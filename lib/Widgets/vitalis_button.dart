import 'package:flutter/material.dart';

/// A premium button with press-scale animation and loading state.
enum VitalisButtonVariant { primary, secondary, text }

class VitalisButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final VitalisButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const VitalisButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = VitalisButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56,
  });

  @override
  State<VitalisButton> createState() => _VitalisButtonState();
}

class _VitalisButtonState extends State<VitalisButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bool isPrimary = widget.variant == VitalisButtonVariant.primary;

    Widget buttonChild = widget.isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPrimary ? cs.onPrimary : cs.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? cs.onPrimary : cs.onSurface,
                ),
              ),
            ],
          );

    Widget button;
    switch (widget.variant) {
      case VitalisButtonVariant.primary:
        button = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(widget.width ?? double.infinity, widget.height),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: buttonChild,
          ),
        );
      case VitalisButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(widget.width ?? double.infinity, widget.height),
            side: BorderSide(color: cs.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: buttonChild,
        );
      case VitalisButtonVariant.text:
        button = TextButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          child: buttonChild,
        );
    }

    return GestureDetector(
      onTapDown:
          widget.onPressed != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onPressed != null ? (_) => _controller.reverse() : null,
      onTapCancel:
          widget.onPressed != null ? () => _controller.reverse() : null,
      child: ScaleTransition(scale: _scaleAnimation, child: button),
    );
  }
}
