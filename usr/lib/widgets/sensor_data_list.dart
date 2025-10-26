import 'package:flutter/material.dart';
import 'package:gluarash/models/sensor_data.dart';

class SensorDataList extends StatelessWidget {
  final List<SensorData> sensorDataList;

  const SensorDataList({super.key, required this.sensorDataList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sensorDataList.length,
      itemBuilder: (context, index) {
        final item = sensorDataList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          child: ListTile(
            title: Text("Prediction: ${item.analyzedResult}"),
            subtitle: Text("Data: ${item.rawData}"),
            trailing: Text(
              "${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }
}
