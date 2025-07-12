import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'map_screen.dart';
import 'vehicle_screen.dart';
import 'history_screen.dart';
import '../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final locationService = LocationService();
  final dbService = DatabaseService();
  final authService = AuthService();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startAutomaticTracking();
  }

  void startAutomaticTracking() {
    const interval = Duration(seconds: 10);

    _timer = Timer.periodic(interval, (_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final position = await locationService.getCurrentPosition();
      if (position != null) {
        await dbService.saveCurrentPosition(user.uid, position);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue[800]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text('Surveillance de flotte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Déconnexion",
            onPressed: () => authService.logout(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(Icons.location_on, size: 60, color: themeColor),
                  const SizedBox(height: 12),
                  Text(
                    'Bienvenue dans votre tableau de bord',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: themeColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.map_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                iconColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              label: const Text(
                'Visualiser les véhicules en temps réel',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                iconColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              label: const Text(
                'Gérer les véhicules',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                iconColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              label: const Text(
                'Historique des positions',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                'Suivi actif toutes les 10 secondes',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
