// Renders the bottom sheet used to filter scan history records.

import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/models/history_filter_model.dart';
import '../controllers/history_controller.dart';

class HistoryFilterSheet extends StatefulWidget {
  const HistoryFilterSheet({super.key, required this.controller});
  final HistoryController controller;

  @override
  State<HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends State<HistoryFilterSheet> {
  late HistoryFilterModel _tempFilter;
  late Set<String> _availablePlants;

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.controller.filter;
    _availablePlants = widget.controller.getAvailablePlants();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filterTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempFilter = const HistoryFilterModel();
                    });
                  },
                  child: Text(l10n.filterReset),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                _buildExpansionSection(
                  context: context,
                  title: l10n.filterDate,
                  icon: Icons.calendar_today_rounded,
                  initiallyExpanded: false,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: DateFilter.values.map((filter) {
                        return ChoiceChip(
                          label: Text(_getDateFilterLabel(filter, l10n)),
                          selected: _tempFilter.dateFilter == filter,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(dateFilter: filter);
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                _buildExpansionSection(
                  context: context,
                  title: l10n.filterStatus,
                  icon: Icons.health_and_safety_rounded,
                  initiallyExpanded: false,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: HealthStatusFilter.values.map((filter) {
                        return ChoiceChip(
                          label: Text(_getHealthFilterLabel(filter, l10n)),
                          selected: _tempFilter.healthFilter == filter,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(healthFilter: filter);
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (_availablePlants.isNotEmpty)
                  _buildExpansionSection(
                    context: context,
                    title: l10n.filterPlants,
                    icon: Icons.local_florist_rounded,
                    initiallyExpanded: false,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availablePlants.map((plantKey) {
                          final isSelected = _tempFilter.selectedPlants.contains(plantKey);
                          return FilterChip(
                            label: Text(_getPlantNameLocalized(plantKey, l10n)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                final newSet = Set<String>.from(_tempFilter.selectedPlants);
                                if (selected) {
                                  newSet.add(plantKey);
                                } else {
                                  newSet.remove(plantKey);
                                }
                                _tempFilter = _tempFilter.copyWith(selectedPlants: newSet);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.controller.updateFilter(_tempFilter);
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.filterApply),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  String _getDateFilterLabel(DateFilter filter, AppLocalizations l10n) {
    switch (filter) {
      case DateFilter.last15Minutes:
        return l10n.filterLast15Min;
      case DateFilter.lastHour:
        return l10n.filterLast1Hour;
      case DateFilter.last24Hours:
        return l10n.filterLast24Hours;
      case DateFilter.lastWeek:
        return l10n.filterLast7Days;
      case DateFilter.lastMonth:
        return l10n.filterLast30Days;
      case DateFilter.allTime:
        return l10n.filterAllTime;
    }
  }

  String _getHealthFilterLabel(HealthStatusFilter filter, AppLocalizations l10n) {
    switch (filter) {
      case HealthStatusFilter.all:
        return l10n.filterAllStatus;
      case HealthStatusFilter.healthy:
        return l10n.filterHealthyOnly;
      case HealthStatusFilter.infected:
        return l10n.filterInfectedOnly;
    }
  }

  String _getPlantNameLocalized(String key, AppLocalizations l10n) {
    // History stores raw PlantVillage plant names; filters display localized names.
    final map = {
      'Apple': l10n.plantApple,
      'Blueberry': l10n.plantBlueberry,
      'Cherry (including sour)': l10n.plantCherry,
      'Corn (maize)': l10n.plantCorn,
      'Grape': l10n.plantGrape,
      'Orange': l10n.plantOrange,
      'Peach': l10n.plantPeach,
      'Pepper, bell': l10n.plantPepper,
      'Potato': l10n.plantPotato,
      'Raspberry': l10n.plantRaspberry,
      'Soybean': l10n.plantSoybean,
      'Squash': l10n.plantSquash,
      'Strawberry': l10n.plantStrawberry,
      'Tomato': l10n.plantTomato,
    };
    return map[key] ?? key;
  }
}
