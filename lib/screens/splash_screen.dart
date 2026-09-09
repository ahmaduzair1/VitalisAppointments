import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  /// When true, this is only a loading view (no navigation).
  final bool hold;

  const SplashScreen({super.key, this.hold = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary,
                    cs.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: cs.onPrimary,
                size: 56,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.4, 0.4),
                  end: const Offset(1.0, 1.0),
                  duration: 700.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 500.ms),
            const SizedBox(height: 32),
            Text(
              'Vitalis',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: cs.primary,
                letterSpacing: -0.5,
              ),
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 500.ms),
            const SizedBox(height: 8),
            Text(
              'Care that feels simple',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ).animate(delay: 700.ms).fadeIn(duration: 500.ms),
            if (hold) ...[
              const SizedBox(height: 28),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: cs.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
