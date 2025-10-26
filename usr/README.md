# Gluarash ESP32 & ML Data Analyzer

This project is a Flutter application designed to connect to an ESP32 device, receive sensor data, analyze it using a TensorFlow Lite model, and store the results in a local database.

## Features

- **Bluetooth Connectivity**: Scans for and connects to BLE (Bluetooth Low Energy) devices like the ESP32.
- **Real-time Data Handling**: Receives and displays data streamed from the connected device.
- **Machine Learning**: Uses a TensorFlow Lite model to perform inference on the incoming data.
- **Local Storage**: Saves the raw data and analysis results to a local SQLite database.
- **Data Visualization**: Displays stored data for review.

## Getting Started

This project provides a robust foundation, but requires a few manual setup steps to become fully operational.

### 1. Add Your TensorFlow Lite Model

You must provide your own trained TensorFlow Lite model.

1.  Create a new directory named `assets` in the root of your project.
2.  Place your model file inside this directory and name it `model.tflite`. If you use a different name, be sure to update it in `lib/services/tensorflow_service.dart`.

### 2. Configure Bluetooth Permissions

Bluetooth functionality requires explicit user permissions. You must add the following configurations to your project.

#### Android (`android/app/src/main/AndroidManifest.xml`)

Add the following lines inside the `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS (`ios/Runner/Info.plist`)

Add the following keys and strings to your `Info.plist` file:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to connect to your ESP32 sensor.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth to discover and connect to your ESP32 sensor.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to scan for Bluetooth devices.</string>
```

### 3. Customize Bluetooth Service UUIDs

You need to specify the unique identifiers (UUIDs) for the Bluetooth service and characteristic your ESP32 is broadcasting.

- Open the file `lib/services/bluetooth_service.dart`.
- Find the placeholder UUIDs and replace them with the actual UUIDs from your ESP32 firmware.

```dart
// TODO: Replace with your ESP32's Service and Characteristic UUIDs
final String serviceUUID = "YOUR_SERVICE_UUID_HERE";
final String characteristicUUID = "YOUR_CHARACTERISTIC_UUID_HERE";
```

## Project Structure

- `lib/screens/home_screen.dart`: The main user interface for connecting, viewing data, and results.
- `lib/services/bluetooth_service.dart`: Handles all Bluetooth scanning, connection, and data streaming logic.
- `lib/services/tensorflow_service.dart`: Manages loading the TFLite model and running inference.
- `lib/services/database_service.dart`: Manages all SQLite database operations (saving/reading data).
- `lib/models/sensor_data.dart`: Defines the data structure for sensor readings.
- `lib/widgets/sensor_data_list.dart`: A widget used to display the list of data stored in the database.
