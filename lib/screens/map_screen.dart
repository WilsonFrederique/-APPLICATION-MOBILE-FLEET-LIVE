import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;

  final DatabaseReference _locationsRef = FirebaseDatabase.instance.ref().child('locations');
  final DatabaseReference _vehiclesRef = FirebaseDatabase.instance.ref().child('vehicles');
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');

  Map<String, Marker> _userMarkers = {};
  Map<String, dynamic> _vehicles = {};
  Map<String, dynamic> _users = {};

  StreamSubscription<DatabaseEvent>? _locationsSubscription;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadVehiclesAndUsers().then((_) {
      _listenToLocations();
    });
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (serviceEnabled && permission != LocationPermission.denied) {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 16),
        );
      }
    }
  }

  Future<void> _loadVehiclesAndUsers() async {
    // Charger tous les véhicules
    final vehiclesSnap = await _vehiclesRef.get();
    if (vehiclesSnap.exists) {
      _vehicles = Map<String, dynamic>.from(vehiclesSnap.value as Map);
    }

    // Charger tous les utilisateurs (conducteurs)
    final usersSnap = await _usersRef.get();
    if (usersSnap.exists) {
      _users = Map<String, dynamic>.from(usersSnap.value as Map);
    }
  }

  void _listenToLocations() {
    _locationsSubscription = _locationsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;

      final Map<dynamic, dynamic> locationsMap = data as Map<dynamic, dynamic>;

      final Map<String, Marker> newMarkers = {};

      locationsMap.forEach((userId, locData) {
        try {
          final lat = locData['lat'];
          final lng = locData['lng'];
          if (lat != null && lng != null) {
            // Chercher le véhicule associé à ce driverId = userId
            final vehicleEntry = _vehicles.entries.firstWhere(
                  (entry) => entry.value['driverId'] == userId,
              orElse: () => MapEntry('', null),
            );

            String vehicleName = vehicleEntry.value != null ? vehicleEntry.value['name'] ?? 'Véhicule inconnu' : 'Véhicule inconnu';
            String plateNumber = vehicleEntry.value != null ? vehicleEntry.value['plateNumber'] ?? '' : '';

            // Chercher le conducteur dans users
            final userData = _users[userId];
            String driverName = userData != null ? userData['name'] ?? 'Conducteur inconnu' : 'Conducteur inconnu';

            // final infoWindowText = '$vehicleName\nPlaque: $plateNumber\nConducteur: $driverName';

            final marker = Marker(
              markerId: MarkerId(userId),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: vehicleName,
                snippet: 'Plaque: $plateNumber\nConducteur: $driverName',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            );

            newMarkers[userId] = marker;
          }
        } catch (e) {
          // Ignore malformed data
        }
      });

      setState(() {
        _userMarkers.clear();
        _userMarkers.addAll(newMarkers);
      });
    });
  }

  @override
  void dispose() {
    _locationsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carte en temps réel')),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 16,
        ),
        myLocationEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: {
          Marker(
            markerId: const MarkerId('current'),
            position: _currentPosition!,
            infoWindow: const InfoWindow(title: 'Position'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
          ..._userMarkers.values,
        },
      ),
    );
  }
}
