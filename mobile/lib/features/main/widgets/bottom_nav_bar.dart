// Renders the primary bottom navigation bar for app sections.

import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      height: 55,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_rounded, 0),
          _buildNavItem(context, Icons.local_florist_rounded, 1),
          // Reserve the notch area for the centered camera action.
          const SizedBox(width: 48),
          _buildNavItem(context, Icons.history_rounded, 2),
          _buildNavItem(context, Icons.settings_rounded, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    final isSelected = currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onTap(index),
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          icon,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.4),
          size: 26,
        ),
      ),
    );
  }
}
