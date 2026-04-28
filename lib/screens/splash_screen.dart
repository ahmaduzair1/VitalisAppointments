import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/page_transitions.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, PageTransitions.fade(const OnboardingScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo container
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withAlpha(38),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.favorite_rounded, color: colors.primary, size: 64),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 28),
            // Brand name with staggered animation
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: colors.textPrimary),
                children: [
                  TextSpan(text: 'Vitalis', style: TextStyle(color: colors.primary)),
                  const TextSpan(text: ' Appointments'),
                ],
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut),
            const SizedBox(height: 10),
            Text(
              'Your Clinical Sanctuary',
              style: TextStyle(color: colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w400),
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 500.ms),
          ],
        ),
      ),
    );
  }
}