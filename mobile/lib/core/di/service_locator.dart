// Registers application services, repositories, and controllers.

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/disease_repository.dart';
import '../../data/repositories/history_repository.dart';
import '../../features/diagnosis/controllers/diagnosis_controller.dart';
import '../../features/history/controllers/history_controller.dart';
import '../../features/settings/controllers/settings_controller.dart';
import '../../services/ai/classifier_service.dart';
import '../../services/media/media_service.dart';
import '../../services/storage/preferences_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  final mediaService = MediaService();
  await mediaService.initialize();
  getIt.registerSingleton<MediaService>(mediaService);

  // Register lazy services behind interfaces/controllers that consume them.
  getIt.registerLazySingleton<PreferencesService>(
    () => PreferencesService(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<ClassifierService>(() => ClassifierService());
  getIt.registerLazySingleton<DiseaseRepository>(() => DiseaseRepository());
  getIt.registerLazySingleton<HistoryRepository>(() => HistoryRepository(getIt()));

  getIt.registerLazySingleton<HistoryController>(
    () => HistoryController(getIt<HistoryRepository>(), getIt<MediaService>()),
  );

  getIt.registerLazySingleton<DiagnosisController>(
    () => DiagnosisController(
      getIt<ClassifierService>(),
      getIt<HistoryController>(),
      getIt<MediaService>(),
    ),
  );

  final settingsController = SettingsController(getIt<PreferencesService>());
  await settingsController.loadSettings();
  getIt.registerSingleton<SettingsController>(settingsController);
}
