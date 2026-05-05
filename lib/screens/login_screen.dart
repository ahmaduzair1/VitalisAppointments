import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/page_transitions.dart';
import '../widgets/vitalis_button.dart';
import '../services/auth_service.dart';
import 'main_tab_navigator.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  // ── Forgot Password Dialog Logic ────────────────────────
  Future<void> _showForgotPasswordDialog() async {
    final resetEmailController = TextEditingController(text: _emailController.text);
    bool isResetLoading = false;
    String? resetMessage;
    bool isError = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final cs = Theme.of(context).colorScheme;

            return AlertDialog(
              backgroundColor: cs.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Reset Password',
                style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter your email address and we will send you a link to reset your password.',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(14),
                      border: Theme.of(context).brightness == Brightness.dark
                          ? Border.all(color: cs.outline.withOpacity(0.3))
                          : null,
                    ),
                    child: TextField(
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: cs.onSurface),
                      decoration: InputDecoration(
                        hintText: 'name@vitalis.com',
                        hintStyle: TextStyle(color: cs.onSurfaceVariant),
                        prefixIcon: Icon(Icons.mail_outline_rounded, color: cs.onSurfaceVariant, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  if (resetMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      resetMessage!,
                      style: TextStyle(
                        color: isError ? cs.error : Colors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]
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
                    if (email.isEmpty || !email.contains('@')) {
                      setDialogState(() {
                        isError = true;
                        resetMessage = "Please enter a valid email.";
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
                        resetMessage = "Reset link sent! Check your inbox/spam.";
                      });
                    } catch (e) {
                      setDialogState(() {
                        isResetLoading = false;
                        isError = true;
                        resetMessage = e.toString().replaceAll('Exception: ', '');
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isResetLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Send Link'),
                ),
              ],
            );
          },
        );
      },
    );
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
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -1.0,
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
                      height: 1.6,
                    ),
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 40),

                // ── Email field ───────────────────────────
                _buildLabel('Email Address'),
                const SizedBox(height: 8),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: theme.brightness == Brightness.dark
                        ? Border.all(color: cs.outline.withOpacity(0.3))
                        : null,
                    boxShadow: theme.brightness == Brightness.light
                        ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: cs.onSurface, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'name@vitalis.com',
                        hintStyle: TextStyle(color: cs.onSurfaceVariant),
                        prefixIcon: Icon(Icons.mail_outline_rounded,
                            color: cs.onSurfaceVariant, size: 20),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                ),
                if (_emailError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: Text(_emailError!, style: TextStyle(color: cs.error, fontSize: 12)),
                  ),

                const SizedBox(height: 20),

                // ── Password field ────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Password'),
                    GestureDetector(
                      onTap: _showForgotPasswordDialog,
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
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: theme.brightness == Brightness.dark
                        ? Border.all(color: cs.outline.withOpacity(0.3))
                        : null,
                    boxShadow: theme.brightness == Brightness.light
                        ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: cs.onSurface, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: cs.onSurfaceVariant),
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
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                ),
                if (_passwordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: Text(_passwordError!, style: TextStyle(color: cs.error, fontSize: 12)),
                  ),

                const SizedBox(height: 32),

                // ── Backend Error Message ─────────────────
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error.withOpacity(0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Sign In button ────────────────────────
                VitalisButton(
                  label: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: () async {
                    if (!_validateForm()) return;

                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });

                    try {
                      await _authService.signInWithEmailPassword(
                          _emailController.text.trim(),
                          _passwordController.text.trim()
                      );

                      if (!mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        PageTransitions.fadeSlide(const MainTabNavigator()),
                            (route) => false,
                      );
                    } catch (e) {
                      if (!mounted) return;
                      setState(() {
                        _errorMessage = e.toString().replaceAll('Exception: ', '');
                        _isLoading = false;
                      });
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
                // UPDATED: Now actually hooks up to your AuthService for Google Auth!
                VitalisButton(
                  label: 'Continue with Google',
                  variant: VitalisButtonVariant.secondary,
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });

                    try {
                      final user = await _authService.signInWithGoogle();
                      if (!mounted) return;

                      if (user != null) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          PageTransitions.fadeSlide(const MainTabNavigator()),
                              (route) => false,
                        );
                      } else {
                        // User canceled the sign in popup
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    } catch (e) {
                      if (!mounted) return;
                      setState(() {
                        _errorMessage = "Google Sign-In failed. Check configuration.";
                        _isLoading = false;
                      });
                    }
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