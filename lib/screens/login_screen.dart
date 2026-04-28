import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/page_transitions.dart';
import '../widgets/vitalis_card.dart';
import '../widgets/vitalis_button.dart';
import '../widgets/vitalis_text_field.dart';
import 'main_tab_navigator.dart';
import 'registration_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: colors.primary.withAlpha(64), blurRadius: 20, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 32),
              )
                  .animate()
                  .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), duration: 500.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Vitalis',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: colors.primary),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),
              // Form card
              VitalisCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Please enter your details to continue', style: TextStyle(color: colors.textSecondary)),
                    const SizedBox(height: AppSpacing.lg),
                    const VitalisTextField(label: 'Email Address', hintText: 'name@vitalis.com'),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Password', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: colors.textPrimary)),
                        Text('Forgot Password?', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const VitalisTextField(hintText: '••••••••', obscureText: true),
                    const SizedBox(height: AppSpacing.lg),
                    VitalisButton(
                      label: 'Sign In →',
                      onPressed: () => Navigator.pushReplacement(context, PageTransitions.fadeSlide(const MainTabNavigator())),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: TextStyle(color: colors.textSecondary)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(context, PageTransitions.fadeSlide(const RegistrationScreen())),
                          child: Text('Sign Up', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut),
            ],
          ),
        ),
      ),
    );
  }
}