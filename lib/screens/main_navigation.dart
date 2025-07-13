import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'map_screen.dart';
import 'vehicle_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/database_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
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

  final List<Widget> _pages = const [
    MapScreen(),
    VehicleScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue[800]!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: themeColor,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Carte',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car),
                label: 'Véhicules',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Historique',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
