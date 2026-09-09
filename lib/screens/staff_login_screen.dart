import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_config.dart';
import '../services/auth_service.dart';
import '../widgets/vitalis_button.dart';

/// Hospital staff sign-in. Same Firebase email/password auth as patients.
/// Only the configured staff email can open the admin board.
class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    _emailError = null;
    _passwordError = null;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _emailError = 'Email cannot be empty';
    } else if (!email.contains('@')) {
      _emailError = 'Please enter a valid email';
    } else if (!AppConfig.isAdminEmail(email)) {
      _emailError = 'This sign-in is for hospital staff only';
    }

    if (_passwordController.text.isEmpty) {
      _passwordError = 'Password cannot be empty';
    } else if (_passwordController.text.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
    }

    setState(() {});
    return _emailError == null && _passwordError == null;
  }

  Future<void> _signIn() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (user == null || !AppConfig.isAdminEmail(user.email)) {
        await _authService.signOut();
        throw Exception('This account is not hospital staff.');
      }
      if (!mounted) return;
      // Staff screen was pushed on top of the auth gate. Pop it so the
      // board can show after Firebase signs in.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final resetEmailController =
        TextEditingController(text: _emailController.text);
    var isResetLoading = false;
    String? resetMessage;
    var isError = false;

    try {
      await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final cs = Theme.of(context).colorScheme;
            return AlertDialog(
              backgroundColor: cs.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Reset password',
                  style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter the staff email. Firebase will send a reset link, same as patient accounts.',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Staff email'),
                  ),
                  if (resetMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      resetMessage!,
                      style: TextStyle(
                        color: isError ? cs.error : Colors.green,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: isResetLoading
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();
                          if (!AppConfig.isAdminEmail(email)) {
                            setDialogState(() {
                              isError = true;
                              resetMessage = 'Use the hospital staff email.';
                            });
                            return;
                          }
                          setDialogState(() {
                            isResetLoading = true;
                            resetMessage = null;
                          });
                          try {
                            await _authService.sendPasswordResetEmail(email);
                            setDialogState(() {
                              isResetLoading = false;
                              isError = false;
                              resetMessage = 'Reset link sent. Check inbox or spam.';
                            });
                          } catch (e) {
                            setDialogState(() {
                              isResetLoading = false;
                              isError = true;
                              resetMessage = e.toString().replaceAll('Exception: ', '');
                            });
                          }
                        },
                  child: isResetLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Send link'),
                ),
              ],
            );
          },
        );
      },
    );
    } finally {
      resetEmailController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.primary.withValues(alpha: 0.8)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.local_hospital_rounded, color: cs.onPrimary, size: 32),
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Staff sign in',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Use your hospital email and password.\nFirebase checks this the same way as patients.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14, height: 1.5),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Email',
                    style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.username, AutofillHints.email],
                  decoration: InputDecoration(
                    hintText: 'Staff email',
                    prefixIcon: Icon(Icons.mail_outline_rounded, color: cs.onSurfaceVariant),
                  ),
                ),
                if (_emailError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8),
                    child: Text(_emailError!, style: TextStyle(color: cs.error, fontSize: 12)),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Password',
                        style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
                    GestureDetector(
                      onTap: _showForgotPasswordDialog,
                      child: Text(
                        'Forgot password?',
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
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _signIn(),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: cs.onSurfaceVariant),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: cs.onSurfaceVariant,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                if (_passwordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8),
                    child: Text(_passwordError!, style: TextStyle(color: cs.error, fontSize: 12)),
                  ),
                const SizedBox(height: 28),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: cs.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.error.withValues(alpha: 0.18)),
                      ),
                      child: Text(_errorMessage!, style: TextStyle(color: cs.error)),
                    ),
                  ),
                VitalisButton(
                  label: 'Sign in',
                  isLoading: _isLoading,
                  onPressed: _signIn,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
