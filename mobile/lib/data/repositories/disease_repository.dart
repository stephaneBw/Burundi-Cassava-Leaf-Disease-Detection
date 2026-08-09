// Provides query and lookup access to disease library records.

import '../models/disease_model.dart';

class DiseaseRepository {
  // Keep this registry aligned with the trained PlantVillage label set.
  static const List<DiseaseModel> _diseases = [
    DiseaseModel(id: '1', localizationKey: 'dsAppleScab'),
    DiseaseModel(id: '2', localizationKey: 'dsAppleBlackRot'),
    DiseaseModel(id: '3', localizationKey: 'dsAppleCedarRust'),
    DiseaseModel(id: '4', localizationKey: 'dsCherryPowderyMildew'),
    DiseaseModel(id: '5', localizationKey: 'dsCornCercospora'),
    DiseaseModel(id: '6', localizationKey: 'dsCornCommonRust'),
    DiseaseModel(id: '7', localizationKey: 'dsCornNorthernBlight'),
    DiseaseModel(id: '8', localizationKey: 'dsGrapeBlackRot'),
    DiseaseModel(id: '9', localizationKey: 'dsGrapeEsca'),
    DiseaseModel(id: '10', localizationKey: 'dsGrapeLeafBlight'),
    DiseaseModel(id: '11', localizationKey: 'dsOrangeHLB'),
    DiseaseModel(id: '12', localizationKey: 'dsPeachBacterialSpot'),
    DiseaseModel(id: '13', localizationKey: 'dsPepperBacterialSpot'),
    DiseaseModel(id: '14', localizationKey: 'dsPotatoEarlyBlight'),
    DiseaseModel(id: '15', localizationKey: 'dsPotatoLateBlight'),
    DiseaseModel(id: '16', localizationKey: 'dsSquashPowderyMildew'),
    DiseaseModel(id: '17', localizationKey: 'dsStrawberryLeafScorch'),
    DiseaseModel(id: '18', localizationKey: 'dsTomatoBacterialSpot'),
    DiseaseModel(id: '19', localizationKey: 'dsTomatoEarlyBlight'),
    DiseaseModel(id: '20', localizationKey: 'dsTomatoLateBlight'),
    DiseaseModel(id: '21', localizationKey: 'dsTomatoLeafMold'),
    DiseaseModel(id: '22', localizationKey: 'dsTomatoSeptoria'),
    DiseaseModel(id: '23', localizationKey: 'dsTomatoSpiderMites'),
    DiseaseModel(id: '24', localizationKey: 'dsTomatoTargetSpot'),
    DiseaseModel(id: '25', localizationKey: 'dsTomatoYellowCurl'),
    DiseaseModel(id: '26', localizationKey: 'dsTomatoMosaic'),
    DiseaseModel(id: '27', localizationKey: 'dsAppleHealthy'),
    DiseaseModel(id: '28', localizationKey: 'dsBlueberryHealthy'),
    DiseaseModel(id: '29', localizationKey: 'dsCherryHealthy'),
    DiseaseModel(id: '30', localizationKey: 'dsCornHealthy'),
    DiseaseModel(id: '31', localizationKey: 'dsGrapeHealthy'),
    DiseaseModel(id: '32', localizationKey: 'dsPeachHealthy'),
    DiseaseModel(id: '33', localizationKey: 'dsPepperHealthy'),
    DiseaseModel(id: '34', localizationKey: 'dsPotatoHealthy'),
    DiseaseModel(id: '35', localizationKey: 'dsRaspberryHealthy'),
    DiseaseModel(id: '36', localizationKey: 'dsSoybeanHealthy'),
    DiseaseModel(id: '37', localizationKey: 'dsStrawberryHealthy'),
    DiseaseModel(id: '38', localizationKey: 'dsTomatoHealthy'),
  ];

  List<DiseaseModel> getAllDiseases() => List.unmodifiable(_diseases);
}
