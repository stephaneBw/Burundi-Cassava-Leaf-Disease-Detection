// Presents user-facing theme and language settings.

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsTitle), centerTitle: true),
          body: ListView(
            children: [
              _buildSectionHeader(context, l10n.settingsGeneral),
              _buildLanguageOption(context, l10n),
              _buildThemeOption(context, l10n),
              const Divider(),
              _buildSectionHeader(context, l10n.settingsAbout),
              _buildVersionInfo(l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.settingsLanguage),
      subtitle: Text(controller.locale?.languageCode == 'tr' ? l10n.langTurkish : l10n.langEnglish),
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(l10n.settingsLanguage),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  controller.updateLocale(const Locale('en'));
                  Navigator.pop(context);
                },
                child: Text(l10n.langEnglish),
              ),
              SimpleDialogOption(
                onPressed: () {
                  controller.updateLocale(const Locale('tr'));
                  Navigator.pop(context);
                },
                child: Text(l10n.langTurkish),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: Text(l10n.settingsTheme),
      subtitle: Text(_getThemeName(controller.themeMode, l10n)),
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(l10n.settingsTheme),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  controller.updateThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
                child: Text(l10n.themeSystem),
              ),
              SimpleDialogOption(
                onPressed: () {
                  controller.updateThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
                child: Text(l10n.themeLight),
              ),
              SimpleDialogOption(
                onPressed: () {
                  controller.updateThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
                child: Text(l10n.themeDark),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVersionInfo(AppLocalizations l10n) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final version = snapshot.data!.version;
        final buildNumber = snapshot.data!.buildNumber;
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.settingsVersion),
          subtitle: Text('$version ($buildNumber)'),
        );
      },
    );
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.themeSystem;
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
    }
  }
}
