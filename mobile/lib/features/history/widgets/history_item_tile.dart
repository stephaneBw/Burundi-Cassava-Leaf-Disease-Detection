// Renders a single diagnosis history entry and its actions.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/disease_label_mapper.dart';
import '../../../data/models/scan_history_model.dart';
import '../../../services/media/media_service.dart';

class HistoryItemTile extends StatelessWidget {
  const HistoryItemTile({super.key, required this.item, required this.onTap});
  final ScanHistoryModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final localizedLabel = DiseaseLabelMapper.getLocalizedLabel(context, item.diseaseId);

    final dateStr = DateFormat.yMMMMd(locale).format(item.date);
    final timeStr = DateFormat.Hm(locale).format(item.date);

    final confidencePercent = (item.confidence * 100).toStringAsFixed(1);

    final imageFile = getIt<MediaService>().getFileFromStorage(item.imagePath);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageFile,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizedLabel,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateStr - $timeStr',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getConfidenceColor(item.confidence).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '%$confidencePercent',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _getConfidenceColor(item.confidence),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (!item.diseaseId.toLowerCase().contains('healthy'))
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF2E7D32);
    if (confidence >= 0.5) return const Color(0xFFF57C00);
    return const Color(0xFFD32F2F);
  }
}
