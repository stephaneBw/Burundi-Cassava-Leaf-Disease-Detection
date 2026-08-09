// Renders the farmer assistant message bubble used in diagnosis screens.

import 'package:flutter/material.dart';
import '../../../../core/constants/layout_constants.dart';
import 'triangle_painter.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    this.title,
    required this.message,
    this.action,
    this.animationDurationMs = LayoutConstants.textAnimationMs,
  });
  final String? title;
  final String message;
  final Widget? action;
  final int animationDurationMs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = theme.colorScheme.surface.withValues(alpha: 0.95);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(LayoutConstants.verticalPadding),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              AnimatedSwitcher(
                duration: Duration(milliseconds: animationDurationMs),
                child: Text(
                  message,
                  key: ValueKey<String>(message),
                  style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              if (action != null) ...[action!],
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -1),
          child: CustomPaint(
            size: const Size(30, 20),
            painter: TrianglePainter(color: bubbleColor),
          ),
        ),
      ],
    );
  }
}
