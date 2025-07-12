import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/database_service.dart';
import 'history_map_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final dbService = DatabaseService();
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = dbService.getAllVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des positions')),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun véhicule trouvé'));
          }

          final vehicles = snapshot.data!;
          return ListView.separated(
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return ListTile(
                leading: const Icon(Icons.directions_car_outlined),
                title: Text(vehicle.name),
                subtitle: Text(vehicle.plateNumber),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryMapScreen(vehicle: vehicle),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
