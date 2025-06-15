import 'package:flutter/material.dart';
import 'package:fleetlive/widgets/custom_scaffold.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart' show CameraPosition, GoogleMap, InfoWindow, LatLng, Marker, MarkerId;
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class Position {
  final int? id;
  final int vehiculeId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? vehiculeNom;
  final String? vehiculePlaque;

  Position({
    this.id,
    required this.vehiculeId,
    required this.latitude,
    required this.longitude,
    DateTime? timestamp,
    this.vehiculeNom,
    this.vehiculePlaque,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Position.fromMap(Map<String, dynamic> map) {
    return Position(
      id: map['id'] as int?,
      vehiculeId: map['vehicule_id'] as int,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : null,
      vehiculeNom: map['vehicule_nom'] as String?,
      vehiculePlaque: map['vehicule_plaque'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicule_id': vehiculeId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      if (vehiculeNom != null) 'vehicule_nom': vehiculeNom,
      if (vehiculePlaque != null) 'vehicule_plaque': vehiculePlaque,
    };
  }

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  String get googleMapsUrl {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  @override
  String toString() {
    return 'Position{id: $id, vehiculeId: $vehiculeId, lat: $latitude, lng: $longitude, time: $timestamp}';
  }
}

class PositionContainer extends StatefulWidget {
  final Function(Position)? onPositionAdded;
  
  const PositionContainer({super.key, this.onPositionAdded});

  @override
  State<PositionContainer> createState() => _PositionContainerState();
}

class _PositionContainerState extends State<PositionContainer> {
  late Size mq;
  List<Position> _allPositions = [];
  List<Position> _filteredPositions = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  Position? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Chargement 
  Future<void> _loadPositions() async {
    // Simuler un chargement asynchrone
    await Future.delayed(const Duration(seconds: 1));

    // Données d'exemple
    final examplePositions = [
      Position(
        id: 1,
        vehiculeId: 1,
        latitude: 48.8566,
        longitude: 2.3522,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        vehiculeNom: 'Camion 1',
        vehiculePlaque: 'ABC-123',
      ),
      Position(
        id: 2,
        vehiculeId: 2,
        latitude: 45.7640,
        longitude: 4.8357,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        vehiculeNom: 'Voiture 2',
        vehiculePlaque: 'XYZ-789',
      ),
      Position(
        id: 3,
        vehiculeId: 3,
        latitude: 43.2965,
        longitude: 5.3698,
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        vehiculeNom: 'Fourgon 3',
        vehiculePlaque: 'DEF-456',
      ),
    ];

    setState(() {
      _allPositions = examplePositions;
      _filteredPositions = examplePositions;
      _isLoading = false;
    });
  }

  void _filterPositions(String query) {
    setState(() {
      _filteredPositions = _allPositions.where((position) {
        final nom = position.vehiculeNom?.toLowerCase() ?? '';
        final plaque = position.vehiculePlaque?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return nom.contains(searchLower) || plaque.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _selectedPosition = null;
    });
    await _loadPositions();
  }

  Future<void> _showPositionOnMap(Position position) async {
    if (kIsWeb) {
      // Solution pour le web
      html.window.open(position.googleMapsUrl, '_blank');
    } else {
      // Solution pour mobile
      setState(() {
        _selectedPosition = position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return CustomScaffold(
      showAppBar: false,
      child: Column(
        children: [
          _buildHeader(),
          if (!kIsWeb && _selectedPosition != null)
            _buildMobileMapSection(_selectedPosition!),
          if (kIsWeb && _selectedPosition != null)
            _buildWebMapSection(_selectedPosition!),
          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _filteredPositions.isEmpty
                    ? _buildEmptyState()
                    : _buildPositionList(),
          ),
        ],
      ),
    );
  }

  // Dernières positions & Icon initial 
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Dernières positions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _refreshData,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSearchField(),
        ],
      ),
    );
  }

  // Rechercher par véhicule... 
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        hintText: 'Rechercher par véhicule...',
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  _searchController.clear();
                  _filterPositions('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      onChanged: _filterPositions,
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // Aucune position trouvée et Réinitialiser la recherche 
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 60, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            'Aucune position trouvée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                _filterPositions('');
              },
              child: const Text(
                'Réinitialiser la recherche',
                style: TextStyle(color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPositionList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        itemCount: _filteredPositions.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showPositionOnMap(_filteredPositions[index]),
            child: _buildPositionCard(_filteredPositions[index]),
          );
        },
      ),
    );
  }

  // Contenue ou Resultat 
  Widget _buildPositionCard(Position position) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_pin, color: Colors.red[400]),
                const SizedBox(width: 8),
                Text(
                  position.vehiculeNom ?? 'Véhicule ${position.vehiculeId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  position.vehiculePlaque ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoItem(Icons.my_location, 
                    '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'),
                const Spacer(),
                _buildInfoItem(Icons.access_time, 
                    '${position.timestamp.hour}:${position.timestamp.minute.toString().padLeft(2, '0')}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Icone & Text color latitude et Longitude
  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMapSection(Position position) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: position.toLatLng(),
            zoom: 14,
          ),
          markers: {
            Marker(
              markerId: MarkerId(position.id.toString()),
              position: position.toLatLng(),
              infoWindow: InfoWindow(
                title: position.vehiculeNom ?? 'Véhicule ${position.vehiculeId}',
                snippet: '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
              ),
            ),
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }

  Widget _buildWebMapSection(Position position) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              _getStaticMapUrl(position),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () => html.window.open(position.googleMapsUrl, '_blank'),
                child: const Icon(Icons.open_in_new, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // GOOGLE Maps 
  String _getStaticMapUrl(Position position) {
    const apiKey = 'MY_GOOGLE_MAPS_API_KEY'; // Ici est mon clé API , mais MY_GOOGLE_MAPS_API_KEY est juste exemple
    final lat = position.latitude;
    final lng = position.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=14&size=600x300&maptype=roadmap&markers=color:red%7C$lat,$lng&key=$apiKey';
  }
}