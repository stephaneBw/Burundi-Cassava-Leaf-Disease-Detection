// Represents localized disease detail content shown in the library.

class DiseaseDetailModel {
  const DiseaseDetailModel({
    required this.id,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
  });
  final String id;
  final List<String> symptoms;
  final List<String> treatment;
  final List<String> prevention;
}
