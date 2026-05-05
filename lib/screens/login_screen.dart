import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/page_transitions.dart';
import '../widgets/vitalis_button.dart';
import 'main_tab_navigator.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    _emailError = null;
    _passwordError = null;

    if (_emailController.text.isEmpty) {
      _emailError = 'Email cannot be empty';
    } else if (!_emailController.text.contains('@')) {
      _emailError = 'Please enter a valid email';
    }

    if (_passwordController.text.isEmpty) {
      _passwordError = 'Password cannot be empty';
    } else if (_passwordController.text.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
    }

    setState(() {});
    return _emailError == null && _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // ── Logo ──────────────────────────────────
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [cs.primary, cs.primary.withOpacity(0.8)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(Icons.favorite_rounded, color: cs.onPrimary, size: 32),
                  ),
                ).animate().scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ).fadeIn(duration: 300.ms),

                const SizedBox(height: 32),

                // ── Welcome text ──────────────────────────
                Center(
                  child: Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Sign in to continue to Vitalis',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 40),

                // ── Email field ───────────────────────────
                _buildLabel('Email Address'),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: cs.onSurface, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'name@vitalis.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded,
                        color: cs.onSurfaceVariant, size: 20),
                    errorText: _emailError,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Password field ────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Password'),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: cs.onSurface, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: Icon(Icons.lock_outline_rounded,
                        color: cs.onSurfaceVariant, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: cs.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    errorText: _passwordError,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Sign In button ────────────────────────
                VitalisButton(
                  label: 'Sign In',
                  onPressed: () {
                    if (_validateForm()) {
                      Navigator.pushReplacement(
                        context,
                        PageTransitions.fadeSlide(const MainTabNavigator()),
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),

                // ── Divider ───────────────────────────────
                Row(
                  children: [
                    Expanded(child: Divider(color: cs.outline)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: cs.outline)),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Social sign in ────────────────────────
                VitalisButton(
                  label: 'Continue with Google',
                  variant: VitalisButtonVariant.secondary,
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageTransitions.fadeSlide(const MainTabNavigator()),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ── Sign Up link ──────────────────────────
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          PageTransitions.fadeSlide(const RegistrationScreen()),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: cs.onSurface,
      ),
    );
  }
}