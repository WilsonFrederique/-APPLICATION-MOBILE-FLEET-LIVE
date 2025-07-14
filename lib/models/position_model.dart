class PositionData {
  final double lat;
  final double lng;
  final DateTime timestamp;

  PositionData({
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  factory PositionData.fromMap(Map<dynamic, dynamic> data) {
    return PositionData(
      lat: data['lat'],
      lng: data['lng'],
      timestamp: DateTime.parse(data['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
