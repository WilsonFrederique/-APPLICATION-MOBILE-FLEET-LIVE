import 'package:geolocator/geolocator.dart';
import '../models/position_model.dart';

class LocationService {
  Future<PositionData?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (!serviceEnabled || permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
      return null;
    }

    Position pos = await Geolocator.getCurrentPosition();
    return PositionData(
      lat: pos.latitude,
      lng: pos.longitude,
      timestamp: DateTime.now(),
    );
  }
}
