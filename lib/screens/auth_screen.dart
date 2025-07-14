import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  bool _obscurePassword = true;

  void toggleMode() => setState(() => isLogin = !isLogin);

  Future<void> submit() async {
    setState(() => isLoading = true);
    try {
      final auth = AuthService();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final name = nameController.text.trim();

      if (isLogin) {
        await auth.login(email, password);
      } else {
        await auth.register(email, password, name, "conducteur");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Une erreur est survenue, veuillez réessayer.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = 'Email ou mot de passe incorrect.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Cet email est déjà utilisé.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur est survenue, veuillez réessayer.')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blueAccent;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.local_shipping_outlined, size: 60, color: primaryColor),
                  Positioned(
                    top: 17,
                    right: 27,
                    child: Icon(Icons.gps_fixed, size: 20, color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                isLogin ? 'Connexion' : 'Inscription',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              if (!isLogin)
                TextField(
                  controller: nameController,
                  decoration: _inputDecoration('Nom et Prénom'),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration('Mot de passe').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                      )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isLogin ? Icons.login : Icons.person_add, size: 24, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(isLogin ? 'Se connecter' : 'Créer un compte',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                      ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: toggleMode,
                child: Text(
                  isLogin ? "Créer un compte" : "J'ai déjà un compte",
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
