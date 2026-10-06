import 'package:flutter/material.dart';
import '../services/chalisa_service.dart';
import '../widgets/hanuman_intro_animation.dart';
import 'home_screen.dart';

class OnboardingAnimationScreen extends StatelessWidget {
  final ChalisaService chalisaService;

  const OnboardingAnimationScreen({super.key, required this.chalisaService});

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HomeScreen(chalisaService: chalisaService),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF19161B),
      body: SafeArea(
        child: HanumanIntroAnimation(
          onBeginJourney: () => _navigateToHome(context),
        ),
      ),
    );
  }
}
