import 'package:biot/model/amputation.dart';
import 'package:biot/model/condition.dart';
import 'package:biot/model/domain_weight_distribution.dart';
import 'package:biot/model/encounter.dart';
import 'package:biot/model/episode_of_care.dart';
import 'package:biot/model/kLevel.dart';
import 'package:biot/model/outcome_measures/outcome_measure.dart';
import 'package:biot/model/patient.dart';
import 'package:biot/model/pre_post_episode_of_care.dart';
import 'package:biot/model/socket_info.dart';
import 'package:biot/services/app_locale_service.dart';
import 'package:biot/services/outcome_measure_load_service.dart';
import 'package:biot/ui/views/amputation_form/amputation_form_viewmodel.dart';
import 'package:biot/ui/views/patient/patient_viewmodel.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:biot/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:biot/services/cloud_service.dart';
import 'package:biot/services/database_service.dart';
import 'package:biot/services/shared_preferences_service.dart';
import 'package:biot/services/package_info_service.dart';
import 'package:biot/services/file_service.dart';
import 'package:biot/services/outcome_measure_selection_service.dart';
import 'package:biot/services/pdf_service.dart';
import 'package:biot/services/file_saver_service.dart';
import 'package:biot/services/logger_service.dart';
import 'package:biot/services/analytics_service.dart';
import 'package:http/http.dart' as http;

// @stacked-import

import 'test_helpers.mocks.dart';

@GenerateMocks([
  OutcomeMeasure,
  http.Client,
  Encounter,
  Patient,
  DomainWeightDistribution,
  Condition,
  KLevel,
  Amputation,
  SocketInfo,
  PrePostEpisodeOfCare,
  EpisodeOfCare,
  AmputationFormViewModel,
  PatientViewModel,
  HiveInterface,
  Box
], customMocks: [
  MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<BottomSheetService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<DialogService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<BiotService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<DatabaseService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<SharedPreferencesService>(
      onMissingStub: OnMissingStub.returnDefault),
  MockSpec<PackageInfoService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<FileService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<OutcomeMeasureSelectionService>(
      onMissingStub: OnMissingStub.returnDefault),
  MockSpec<OutcomeMeasureLoadService>(
      onMissingStub: OnMissingStub.returnDefault),
  MockSpec<PdfService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<FileSaverService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<AppLocaleService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<LoggerService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<AnalyticsService>(onMissingStub: OnMissingStub.returnDefault),
// @stacked-mock-spec
])
void registerServices() {
  getAndRegisterNavigationService();
  getAndRegisterBottomSheetService();
  getAndRegisterDialogService();
  getAndRegisterBiotService();
  getAndRegisterLocaldbService();
  getAndRegisterSharedPreferencesService();
  getAndRegisterPackageInfoService();
  getAndRegisterFileService();
  getAndRegisterOutcomeMeasureSelectionService();
  getAndRegisterOutcomeMeasureLoadService();
  getAndRegisterPdfService();
  getAndRegisterFileSaverService();
  getAndRegisterLoggerService();
  getAndRegisterAppLocaleService();
  getAndRegisterAnalyticsService();
// @stacked-mock-register
}

void unregisterService() {
  locator.unregister<NavigationService>();
  locator.unregister<BottomSheetService>();
  locator.unregister<DialogService>();
  locator.unregister<BiotService>();
}

MockNavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

