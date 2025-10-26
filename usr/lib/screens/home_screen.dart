import 'package:flutter/material.dart';
import 'package:gluarash/models/sensor_data.dart';
import 'package:gluarash/services/database_service.dart';
import 'package:gluarash/widgets/sensor_data_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gluarash/services/tensorflow_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TensorflowService _tensorflowService = TensorflowService();
  final DatabaseService _databaseService = DatabaseService();
  BluetoothDevice? _connectedDevice;
  Stream<List<int>>? _dataStream;
  List<double> _rawData = [];
  String _prediction = "N/A";
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _tensorflowService.loadModel();
  }

  @override
  void dispose() {
    _tensorflowService.dispose();
    FlutterBluePlus.stopScan();
    _connectedDevice?.disconnect();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void _startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
    });
    try {
      await device.connect();
      setState(() {
        _connectedDevice = device;
      });
      _discoverServices(device);
    } catch (e) {
      print("Failed to connect: $e");
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _disconnectFromDevice() {
    _connectedDevice?.disconnect();
    setState(() {
      _connectedDevice = null;
      _dataStream = null;
      _prediction = "N/A";
      _rawData = [];
    });
  }

  void _discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      // TODO: Replace with your ESP32's Service UUID
      if (service.uuid.toString().toUpperCase() == "YOUR_SERVICE_UUID_HERE") {
        for (var characteristic in service.characteristics) {
          // TODO: Replace with your ESP32's Characteristic UUID
          if (characteristic.uuid.toString().toUpperCase() == "YOUR_CHARACTERISTIC_UUID_HERE") {
            final isNotifying = await characteristic.setNotifyValue(true);
            if(isNotifying){
               setState(() {
                  _dataStream = characteristic.value;
                  _listenToData();
               });
            }
          }
        }
      }
    }
  }

  void _listenToData() {
    _dataStream?.listen((value) {
      // Assuming the ESP32 sends a comma-separated string of numbers
      String decodedValue = String.fromCharCodes(value);
      List<double> sensorValues = decodedValue.split(',').map((e) => double.tryParse(e) ?? 0.0).toList();
      
      setState(() {
        _rawData = sensorValues;
      });

      // Perform prediction
      final result = _tensorflowService.predict(sensorValues);
      setState(() {
        _prediction = result;
      });

      // Save to database
      final sensorData = SensorData(
        timestamp: DateTime.now(),
        rawData: sensorValues.join(','),
        analyzedResult: result,
      );
      _databaseService.insertData(sensorData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ESP32 Data Analyzer"),
        actions: [
          if (_connectedDevice != null)
            IconButton(
              icon: const Icon(Icons.bluetooth_disabled),
              onPressed: _disconnectFromDevice,
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildConnectionManagementUI(),
            const Divider(height: 32),
            _buildRealtimeDataUI(),
            const Divider(height: 32),
            Expanded(child: _buildDatabaseUI()),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionManagementUI() {
    if (_isConnecting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_connectedDevice != null) {
      return Column(
        children: [
          Text("Connected to: ${_connectedDevice!.localName}", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _disconnectFromDevice,
            child: const Text("Disconnect"),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          ElevatedButton(
            onPressed: _startScan,
            child: const Text("Scan for ESP32 Devices"),
          ),
          StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.scanResults,
            initialData: const [],
            builder: (c, snapshot) => Column(
              children: snapshot.data!.map((r) => ListTile(
                title: Text(r.device.localName.isEmpty ? "Unknown Device" : r.device.localName),
                subtitle: Text(r.device.remoteId.toString()),
                onTap: () => _connectToDevice(r.device),
              )).toList(),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildRealtimeDataUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Real-time Data", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text("Raw Data: ${_rawData.isEmpty ? "N/A" : _rawData.join(', ')}"),
        const SizedBox(height: 8),
        Text("ML Prediction: $_prediction", style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }

  Widget _buildDatabaseUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Stored Data", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<List<SensorData>>(
            future: _databaseService.getData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No data saved yet."));
              }
              return SensorDataList(sensorDataList: snapshot.data!);
            },
          ),
        ),
      ],
    );
  }
}
