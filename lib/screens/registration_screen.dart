import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/page_transitions.dart';
import '../widgets/vitalis_button.dart';
import 'login_screen.dart';
import 'main_tab_navigator.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    _nameError = null;
    _emailError = null;
    _passwordError = null;

    if (_nameController.text.isEmpty) {
      _nameError = 'Full name cannot be empty';
    }
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
    return _nameError == null && _emailError == null && _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                const SizedBox(height: 16),

                // ── Header ────────────────────────────────
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
                    child: Icon(Icons.person_add_rounded, color: cs.onPrimary, size: 32),
                  ),
                ).animate().scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ).fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'Create Account',
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
                    'Sign up to start booking appointments',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 32),

                // ── Full Name ─────────────────────────────
                _buildLabel('Full Name'),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: cs.onSurface, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Sarah Jenkins',
                    prefixIcon: Icon(Icons.person_outline_rounded,
                        color: cs.onSurfaceVariant, size: 20),
                    errorText: _nameError,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Email ─────────────────────────────────
                _buildLabel('Email Address'),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: cs.onSurface, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'name@example.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded,
                        color: cs.onSurfaceVariant, size: 20),
                    errorText: _emailError,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Password ──────────────────────────────
                _buildLabel('Password'),
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

                // ── Sign Up ───────────────────────────────
                VitalisButton(
                  label: 'Create Account',
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

                // ── Sign In link ──────────────────────────
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          PageTransitions.fade(const LoginScreen()),
                        ),
                        child: Text(
                          'Sign In',
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