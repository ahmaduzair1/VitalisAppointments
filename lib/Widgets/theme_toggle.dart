import 'package:flutter/material.dart';
import '../main.dart';

/// Animated sun/moon toggle for switching between light and dark themes.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: VitalisApp.themeNotifier,
      builder: (context, currentMode, child) {
        final effectiveDarkMode = currentMode == ThemeMode.dark ||
            (currentMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return GestureDetector(
          onTap: () {
            if (effectiveDarkMode) {
              VitalisApp.themeNotifier.value = ThemeMode.light;
            } else {
              VitalisApp.themeNotifier.value = ThemeMode.dark;
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: 64,
            height: 34,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: effectiveDarkMode
                  ? colorScheme.primary.withAlpha(51)
                  : colorScheme.outline.withAlpha(26),
              border: Border.all(
                color: effectiveDarkMode
                    ? colorScheme.primary.withAlpha(102)
                    : colorScheme.outline.withAlpha(77),
                width: 1,
              ),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: effectiveDarkMode ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(64),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    effectiveDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    key: ValueKey(effectiveDarkMode),
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
