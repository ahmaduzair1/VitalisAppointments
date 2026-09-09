import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Network or Firestore-stored photo, with a person fallback.
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

  static bool isPlaceholderUrl(String value) {
    final u = value.toLowerCase();
    return u.contains('randomuser.me') || u.contains('pravatar.cc');
  }

  static (String, String)? parseStoredRef(String value) {
    final match = RegExp(r'^fs:(profile|doctor):([A-Za-z0-9_-]{1,128})$')
        .firstMatch(value.trim());
    if (match == null) return null;
    final kind = match.group(1)!;
    final id = match.group(2)!;
    final collection = kind == 'profile' ? 'profilePhotos' : 'doctorPhotos';
    return (collection, id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safe = isPlaceholderUrl(url) ? '' : url;
    if (safe.isEmpty) return _fallback(cs);

    final stored = parseStoredRef(safe);
    if (stored != null) {
      return _FirestoreAvatar(
        collection: stored.$1,
        id: stored.$2,
        size: size,
        radius: radius,
        fit: fit,
        fallback: _fallback(cs),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        safe,
        width: size,
        height: size,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _fallback(cs),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _loading(cs);
        },
      ),
    );
  }

  Widget _loading(ColorScheme cs) {
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

class _FirestoreAvatar extends StatelessWidget {
  final String collection;
  final String id;
  final double size;
  final double radius;
  final BoxFit fit;
  final Widget fallback;

  const _FirestoreAvatar({
    required this.collection,
    required this.id,
    required this.size,
    required this.radius,
    required this.fit,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(collection).doc(id).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final encoded = data?['bytes'] as String?;
        if (encoded == null || encoded.isEmpty) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: size,
              height: size,
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return fallback;
        }
        try {
          final bytes = base64Decode(encoded);
          return ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: fit,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) => fallback,
            ),
          );
        } catch (_) {
          return fallback;
        }
      },
    );
  }
}
