// Displays the searchable disease library list.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/disease_label_mapper.dart';
import '../../../../data/models/disease_model.dart';
import '../../../../data/repositories/disease_repository.dart';
import '../widgets/disease_tile.dart';
import '../widgets/library_search_field.dart';
import 'disease_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final DiseaseRepository _repository = getIt<DiseaseRepository>();
  final TextEditingController _searchController = TextEditingController();

  List<DiseaseModel> _allDiseases = [];
  List<DiseaseModel> _filteredDiseases = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _allDiseases = _repository.getAllDiseases();
    _filteredDiseases = List.from(_allDiseases);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Localized names can change when the active locale changes.
    _sortDiseases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _sortDiseases() {
    _filteredDiseases.sort((a, b) {
      final nameA = DiseaseLabelMapper.getLocalizedLabel(context, a.localizationKey);
      final nameB = DiseaseLabelMapper.getLocalizedLabel(context, b.localizationKey);
      return nameA.compareTo(nameB);
    });
  }

  void _filterDiseases(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredDiseases = List.from(_allDiseases);
      } else {
        _filteredDiseases = _allDiseases.where((disease) {
          final name = DiseaseLabelMapper.getLocalizedLabel(context, disease.localizationKey);
          return name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      _sortDiseases();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Image.asset(
            AppAssets.bgLibrary,
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                LibrarySearchField(
                  controller: _searchController,
                  onChanged: _filterDiseases,
                  onClear: () {
                    _searchController.clear();
                    _filterDiseases('');
                    FocusScope.of(context).unfocus();
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    itemCount: _filteredDiseases.length,
                    itemBuilder: (context, index) {
                      final disease = _filteredDiseases[index];
                      final name = DiseaseLabelMapper.getLocalizedLabel(
                        context,
                        disease.localizationKey,
                      );

                      return DiseaseTile(
                        disease: disease,
                        localizedName: name,
                        backgroundColor: _isSearching
                            ? AppColors.primary.withValues(alpha: 0.9)
                            : null,
                        onTap: () {
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => DiseaseDetailScreen(
                                diseaseName: name,
                                diseaseId: disease.localizationKey,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Leave visual space for the foreground reading character.
                SizedBox(height: size.height * 0.275),
              ],
            ),
          ),
          Positioned(
            left: -50,
            bottom: -20,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -0.01,
                child: Image.asset(
                  AppAssets.farmerReading,
                  width: size.width * 0.85,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
