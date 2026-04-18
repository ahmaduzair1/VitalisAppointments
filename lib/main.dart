import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/app_colors.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const VitalisApp());
}

class VitalisApp extends StatelessWidget {
  const VitalisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vitalis Appointments',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}