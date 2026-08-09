// Hosts the main tab scaffold and mobile background composition.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../services/media/media_service.dart';
import '../../diagnosis/controllers/diagnosis_controller.dart';
import '../../diagnosis/screens/diagnosis_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../library/screens/library_wrapper.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../settings/screens/settings_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key, required this.settingsController});
  final SettingsController settingsController;

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _currentIndex = 0;
  final MediaService _mediaService = getIt<MediaService>();
  final DiagnosisController _diagnosisController = getIt<DiagnosisController>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DiagnosisScreen(controller: _diagnosisController),
      const LibraryWrapper(),
      const HistoryScreen(),
      SettingsScreen(controller: widget.settingsController),
    ];
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    final File? image = await _mediaService.pickImage(source);
    if (image != null) {
      setState(() => _currentIndex = 0);
      _diagnosisController.analyzeImage(image);
    }
  }

  void _showSourceModal() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: Text(l10n.lblCamera),
              onTap: () {
                Navigator.pop(context);
                _handleImageSelection(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: Text(l10n.lblGallery),
              onTap: () {
                Navigator.pop(context);
                _handleImageSelection(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // Keep tab state alive while switching sections.
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSourceModal,
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex, onTap: _onTabTapped),
    );
  }
}
