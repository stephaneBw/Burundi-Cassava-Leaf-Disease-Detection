// Provides a reusable circular icon action button.

import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  const CircularIconButton({super.key, required this.icon, this.onPressed, this.tooltip});
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
        : theme.colorScheme.surface.withValues(alpha: 0.9);

    final iconColor = theme.colorScheme.onSurface;

    Widget button = DecoratedBox(
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
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 40,
            child: Center(child: Icon(icon, color: iconColor, size: 22)),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: button);
  }
}
