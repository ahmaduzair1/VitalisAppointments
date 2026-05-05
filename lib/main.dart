import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_tab_navigator.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const VitalisApp());
}

class VitalisApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

  const VitalisApp({super.key});

  // ── Design tokens ─────────────────────────────────────────
  static const Color _primary = Color(0xFF2563EB);
  static const Color _primaryDark = Color(0xFF3B82F6);

  // Light
  static const Color _bgLight = Color(0xFFF9FAFB);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _textPrimaryLight = Color(0xFF111827);
  static const Color _textSecondaryLight = Color(0xFF6B7280);

  // Dark
  static const Color _bgDark = Color(0xFF0F172A);
  static const Color _surfaceDark = Color(0xFF1E293B);
  static const Color _textPrimaryDark = Color(0xFFF9FAFB);
  static const Color _textSecondaryDark = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Vitalis Appointments',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // ── Light Theme ──────────────────────────────────
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            scaffoldBackgroundColor: _bgLight,
            primaryColor: _primary,
            cardColor: _surfaceLight,
            colorScheme: const ColorScheme.light(
              primary: _primary,
              onPrimary: Colors.white,
              surface: _surfaceLight,
              onSurface: _textPrimaryLight,
              onSurfaceVariant: _textSecondaryLight,
              outline: Color(0xFFE5E7EB),
              error: Color(0xFFEF4444),
            ),
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.light().textTheme,
            ).apply(
              bodyColor: _textPrimaryLight,
              displayColor: _textPrimaryLight,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: _bgLight,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: _textPrimaryLight),
              titleTextStyle: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimaryLight,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
              hintStyle: GoogleFonts.inter(
                color: _textSecondaryLight.withOpacity(0.6),
                fontSize: 15,
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: _surfaceLight,
              selectedItemColor: _primary,
              unselectedItemColor: _textSecondaryLight,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            dividerColor: const Color(0xFFE5E7EB),
          ),

          // ── Dark Theme ───────────────────────────────────
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            scaffoldBackgroundColor: _bgDark,
            primaryColor: _primaryDark,
            cardColor: _surfaceDark,
            colorScheme: const ColorScheme.dark(
              primary: _primaryDark,
              onPrimary: Colors.white,
              surface: _surfaceDark,
              onSurface: _textPrimaryDark,
              onSurfaceVariant: _textSecondaryDark,
              outline: Color(0xFF334155),
              error: Color(0xFFF87171),
            ),
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.dark().textTheme,
            ).apply(
              bodyColor: _textPrimaryDark,
              displayColor: _textPrimaryDark,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: _bgDark,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: _textPrimaryDark),
              titleTextStyle: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimaryDark,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _primaryDark, width: 1.5),
              ),
              hintStyle: GoogleFonts.inter(
                color: _textSecondaryDark.withOpacity(0.6),
                fontSize: 15,
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: _surfaceDark,
              selectedItemColor: _primaryDark,
              unselectedItemColor: _textSecondaryDark,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            dividerColor: const Color(0xFF334155),
          ),

          // Home points to our AuthWrapper
          home: const AuthWrapper(),
        );
      },
    );
  }
}

// ── The Traffic Cop (Auth Wrapper) ───────────────────────
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // 1. While checking Firebase, show the Splash Screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // 2. If we have user data, they are logged in! Send to Dashboard.
        if (snapshot.hasData) {
          return const MainTabNavigator();
        }

        // 3. Otherwise, they are logged out. Send to Login Screen.
        return const LoginScreen();
      },
    );
  }
}