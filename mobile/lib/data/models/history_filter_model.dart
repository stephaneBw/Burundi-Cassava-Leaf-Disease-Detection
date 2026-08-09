// Models the scan history filters available to the user.

enum DateFilter { last15Minutes, lastHour, last24Hours, lastWeek, lastMonth, allTime }

enum HealthStatusFilter { all, healthy, infected }

class HistoryFilterModel {
  const HistoryFilterModel({
    this.dateFilter = DateFilter.allTime,
    this.healthFilter = HealthStatusFilter.all,
    this.selectedPlants = const {},
  });
  final DateFilter dateFilter;
  final HealthStatusFilter healthFilter;
  final Set<String> selectedPlants;

  HistoryFilterModel copyWith({
    DateFilter? dateFilter,
    HealthStatusFilter? healthFilter,
    Set<String>? selectedPlants,
  }) {
    return HistoryFilterModel(
      dateFilter: dateFilter ?? this.dateFilter,
      healthFilter: healthFilter ?? this.healthFilter,
      selectedPlants: selectedPlants ?? this.selectedPlants,
    );
  }
}
