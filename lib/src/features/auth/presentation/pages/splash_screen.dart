import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartmushroom_app/src/core/auth/auth_storage.dart';
import 'package:smartmushroom_app/src/features/auth/presentation/pages/login_screen.dart';
import 'package:smartmushroom_app/src/features/home/presentation/pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;
  late final AuthStorage _authStorage;

  @override
  void initState() {
    super.initState();
    _authStorage = AuthStorage();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInSine));

    _controller.forward();

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final hasSession = _authStorage.hasSession;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              hasSession ? const HomePage() : const LoginScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLight = theme.brightness == Brightness.light;
    final Color logoColor =
        isLight ? theme.colorScheme.primary : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: Image.asset(
              'assets/logoG.png',
              width: 350,
              color: logoColor,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
