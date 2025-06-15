import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showAppBar;
  final bool showBackButton; // Rendre optionnel avec une valeur par défaut
  final VoidCallback? onBackPressed;

  const CustomScaffold({
    super.key,
    required this.child,
    this.title,
    this.showAppBar = true,
    this.showBackButton = false, // Valeur par défaut à false
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: onBackPressed ?? () => Navigator.pop(context),
                    )
                  : null,
              title: title != null
                  ? Text(
                      title!,
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
            )
          : null,
      extendBodyBehindAppBar: showAppBar,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/maps5.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}