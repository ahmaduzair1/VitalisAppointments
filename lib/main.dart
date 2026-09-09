import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';
import 'services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
  try {
    await ReminderService.instance.init();
  } catch (e) {
    debugPrint('Reminder init skipped: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const VitalisApp());
}

class VitalisApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);

  const VitalisApp({super.key});

  static const Color _primary = Color(0xFF0F766E);
  static const Color _primaryDark = Color(0xFF2DD4BF);

  static const Color _bgLight = Color(0xFFF4F7F7);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _textPrimaryLight = Color(0xFF134E4A);
  static const Color _textSecondaryLight = Color(0xFF5B6B6A);

  static const Color _bgDark = Color(0xFF0B1414);
  static const Color _surfaceDark = Color(0xFF14201F);
  static const Color _textPrimaryDark = Color(0xFFF0FDFA);
  static const Color _textSecondaryDark = Color(0xFF94A8A6);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, _) {
        return MaterialApp(
          title: 'Vitalis',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
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
              outline: Color(0xFFD5E3E1),
              error: Color(0xFFDC2626),
              secondary: Color(0xFF0EA5A4),
            ),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
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
              titleTextStyle: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimaryLight,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFECF4F3),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: _surfaceLight,
              selectedItemColor: _primary,
              unselectedItemColor: _textSecondaryLight,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedLabelStyle:
                  TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle:
                  TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            dividerColor: const Color(0xFFD5E3E1),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            scaffoldBackgroundColor: _bgDark,
            primaryColor: _primaryDark,
            cardColor: _surfaceDark,
            colorScheme: const ColorScheme.dark(
              primary: _primaryDark,
              onPrimary: Color(0xFF042F2E),
              surface: _surfaceDark,
              onSurface: _textPrimaryDark,
              onSurfaceVariant: _textSecondaryDark,
              outline: Color(0xFF2A3F3D),
              error: Color(0xFFF87171),
              secondary: Color(0xFF5EEAD4),
            ),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
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
              titleTextStyle: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimaryDark,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryDark,
                foregroundColor: const Color(0xFF042F2E),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF14201F),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF2A3F3D)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF2A3F3D)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _primaryDark, width: 1.5),
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: _surfaceDark,
              selectedItemColor: _primaryDark,
              unselectedItemColor: _textSecondaryDark,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedLabelStyle:
                  TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle:
                  TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            dividerColor: const Color(0xFF2A3F3D),
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}
