import 'package:flutter/material.dart';
import 'package:fleetlive/widgets/custom_scaffold.dart';

import 'vehicule_frm_container.dart';

class Vehicule {
  final int id;
  final String nom;
  final String plaque;
  final String statut;
  final DateTime? lastUpdate;

  Vehicule({
    required this.id,
    required this.nom,
    required this.plaque,
    required this.statut,
    this.lastUpdate,
  });

  factory Vehicule.fromMap(Map<String, dynamic> map) {
    return Vehicule(
      id: map['id'] as int,
      nom: map['nom'] as String,
      plaque: map['plaque'] as String,
      statut: map['statut'] as String,
      lastUpdate: map['lastUpdate'] != null 
          ? DateTime.parse(map['lastUpdate']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'plaque': plaque,
      'statut': statut,
      if (lastUpdate != null) 'lastUpdate': lastUpdate!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Vehicule{id: $id, nom: $nom, plaque: $plaque, statut: $statut}';
  }
}

class VehiculeContainer extends StatefulWidget {
  const VehiculeContainer({super.key});

  @override
  State<VehiculeContainer> createState() => _VehiculeContainerState();
}

class _VehiculeContainerState extends State<VehiculeContainer> {
  late Size mq;
  List<Vehicule> _allVehicules = [];
  List<Vehicule> _filteredVehicules = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicules();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicules() async {
    // Simuler un chargement asynchrone
    await Future.delayed(const Duration(seconds: 1));

    // Données d'exemple
    final exampleVehicules = [
      Vehicule(
        id: 1, 
        nom: 'Voiture 1', 
        plaque: 'ABC-123', 
        statut: 'en_route',
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      Vehicule(
        id: 2, 
        nom: 'Voiture 2', 
        plaque: 'XYZ-789', 
        statut: 'arreté',
        lastUpdate: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Vehicule(
        id: 3, 
        nom: 'Voiture 3', 
        plaque: 'DEF-456', 
        statut: 'hors_zone',
        lastUpdate: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Vehicule(
        id: 4, 
        nom: 'Voiture 4', 
        plaque: 'GHI-101', 
        statut: 'en_route',
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      Vehicule(
        id: 5, 
        nom: 'Voiture 5', 
        plaque: 'GHI-102', 
        statut: 'en_route',
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Vehicule(
        id: 6, 
        nom: 'Voiture 6', 
        plaque: 'ABC-124', 
        statut: 'arreté',
        lastUpdate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Vehicule(
        id: 7, 
        nom: 'Voiture 7', 
        plaque: 'ABC-125', 
        statut: 'en_route',
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];

    setState(() {
      _allVehicules = exampleVehicules;
      _filteredVehicules = exampleVehicules;
      _isLoading = false;
    });
  }

  void _filterVehicules(String query) {
    setState(() {
      _filteredVehicules = _allVehicules.where((vehicule) {
        final nom = vehicule.nom.toLowerCase();
        final plaque = vehicule.plaque.toLowerCase();
        final searchLower = query.toLowerCase();
        return nom.contains(searchLower) || plaque.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadVehicules();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return CustomScaffold(
      showAppBar: false,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _filteredVehicules.isEmpty
                    ? _buildEmptyState()
                    : _buildVehiculeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Liste des Véhicules',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VehiculeFrmContainer()),
                  );
                },
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        hintText: 'Rechercher par nom ou plaque...',
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  _searchController.clear();
                  _filterVehicules('');
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
      onChanged: _filterVehicules,
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 60, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            'Aucun véhicule trouvé',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                _filterVehicules('');
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

  Widget _buildVehiculeList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        itemCount: _filteredVehicules.length,
        itemBuilder: (context, index) {
          return _buildVehiculeCard(_filteredVehicules[index]);
        },
      ),
    );
  }

  Widget _buildVehiculeCard(Vehicule vehicule) {
    final statusColor = _getStatusColor(vehicule.statut);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatusIcon(statusColor, vehicule.statut),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicule.nom,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicule.plaque,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(statusColor, vehicule.statut),
              ],
            ),
            if (vehicule.lastUpdate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Mis à jour: ${_formatTime(vehicule.lastUpdate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(Color color, String status) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(_getStatusIcon(status), color: color),
    );
  }

  Widget _buildStatusChip(Color color, String status) {
    return Chip(
      backgroundColor: color.withOpacity(0.1),
      label: Text(
        _formatStatus(status),
        style: TextStyle(color: color),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'en_route':
        return Colors.green;
      case 'arreté':
        return Colors.orange;
      case 'hors_zone':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'en_route':
        return Icons.directions_car;
      case 'arreté':
        return Icons.time_to_leave;
      case 'hors_zone':
        return Icons.location_off;
      default:
        return Icons.help_outline;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')} - ${time.day}/${time.month}/${time.year}';
  }
}