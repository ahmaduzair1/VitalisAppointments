import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/app_config.dart';
import '../services/auth_service.dart';
import 'admin/admin_shell.dart';
import 'login_screen.dart';
import 'main_tab_navigator.dart';
import 'splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(hold: true);
        }
        if (snapshot.hasData) {
          AuthService().ensureUserDocument();
          final user = snapshot.data!;
          if (AppConfig.isAdminEmail(user.email)) {
            return const AdminShell();
          }
          return const MainTabNavigator();
        }
        return const LoginScreen();
      },
    );
  }
}
