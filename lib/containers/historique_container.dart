import 'package:flutter/material.dart';
import 'package:fleetlive/widgets/custom_scaffold.dart';

class Historique {
  final int? id;
  final int vehiculeId;
  final String action;
  final DateTime timestamp;
  final String? vehiculeNom;
  final String? vehiculePlaque;

  Historique({
    this.id,
    required this.vehiculeId,
    required this.action,
    DateTime? timestamp,
    this.vehiculeNom,
    this.vehiculePlaque,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Historique.fromMap(Map<String, dynamic> map) {
    return Historique(
      id: map['id'] as int?,
      vehiculeId: map['vehicule_id'] as int,
      action: map['action'] as String,
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
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      if (vehiculeNom != null) 'vehicule_nom': vehiculeNom,
      if (vehiculePlaque != null) 'vehicule_plaque': vehiculePlaque,
    };
  }

  @override
  String toString() {
    return 'Historique{id: $id, vehiculeId: $vehiculeId, action: $action, time: $timestamp}';
  }
}

class HistoriqueContainer extends StatefulWidget {
  const HistoriqueContainer({super.key});

  @override
  State<HistoriqueContainer> createState() => _HistoriqueContainerState();
}

class _HistoriqueContainerState extends State<HistoriqueContainer> {
  late Size mq;
  List<Historique> _allHistoriques = [];
  List<Historique> _filteredHistoriques = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoriques();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoriques() async {
    // Simuler un chargement asynchrone
    await Future.delayed(const Duration(seconds: 1));

    // Données d'exemple
    final exampleHistoriques = [
      Historique(
        id: 1,
        vehiculeId: 1,
        action: 'Départ du dépôt',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        vehiculeNom: 'Camion 1',
        vehiculePlaque: 'ABC-123',
      ),
      Historique(
        id: 2,
        vehiculeId: 2,
        action: 'Arrivée sur site',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        vehiculeNom: 'Voiture 2',
        vehiculePlaque: 'XYZ-789',
      ),
      Historique(
        id: 3,
        vehiculeId: 3,
        action: 'Maintenance effectuée',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        vehiculeNom: 'Fourgon 3',
        vehiculePlaque: 'DEF-456',
      ),
    ];

    setState(() {
      _allHistoriques = exampleHistoriques;
      _filteredHistoriques = exampleHistoriques;
      _isLoading = false;
    });
  }

  void _filterHistoriques(String query) {
    setState(() {
      _filteredHistoriques = _allHistoriques.where((historique) {
        final nom = historique.vehiculeNom?.toLowerCase() ?? '';
        final plaque = historique.vehiculePlaque?.toLowerCase() ?? '';
        final action = historique.action.toLowerCase();
        final searchLower = query.toLowerCase();
        return nom.contains(searchLower) || 
               plaque.contains(searchLower) ||
               action.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadHistoriques();
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
                : _filteredHistoriques.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoriqueList(),
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
              const Expanded(child: SizedBox()),
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
        hintText: 'Rechercher par véhicule ou action...',
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  _searchController.clear();
                  _filterHistoriques('');
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
      onChanged: _filterHistoriques,
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
          const Icon(Icons.history, size: 60, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            'Aucun historique trouvé',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                _filterHistoriques('');
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

  Widget _buildHistoriqueList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        itemCount: _filteredHistoriques.length,
        itemBuilder: (context, index) {
          return _buildHistoriqueCard(_filteredHistoriques[index]);
        },
      ),
    );
  }

  Widget _buildHistoriqueCard(Historique historique) {
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
                Icon(Icons.history, color: Colors.blue[400]),
                const SizedBox(width: 8),
                Text(
                  historique.vehiculeNom ?? 'Véhicule ${historique.vehiculeId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  historique.vehiculePlaque ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              historique.action,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoItem(Icons.access_time, 
                    '${historique.timestamp.hour}:${historique.timestamp.minute.toString().padLeft(2, '0')}'),
                const Spacer(),
                _buildInfoItem(Icons.calendar_today, 
                    '${historique.timestamp.day}/${historique.timestamp.month}/${historique.timestamp.year}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
}