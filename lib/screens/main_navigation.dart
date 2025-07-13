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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: themeColor,
            unselectedItemColor: Colors.grey[600],
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.white,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            selectedIconTheme: IconThemeData(
              size: 28,
              color: themeColor,
            ),
            unselectedIconTheme: IconThemeData(
              size: 26,
              color: Colors.grey[600],
            ),
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Icon(Icons.map_outlined),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Icon(Icons.map),
                ),
                label: 'Carte',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Icon(Icons.directions_car_outlined),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Icon(Icons.directions_car),
                ),
                label: 'Véhicules',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Icon(Icons.history_outlined),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Icon(Icons.history),
                ),
                label: 'Historique',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Icon(Icons.person_outline),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Icon(Icons.person),
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
