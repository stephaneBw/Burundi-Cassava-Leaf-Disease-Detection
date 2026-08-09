// Represents a persisted diagnosis scan history record.

class ScanHistoryModel {
  const ScanHistoryModel({
    required this.id,
    required this.imagePath,
    required this.diseaseId,
    required this.confidence,
    required this.date,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      diseaseId: json['diseaseId'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
  final String id;
  final String imagePath;
  final String diseaseId;
  final double confidence;
  final DateTime date;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'diseaseId': diseaseId,
      'confidence': confidence,
      'date': date.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ScanHistoryModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            imagePath == other.imagePath &&
            diseaseId == other.diseaseId &&
            confidence == other.confidence &&
            date == other.date;
  }

  @override
  int get hashCode => Object.hash(id, imagePath, diseaseId, confidence, date);
}
