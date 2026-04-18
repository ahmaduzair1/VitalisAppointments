import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
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
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.favorite, color: AppColors.primary, size: 64),
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark),
                children: const [
                  TextSpan(text: 'Vitalis', style: TextStyle(color: AppColors.primary)),
                  TextSpan(text: ' Appointments'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Your Clinical Sanctuary', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}