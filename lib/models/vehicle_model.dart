class Vehicle {
  final String vehicleId;
  final String name;
  final String plateNumber;
  final String driverId;

  Vehicle({
    required this.vehicleId,
    required this.name,
    required this.plateNumber,
    required this.driverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'plateNumber': plateNumber,
      'driverId': driverId,
    };
  }

  factory Vehicle.fromMap(Map<dynamic, dynamic> map, String id) {
    return Vehicle(
      vehicleId: id,
      name: map['name'],
      plateNumber: map['plateNumber'],
      driverId: map['driverId'],
    );
  }
}
