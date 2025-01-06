// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../services/analytics_service.dart';
import '../services/app_locale_service.dart';
import '../services/cloud_service.dart';
import '../services/database_service.dart';
import '../services/file_saver_service.dart';
import '../services/file_service.dart';
import '../services/logger_service.dart';
import '../services/outcome_measure_load_service.dart';
import '../services/outcome_measure_selection_service.dart';
import '../services/package_info_service.dart';
import '../services/pdf_service.dart';
import '../services/shared_preferences_service.dart';
import '../services/tts_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => BiotService());
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => SharedPreferencesService());
  locator.registerLazySingleton(() => PackageInfoService());
  locator.registerLazySingleton(() => FileService());
  locator.registerLazySingleton(() => OutcomeMeasureLoadService());
  locator.registerLazySingleton(() => AppLocaleService());
  locator.registerLazySingleton(() => OutcomeMeasureSelectionService());
  locator.registerLazySingleton(() => TtsService());
  locator.registerLazySingleton(() => PdfService());
  locator.registerLazySingleton(() => FileSaverService());
  locator.registerLazySingleton(() => LoggerService());
  locator.registerLazySingleton(() => AnalyticsService());
}
