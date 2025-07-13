import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final DatabaseService _dbService = DatabaseService();

  late Future<List<Vehicle>> _vehiclesFuture;
  late Future<List<AppUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _vehiclesFuture = _dbService.getAllVehicles();
    _usersFuture = _dbService.getAllUsers();
  }

  Future<void> _showVehicleDialog({Vehicle? vehicle}) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(text: vehicle?.name ?? '');
    final TextEditingController plateController = TextEditingController(text: vehicle?.plateNumber ?? '');

    String? selectedDriverId = vehicle?.driverId;

    final isEditing = vehicle != null;

    // On attend la liste des users pour le dropdown
    final users = await _usersFuture;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(isEditing ? 'Modifier Véhicule' : 'Ajouter Véhicule'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom du véhicule'),
                    validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: plateController,
                    decoration: const InputDecoration(labelText: 'Numéro de plaque'),
                    validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedDriverId,
                    decoration: const InputDecoration(labelText: 'Conducteur'),
                    items: users.map((user) {
                      return DropdownMenuItem(
                        value: user.uid,
                        child: Text(user.name),
                      );
                    }).toList(),
                    onChanged: (val) => setStateDialog(() => selectedDriverId = val),
                    validator: (value) => value == null || value.isEmpty ? 'Veuillez sélectionner un conducteur' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                final newVehicle = Vehicle(
                  vehicleId: isEditing ? vehicle!.vehicleId : _dbService.generateNewKey('vehicles'), // Génère ID auto si création
                  name: nameController.text.trim(),
                  plateNumber: plateController.text.trim(),
                  driverId: selectedDriverId!,
                );

                try {
                  if (isEditing) {
                    await _dbService.updateVehicle(newVehicle);
                  } else {
                    await _dbService.saveVehicle(newVehicle);
                  }
                  Navigator.pop(ctx);
                  setState(() => _loadData());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Véhicule modifié' : 'Véhicule ajouté')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              },
              child: Text(isEditing ? 'Modifier' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteVehicle(String vehicleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce véhicule ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _dbService.deleteVehicle(vehicleId);
        setState(() => _loadData());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Véhicule supprimé')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue[800]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des véhicules'),
        backgroundColor: themeColor,
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final vehicles = snapshot.data ?? [];

          if (vehicles.isEmpty) {
            return const Center(child: Text('Aucun véhicule trouvé'));
          }

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (ctx, index) {
              final vehicle = vehicles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.directions_car_outlined),
                  title: Text(vehicle.name),
                  subtitle: Text('Plaque: ${vehicle.plateNumber}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Modifier',
                        onPressed: () => _showVehicleDialog(vehicle: vehicle),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Supprimer',
                        onPressed: () => _deleteVehicle(vehicle.vehicleId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVehicleDialog(),
        backgroundColor: themeColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Ajouter un véhicule',
      ),
    );
  }
}
