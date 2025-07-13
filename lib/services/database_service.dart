import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../models/position_model.dart';
import '../models/vehicle_model.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  String generateNewKey(String path) {
    return _db.child(path).push().key ?? '';
  }

  // Users services

  Future<void> saveUser(AppUser user) async {
    await _db.child('users/${user.uid}').set(user.toMap());
  }

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _db.child('users').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        return AppUser.fromMap(entry.value, entry.key);
      }).toList();
    }
    return [];
  }


  Future<AppUser?> fetchUser(String uid) async {
    final snapshot = await _db.child('users/$uid').get();
    if (snapshot.exists) {
      return AppUser.fromMap(snapshot.value as Map, uid);
    }
    return null;
  }

  // Positions services
  Future<void> saveCurrentPosition(String uid, PositionData data) async {
    final timestampKey = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.child('locations/$uid').set(data.toMap());
    await _db.child('positions_history/$uid/$timestampKey')
        .set(data.toMap());
  }

  Future<List<PositionData>> fetchPositionHistory(String uid) async {
    final snapshot = await _db.child('positions_history/$uid').get();
    if (snapshot.exists) {
      final map = snapshot.value as Map;
      return map.values.map((e) => PositionData.fromMap(e)).toList();
    }
    return [];
  }

  // vehicles services

  Future<void> saveVehicle(Vehicle vehicle) async {
    await _db.child('vehicles/${vehicle.vehicleId}').set(vehicle.toMap());
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final snapshot = await _db.child('vehicles').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        return Vehicle.fromMap(entry.value, entry.key);
      }).toList();
    } else {
      return [];
    }
  }

  Future<Vehicle?> getVehicleById(String vehicleId) async {
    final snapshot = await _db.child('vehicles/$vehicleId').get();
    if (snapshot.exists) {
      return Vehicle.fromMap(snapshot.value as Map, vehicleId);
    }
    return null;
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _db.child('vehicles/${vehicle.vehicleId}').update(vehicle.toMap());
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await _db.child('vehicles/$vehicleId').remove();
  }
}
