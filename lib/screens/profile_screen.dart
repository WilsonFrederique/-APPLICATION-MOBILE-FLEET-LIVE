import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authService = AuthService();
  final dbService = DatabaseService();

  AppUser? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final user = await dbService.fetchUser(firebaseUser.uid);
      setState(() {
        currentUser = user ??
            AppUser(
              uid: firebaseUser.uid,
              name: firebaseUser.displayName ?? 'Administrateur',
              email: firebaseUser.email ?? '',
              role: 'administrateur',
            );
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue[800]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text('Profil utilisateur'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentUser == null
          ? const Center(child: Text("Utilisateur introuvable"))
          : Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: themeColor,
                    child: const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                _profileItem('Nom et Prénom', currentUser!.name),
                _profileItem('Email', currentUser!.email),
                _profileItem('Rôle', currentUser!.role),
                const Spacer(),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => authService.logout(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Se déconnecter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _profileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue[300]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
