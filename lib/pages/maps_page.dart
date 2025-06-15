import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;

import '../containers/position_container.dart';

class MapsPage extends StatefulWidget {
  final Position position;
  
  const MapsPage({
    super.key, 
    required this.position,
  });

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController? mapController;
  late final LatLng _position;
  late final Set<Marker> _markers = {};
  bool _mapError = false;

  @override
  void initState() {
    super.initState();
    _position = widget.position.toLatLng();
    
    _markers.add(
      Marker(
        markerId: MarkerId(widget.position.id.toString()),
        position: _position,
        infoWindow: InfoWindow(
          title: widget.position.vehiculeNom ?? 'Véhicule ${widget.position.vehiculeId}',
          snippet: '${widget.position.latitude.toStringAsFixed(4)}, ${widget.position.longitude.toStringAsFixed(4)}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.position.vehiculeNom ?? 'Position sur la carte'),
        backgroundColor: const Color(0xFF023661),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildMapContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_position, 16),
        ),
        backgroundColor: const Color(0xFF023661),
        child: const Icon(Icons.gps_fixed, color: Colors.white),
      ),
    );
  }

  Widget _buildMapContent() {
    if (_mapError || kIsWeb) {
      return _buildFallbackView();
    }

    return GoogleMap(
      onMapCreated: (controller) {
        setState(() {
          mapController = controller;
        });
      },
      initialCameraPosition: CameraPosition(
        target: _position,
        zoom: 14.0,
      ),
      markers: _markers,
      myLocationEnabled: true,
      zoomControlsEnabled: true,
      onCameraIdle: () {
        if (mapController != null) {
          mapController!.moveCamera(
            CameraUpdate.newLatLng(_position),
          );
        }
      },
    );
  }

  Widget _buildFallbackView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 20),
          const Text('Impossible de charger la carte',
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          Text(
            'Position: ${_position.latitude.toStringAsFixed(4)}, ${_position.longitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _openInExternalMaps,
            child: const Text('Ouvrir dans Google Maps'),
          ),
        ],
      ),
    );
  }

  Future<void> _openInExternalMaps() async {
    final url = widget.position.googleMapsUrl;
    if (kIsWeb) {
      html.window.open(url, '_blank');
    } else {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        setState(() {
          _mapError = true;
        });
      }
    }
  }
}