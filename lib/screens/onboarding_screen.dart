import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/page_transitions.dart';
import '../widgets/vitalis_button.dart';
import '../widgets/vitalis_card.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    PageTransitions.fade(const LoginScreen()),
                  ),
                  child: Text('Skip', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w500)),
                ),
              ),
              const Spacer(),
              // Illustration card
              VitalisCard(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Icon(Icons.medical_services_rounded, size: 100, color: colors.primary),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.15, end: 0, duration: 600.ms, curve: Curves.easeOut),
              const SizedBox(height: 40),
              Text(
                'Find Top Doctors',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: colors.textPrimary),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Access a network of highly-rated specialists near you. We curate the best so you receive the highest quality of care.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary, fontSize: 16, height: 1.6),
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 500.ms),
              const Spacer(),
              VitalisButton(
                label: 'Continue →',
                onPressed: () => Navigator.pushReplacement(
                  context,
                  PageTransitions.fade(const LoginScreen()),
                ),
              )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.3, end: 0, duration: 400.ms),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}