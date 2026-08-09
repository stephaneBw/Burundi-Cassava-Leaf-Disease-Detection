// Provides the search input used to filter library records.

import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';

class LibrarySearchField extends StatelessWidget {
  const LibrarySearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 95, bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge,
        cursorColor: theme.primaryColor,
        decoration: InputDecoration(
          hintText: l10n.lblSearch,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: theme.iconTheme.color),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
