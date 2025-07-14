import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/vehicle_model.dart';
import '../models/position_model.dart';
import '../services/database_service.dart';

class HistoryMapScreen extends StatefulWidget {
  final Vehicle vehicle;

  const HistoryMapScreen({required this.vehicle, super.key});

  @override
  State<HistoryMapScreen> createState() => _HistoryMapScreenState();
}

class _HistoryMapScreenState extends State<HistoryMapScreen> {
  final dbService = DatabaseService();
  List<PositionData> _positions = [];
  bool _loading = true;

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    final positions = await dbService.fetchPositionHistory(widget.vehicle.vehicleId);
    setState(() {
      _positions = positions;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialPos = const LatLng(0, 0);
    if (_positions.isNotEmpty) {
      final first = _positions.first;
      initialPos = LatLng(first.lat, first.lng);
    }

    Set<Marker> markers = {};
    List<LatLng> polylinePoints = [];

    for (int i = 0; i < _positions.length; i++) {
      final pos = _positions[i];
      final latLng = LatLng(pos.lat, pos.lng);
      polylinePoints.add(latLng);

      markers.add(
        Marker(
          markerId: MarkerId('pos_$i'),
          position: latLng,
          infoWindow: InfoWindow(
            title: widget.vehicle.name,
            snippet: 'Position à ${pos.timestamp}',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Trajet historique: ${widget.vehicle.name}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPos,
          zoom: 14,
        ),
        markers: markers,
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylinePoints,
            color: Colors.blue,
            width: 4,
          ),
        },
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
