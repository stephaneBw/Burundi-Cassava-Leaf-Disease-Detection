// Renders a disease library tile with plant and disease metadata.

import 'package:flutter/material.dart';
import '../../../data/models/disease_model.dart';

class DiseaseTile extends StatelessWidget {
  const DiseaseTile({
    super.key,
    required this.disease,
    required this.localizedName,
    required this.onTap,
    this.backgroundColor,
  });
  final DiseaseModel disease;
  final String localizedName;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustomBackground = backgroundColor != null;
    final accentColor = _accentColorFor(disease.localizationKey);

    final textColor = isCustomBackground ? Colors.white : theme.textTheme.titleMedium?.color;

    final iconColor = isCustomBackground ? Colors.white : accentColor;

    final iconBoxColor = isCustomBackground
        ? Colors.white.withValues(alpha: 0.2)
        : accentColor.withValues(alpha: 0.15);

    final arrowColor = isCustomBackground
        ? Colors.white70
        : theme.iconTheme.color?.withValues(alpha: 0.5);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBoxColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _initialsFor(localizedName),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    localizedName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: arrowColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _accentColorFor(String value) {
    const colors = [
      Color(0xFF2E7D32),
      Color(0xFF1565C0),
      Color(0xFF6A1B9A),
      Color(0xFFAD6800),
      Color(0xFF00838F),
      Color(0xFFC62828),
    ];
    final index = value.codeUnits.fold<int>(0, (sum, codeUnit) => sum + codeUnit);
    return colors[index % colors.length];
  }

  String _initialsFor(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .toList();
    if (words.isEmpty) return '?';
    return words.map((word) => String.fromCharCode(word.runes.first).toUpperCase()).join();
  }
}
