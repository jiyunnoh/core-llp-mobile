import 'package:biot/app/app.dialogs.dart';
import 'package:biot/app/app.locator.dart';
import 'package:biot/app/app.router.dart';
import 'package:biot/constants/amputation_info.dart';
import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/constants/sex_at_birth.dart';
import 'package:biot/model/amputation.dart';
import 'package:biot/model/encounter.dart';
import 'package:biot/model/encounter_collection.dart';
import 'package:biot/services/database_service.dart';
import 'package:biot/services/logger_service.dart';
import 'package:biot/ui/views/patient_detail/patient_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  late var mockLoggerService;
  late ReactiveValue<MockPatient> patient;
  List<Amputation> amputations = [];
  List<Encounter> encounters = [];

  setUp(() {
    getAndRegisterBottomSheetService();
    getAndRegisterBiotService();
    getAndRegisterLocaldbService();
    getAndRegisterLoggerService();
    getAndRegisterOutcomeMeasureSelectionService();
    getAndRegisterOutcomeMeasureLoadService();
    StackedLocator.instance.registerLazySingleton(() => NavigationService());
    StackedLocator.instance.registerLazySingleton(() => DialogService());
    setupDialogUi();

    mockLoggerService = locator<LoggerService>();
    when(mockLoggerService.getLogger(any))
        .thenReturn(Logger(printer: SimplePrinter(), output: ConsoleOutput()));

    patient = ReactiveValue<MockPatient>(MockPatient());
    final localdbService = locator<DatabaseService>();
    when(localdbService.currentPatient).thenReturn(patient);
    when(patient.value.amputations).thenReturn(amputations);
    when(patient.value.id).thenReturn('JK0001-A12B-90M');
    when(patient.value.dob).thenReturn(DateTime(1990, 1, 1));
    when(patient.value.sexAtBirth).thenReturn(SexAtBirth.male);
    when(patient.value.encounters).thenReturn(encounters);
    when(patient.value.encounterCollection)
        .thenAnswer((_) => EncounterCollection(encounters));
  });

  tearDown(() {
    amputations.clear();
    encounters.clear();
    unregisterService();
  });

  testWidgets('Verify selected patient info is displayed correctly',
      (WidgetTester tester) async {
    const Size screenSize =
        Size(1488, 2266); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      home: const PatientDetailView(),
    ));

    expect(find.text('JK0001-A12B-90M'), findsOneWidget);
    expect(find.text('1990'), findsOneWidget);
    expect(find.text('Male'), findsOneWidget);
  });

  testWidgets('Verify no amputation info is displayed correctly',
      (WidgetTester tester) async {
    const Size screenSize =
        Size(1488, 2266); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      home: const PatientDetailView(),
    ));

    //Verify no amputation info is displayed
    expect(find.text('Left'), findsNothing);
    expect(find.text('Right'), findsNothing);
    expect(find.text('Detail'), findsNothing);
  });

  testWidgets(
      'Verify current amputation side and level is displayed in Patient Details view',
      (WidgetTester tester) async {
    Amputation left = Amputation(
        side: AmputationSide.left, level: LevelOfAmputation.toeAmputation);
    Amputation right = Amputation(
        side: AmputationSide.right, level: LevelOfAmputation.transfemoral);
    amputations.add(left);
    amputations.add(right);
    const Size screenSize =
        Size(1488, 2266); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      home: const PatientDetailView(),
    ));

    //Verify no amputation info is displayed
    expect(find.text('Left'), findsOneWidget);
    expect(find.text('Right'), findsOneWidget);
    expect(
        find.text(LevelOfAmputation.toeAmputation.displayName), findsOneWidget);
    expect(
        find.text(LevelOfAmputation.transfemoral.displayName), findsOneWidget);
    expect(find.text('Detail'), findsOneWidget);
  });

  testWidgets('Verify no amputation info is displayed correctly',
      (WidgetTester tester) async {
    const Size screenSize =
        Size(1488, 2266); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      home: const PatientDetailView(),
    ));

    //Verify no amputation info is displayed
    expect(find.text('Pre'), findsNothing);
    expect(find.text('Post'), findsNothing);
    expect(find.text('Encounters'), findsNothing);
  });

  testWidgets(
      'Verify pre, post and after post encounters are displayed correctly',
      (WidgetTester tester) async {
    Encounter preEp =
        Encounter(prefix: EpisodePrefix.pre, submitCode: Submit.finish);
    preEp.encounterCreatedTimeString = DateTime(2024, 1, 5).toIso8601String();
    Encounter postEp =
        Encounter(prefix: EpisodePrefix.post, submitCode: Submit.finish);
    postEp.encounterCreatedTimeString = DateTime(2024, 2, 10).toIso8601String();
    Encounter encounter =
        Encounter(prefix: EpisodePrefix.post, submitCode: Submit.finish);
    encounter.encounterCreatedTimeString =
        DateTime(2024, 3, 15).toIso8601String();
    encounters.add(preEp);
    encounters.add(postEp);
    encounters.add(encounter);
    encounters.sort((a,b) => b.encounterCreatedTime!.compareTo(a.encounterCreatedTime!));
    const Size screenSize =
        Size(1488, 2266); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      home: const PatientDetailView(),
    ));

    //Verify no amputation info is displayed
    expect(find.text(EpisodePrefix.pre.displayName), findsOneWidget);
    expect(find.textContaining('2024-01-05'), findsOneWidget);
    expect(find.text(EpisodePrefix.post.displayName), findsNWidgets(2));
    expect(find.textContaining('2024-02-10'), findsOneWidget);
    expect(find.text('Encounters'), findsOneWidget);
    expect(find.textContaining('2024-03-15'), findsOneWidget);
  });

  testWidgets(
      'Verify pre, post and after post encounters with submit code 1 are displayed correctly',
      (WidgetTester tester) async {
    Encounter preEp =
        Encounter(prefix: EpisodePrefix.pre, submitCode: Submit.initial);
    preEp.encounterCreatedTimeString = DateTime(2024, 1, 5).toIso8601String();
    Encounter preEp2 =
        Encounter(prefix: EpisodePrefix.pre, submitCode: Submit.finish);
    preEp2.encounterCreatedTimeString = DateTime(2024, 2, 10).toIso8601String();
    Encounter postEp =
        Encounter(prefix: EpisodePrefix.post, submitCode: Submit.initial);
    postEp.encounterCreatedTimeString = DateTime(2024, 3, 15).toIso8601String();
    Encounter postEp2 =
        Encounter(prefix: EpisodePrefix.post, submitCode: Submit.finish);
    postEp2.encounterCreatedTimeString =
        DateTime(2024, 3, 16).toIso8601String();
    encounters.add(preEp);
    encounters.add(preEp2);
    encounters.add(postEp);
    encounters.add(postEp2);
    encounters.sort((a,b) => b.encounterCreatedTime!.compareTo(a.encounterCreatedTime!));
    const Size screenSize =
        Size(1488, 2266); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      home: const PatientDetailView(),
    ));

    //Verify no amputation info is displayed
    expect(find.text(EpisodePrefix.pre.displayName), findsOneWidget);
    expect(find.textContaining('2024-01-05'), findsNothing);
    expect(find.textContaining('2024-02-10'), findsOneWidget);
    expect(find.text(EpisodePrefix.post.displayName), findsOneWidget);
    expect(find.textContaining('2024-03-15'), findsNothing);
    expect(find.textContaining('2024-03-16'), findsOneWidget);
    expect(find.text('Encounters'), findsOneWidget);
  });
}
