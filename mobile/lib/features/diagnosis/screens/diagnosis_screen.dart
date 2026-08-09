// Presents the camera/gallery diagnosis flow and analysis result state.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/disease_label_mapper.dart';
import '../../library/screens/disease_detail_screen.dart';
import '../controllers/diagnosis_controller.dart';
import '../widgets/message_bubble.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key, required this.controller});
  final DiagnosisController controller;

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.farmerGreet), context);
    precacheImage(const AssetImage(AppAssets.farmerDiagnosis), context);
    precacheImage(const AssetImage(AppAssets.farmerResult), context);
    precacheImage(const AssetImage(AppAssets.farmerReading), context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final bgImage = theme.brightness == Brightness.dark ? AppAssets.bgDark : AppAssets.bgLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return Stack(
            children: [
              _buildBackground(size, bgImage),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: _buildFarmerImage(size.height, widget.controller),
                ),
              ),

              Positioned(
                bottom: size.height * LayoutConstants.bottomPanelHeight,
                left: LayoutConstants.horizontalPadding,
                right: LayoutConstants.horizontalPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMessageBubble(context, widget.controller),
                    if (widget.controller.status == DiagnosisStatus.greeting) ...[
                      const SizedBox(height: 8),
                      _buildActionButtons(context, widget.controller),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground(Size size, String bgImage) {
    return SizedBox.expand(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: LayoutConstants.bgAnimationDurationMs),
        child: Image.asset(
          bgImage,
          key: ValueKey<String>(bgImage),
          fit: BoxFit.cover,
          width: size.width,
          height: size.height,
        ),
      ),
    );
  }

  Widget _buildFarmerImage(double screenHeight, DiagnosisController controller) {
    String imagePath;
    Offset offset = Offset.zero;

    if (controller.customBubbleMessage != null) {
      imagePath = AppAssets.farmerResult;
      offset = const Offset(-5, 0);
    } else {
      switch (controller.status) {
        case DiagnosisStatus.greeting:
        case DiagnosisStatus.error:
          imagePath = AppAssets.farmerGreet;
          offset = const Offset(-5, 0);
          break;
        case DiagnosisStatus.analyzing:
          imagePath = AppAssets.farmerDiagnosis;
          offset = Offset.zero;
          break;
        case DiagnosisStatus.result:
          imagePath = AppAssets.farmerResult;
          offset = const Offset(-5, 0);
          break;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: LayoutConstants.characterAnimationMs),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(offset.dx, offset.dy, 0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: LayoutConstants.characterAnimationMs),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
              child: child,
            ),
          );
        },
        child: Image.asset(
          imagePath,
          key: ValueKey<String>(imagePath),
          height: screenHeight * LayoutConstants.avatarHeight,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, DiagnosisController controller) {
    final l10n = AppLocalizations.of(context)!;
    String? title;
    String message = '';
    Widget? actionButton;

    if (controller.customBubbleMessage != null) {
      title = controller.customBubbleTitle;
      message = controller.customBubbleMessage!;
    } else {
      switch (controller.status) {
        case DiagnosisStatus.greeting:
          title = l10n.farmerGreetingTitle;
          message = l10n.farmerGreetingBody;
          break;
        case DiagnosisStatus.analyzing:
          message = l10n.farmerAnalyzingBody;
          break;
        case DiagnosisStatus.result:
          final topResult = controller.topResult!;
          final confidenceVal = (topResult['confidence'] as double) * 100;
          final rawLabel = topResult['label'].toString();
          final label = DiseaseLabelMapper.getLocalizedLabel(context, rawLabel);

          final isHealthy = rawLabel.toLowerCase().contains('healthy');

          if (isHealthy) {
            message = l10n.farmerResultHealthy(confidenceVal.toStringAsFixed(1));
          } else {
            message = l10n.farmerResultSuccess(confidenceVal.toStringAsFixed(1), label);

            actionButton = Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                height: 40,
                child: FilledButton.icon(
                  onPressed: () {
                    final jsonKey = DiseaseLabelMapper.getJsonKey(rawLabel);
                    if (jsonKey != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              DiseaseDetailScreen(diseaseName: label, diseaseId: jsonKey),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: Text(l10n.btnViewInLibrary),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            );
          }
          break;
        case DiagnosisStatus.error:
          message = l10n.farmerErrorBody;
          break;
      }
    }

    return MessageBubble(title: title, message: message, action: actionButton);
  }

  Widget _buildActionButtons(BuildContext context, DiagnosisController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          context,
          l10n.btnQuestionHow,
          () => controller.updateBubbleMessage(l10n.ansQuestionHow, title: null),
        ),
        const SizedBox(height: 6),
        _buildActionButton(
          context,
          l10n.btnQuestionPlants,
          () => controller.updateBubbleMessage(l10n.ansQuestionPlants, title: null),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, VoidCallback onPressed) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black54 : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
