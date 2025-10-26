class SensorData {
  final int? id;
  final DateTime timestamp;
  final String rawData;
  final String analyzedResult;

  SensorData({
    this.id,
    required this.timestamp,
    required this.rawData,
    required this.analyzedResult,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'rawData': rawData,
      'analyzedResult': analyzedResult,
    };
  }

  factory SensorData.fromMap(Map<String, dynamic> map) {
    return SensorData(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      rawData: map['rawData'],
      analyzedResult: map['analyzedResult'],
    );
  }
}
