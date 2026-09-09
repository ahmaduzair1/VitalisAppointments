import 'package:flutter/material.dart';

/// Network photo with a person fallback when the URL fails (CORS, 404, offline).
class NetworkAvatar extends StatelessWidget {
  final String url;
  final double size;
  final double radius;
  final BoxFit fit;

  const NetworkAvatar({
    super.key,
    required this.url,
    this.size = 80,
    this.radius = 24,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (url.isEmpty) return _fallback(cs);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _fallback(cs),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: size,
            height: size,
            child: ColoredBox(
              color: cs.onSurfaceVariant.withValues(alpha: 0.08),
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _fallback(ColorScheme cs) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: cs.primary.withValues(alpha: 0.1),
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * 0.5,
        color: cs.primary.withValues(alpha: 0.6),
      ),
    );
  }
}