MockBottomSheetService getAndRegisterBottomSheetService<T>({
  SheetResponse<T>? showCustomSheetResponse,
}) {
  _removeRegistrationIfExists<BottomSheetService>();
  final service = MockBottomSheetService();

  when(service.showCustomSheet<T, T>(
    enableDrag: anyNamed('enableDrag'),
    enterBottomSheetDuration: anyNamed('enterBottomSheetDuration'),
    exitBottomSheetDuration: anyNamed('exitBottomSheetDuration'),
    ignoreSafeArea: anyNamed('ignoreSafeArea'),
    isScrollControlled: anyNamed('isScrollControlled'),
    barrierDismissible: anyNamed('barrierDismissible'),
    additionalButtonTitle: anyNamed('additionalButtonTitle'),
    variant: anyNamed('variant'),
    title: anyNamed('title'),
    hasImage: anyNamed('hasImage'),
    imageUrl: anyNamed('imageUrl'),
    showIconInMainButton: anyNamed('showIconInMainButton'),
    mainButtonTitle: anyNamed('mainButtonTitle'),
    showIconInSecondaryButton: anyNamed('showIconInSecondaryButton'),
    secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
    showIconInAdditionalButton: anyNamed('showIconInAdditionalButton'),
    takesInput: anyNamed('takesInput'),
    barrierColor: anyNamed('barrierColor'),
    barrierLabel: anyNamed('barrierLabel'),
    customData: anyNamed('customData'),
    data: anyNamed('data'),
    description: anyNamed('description'),
  )).thenAnswer((realInvocation) =>
      Future.value(showCustomSheetResponse ?? SheetResponse<T>()));

  locator.registerSingleton<BottomSheetService>(service);
  return service;
}

MockDialogService getAndRegisterDialogService() {
  _removeRegistrationIfExists<DialogService>();
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service);
  return service;
}

MockBiotService getAndRegisterBiotService() {
  _removeRegistrationIfExists<BiotService>();
  final service = MockBiotService();
  locator.registerSingleton<BiotService>(service);
  return service;
}

MockDatabaseService getAndRegisterLocaldbService() {
  _removeRegistrationIfExists<DatabaseService>();
  final service = MockDatabaseService();
  locator.registerSingleton<DatabaseService>(service);
  return service;
}

MockSharedPreferencesService getAndRegisterSharedPreferencesService() {
  _removeRegistrationIfExists<SharedPreferencesService>();
  final service = MockSharedPreferencesService();
  locator.registerSingleton<SharedPreferencesService>(service);
  return service;
}

MockPackageInfoService getAndRegisterPackageInfoService() {
  _removeRegistrationIfExists<PackageInfoService>();
  final service = MockPackageInfoService();
  locator.registerSingleton<PackageInfoService>(service);
  return service;
}

MockFileService getAndRegisterFileService() {
  _removeRegistrationIfExists<FileService>();
  final service = MockFileService();
  locator.registerSingleton<FileService>(service);
  return service;
}

MockOutcomeMeasureSelectionService
    getAndRegisterOutcomeMeasureSelectionService() {
  _removeRegistrationIfExists<OutcomeMeasureSelectionService>();
  final service = MockOutcomeMeasureSelectionService();
  locator.registerSingleton<OutcomeMeasureSelectionService>(service);
  return service;
}

MockOutcomeMeasureLoadService getAndRegisterOutcomeMeasureLoadService() {
  _removeRegistrationIfExists<OutcomeMeasureLoadService>();
  final service = MockOutcomeMeasureLoadService();
  locator.registerSingleton<OutcomeMeasureLoadService>(service);
  return service;
}

MockPdfService getAndRegisterPdfService() {
  _removeRegistrationIfExists<PdfService>();
  final service = MockPdfService();
  locator.registerSingleton<PdfService>(service);
  return service;
}

MockFileSaverService getAndRegisterFileSaverService() {
  _removeRegistrationIfExists<FileSaverService>();
  final service = MockFileSaverService();
  locator.registerSingleton<FileSaverService>(service);
  return service;
}

MockAppLocaleService getAndRegisterAppLocaleService() {
  _removeRegistrationIfExists<AppLocaleService>();
  final service = MockAppLocaleService();
  locator.registerSingleton<AppLocaleService>(service);
  return service;
}

MockLoggerService getAndRegisterLoggerService() {
  _removeRegistrationIfExists<LoggerService>();
  final service = MockLoggerService();
  locator.registerSingleton<LoggerService>(service);
  return service;
}

MockAnalyticsService getAndRegisterAnalyticsService() {
  _removeRegistrationIfExists<AnalyticsService>();
  final service = MockAnalyticsService();
  locator.registerSingleton<AnalyticsService>(service);
  return service;
}
// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
