// Provides a reusable circular back navigation button.

import 'package:flutter/material.dart';

class CircularBackButton extends StatelessWidget {
  const CircularBackButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
        : theme.colorScheme.surface.withValues(alpha: 0.9);

    final iconColor = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: bgColor,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed ?? () => Navigator.maybePop(context),
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: 44,
              child: Center(child: Icon(Icons.arrow_back_rounded, color: iconColor, size: 22)),
            ),
          ),
        ),
      ),
    );
  }
}
