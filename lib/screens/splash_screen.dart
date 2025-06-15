import 'package:fleetlive/containers/position_frm_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fleetlive/widgets/custom_scaffold.dart';
import 'package:fleetlive/screens/home_screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Size mq;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return CustomScaffold(
      // title: 'Bienvenue dans Fleet Live',
      child: Stack(
        children: [
          Positioned(
            top: mq.height * 0.10, // légèrement plus haut
            left: mq.width * 0.10, // centrer un peu plus
            width: mq.width * 0.8, // agrandir à 80% de largeur
            child: Image.asset(
              'assets/images/logo2.png',
              fit: BoxFit.contain, // pour qu’elle garde ses proportions
            ),
          ),
          Positioned(
            bottom: mq.height * .13,
            width: mq.width,
            child: const Text(
              // 'FABRIQUÉ À MADAGASCAR AVEC 💖',
              'BIENVENUE DANS FLEET LIVE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                letterSpacing: .5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
