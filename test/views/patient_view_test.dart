import 'dart:async';

import 'package:biot/app/app.dialogs.dart';
import 'package:biot/app/app.locator.dart';
import 'package:biot/app/app.router.dart';
import 'package:biot/model/patient.dart';
import 'package:biot/services/cloud_service.dart';
import 'package:biot/services/database_service.dart';
import 'package:biot/services/logger_service.dart';
import 'package:biot/ui/views/add_lead_dialog/add_lead_dialog_view.dart';
import 'package:biot/ui/views/patient/patient_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

class MockValueListenable<T> extends Mock implements ValueListenable<T> {}

// Function to tap a widget and wait for frame to build
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  late var mockLoggerService;
  late var localDatabaseService;
  late var apiService;
  late MockBox<Patient> mockPatientBox;
  late StreamController<BoxEvent> boxEventStreamController;
  List<Patient> patients = [];
  setUp(() {
    mockPatientBox = MockBox<Patient>();
    getAndRegisterBottomSheetService();
    getAndRegisterBiotService();
    getAndRegisterLocaldbService();
    getAndRegisterLoggerService();
    StackedLocator.instance.registerLazySingleton(() => NavigationService());
    StackedLocator.instance.registerLazySingleton(() => DialogService());
    setupDialogUi();

    mockLoggerService = locator<LoggerService>();
    apiService = locator<BiotService>();
    when(apiService.ownerOrganizationCode).thenReturn('JK0001');
    when(mockLoggerService.getLogger(any))
        .thenReturn(Logger(printer: SimplePrinter(), output: ConsoleOutput()));
    localDatabaseService = locator<DatabaseService>();
    when(localDatabaseService.patientsBox).thenReturn(mockPatientBox);

    boxEventStreamController = StreamController<BoxEvent>.broadcast();

    boxEventStreamController.stream.listen(
            (event) {
          print("Received event: ${event.key}, ${event.value}");
          // Your update logic here
        }
    );
    // Setup your mock to return this stream when watch is called
    when(mockPatientBox.watch())
        .thenAnswer((_) => boxEventStreamController.stream);

    when(mockPatientBox.values).thenAnswer((_) {
      print('mockbox values: ${patients.length}');
      if(patients.isNotEmpty){
        print(patients.first.dob);
      }
      return patients;
    });

    when(localDatabaseService.addPatient(any)).thenAnswer((invocation) async {
      var patient = invocation.positionalArguments[0] as Patient;
      patient.creationTime = DateTime.now();
      patients.add(patient);
      boxEventStreamController.add(BoxEvent(patient.id, patient, true));
    });

    when(localDatabaseService.editPatient(any)).thenAnswer((invocation) async {
      print('editPatient triggerd');
      var patient = invocation.positionalArguments[0] as Patient;
      var patientToEdit = patients.firstWhere((element) => element.id == patient.id);
      patientToEdit.sexAtBirthIndex = patient.sexAtBirthIndex;
      patientToEdit.dob = patient.dob;
      boxEventStreamController.add(BoxEvent(patient.id, patient, false));
    });
  });

  tearDown(() {
    unregisterService();
    boxEventStreamController.close();
    patients.clear();
  });

  testWidgets('Verify the view has a title as "Clients"',
      (WidgetTester tester) async {
    const Size screenSize =
        Size(1488, 2266); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);
    Patient tp1 = Patient(
        id: 'TEST-PATIENT-001',
        firstName: 'Test',
        lastName: 'Patient',
        email: 'testpatient001@test.com');
    tp1.sexAtBirthIndex = 0;
    tp1.dob = DateTime(2000, 5, 30);
    tp1.creationTime = DateTime.now();
    when(mockPatientBox.values).thenAnswer((_) => [tp1]);
    await tester.pumpWidget(const MaterialApp(
      home: PatientView(),
    ));

    final textFinder = find.text('Clients');
    expect(textFinder, findsOneWidget);

    final patient = find.text('TEST-PATIENT-001');
    expect(patient, findsOneWidget);
  });

  testWidgets(
      'Verify list of clients is sorted in descending order by enrollment date.',
      (WidgetTester tester) async {
    const Size screenSize =
        Size(1488, 2266); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);
    Patient tp1 = Patient(
        id: 'TEST-PATIENT-001',
        firstName: 'Test',
        lastName: 'Patient',
        email: 'testpatient001@test.com');
    tp1.sexAtBirthIndex = 0;
    tp1.dob = DateTime(2000, 5, 30);
    tp1.creationTime = DateTime.now();
    Patient tp2 = Patient(
        id: 'TEST-PATIENT-002',
        firstName: 'Test',
        lastName: 'Patient',
        email: 'testpatient001@test.com');
    tp2.sexAtBirthIndex = 1;
    tp2.dob = DateTime(2001, 5, 30);
    tp2.creationTime = DateTime.now();
    // Provide unsorted list of patients based on their creation time
    // tp2's creation time is later then tp1's, so tp2 should be
    // displayed on top of the list
    when(mockPatientBox.values).thenAnswer((_) => [tp1, tp2]);
    await tester.pumpWidget(const MaterialApp(
      home: PatientView(),
    ));

    final textFinder = find.text('Clients');
    expect(textFinder, findsOneWidget);

    // Verify that patient with id "TEST-PATIENT-002" is the first in the list
    Widget patientTile = tester.widgetList(find.byType(ListTile)).elementAt(0);
    String patientId = ((patientTile as ListTile).title as Text).data!;
    expect('TEST-PATIENT-002', patientId);
  });

  testWidgets(
      'Verify add patient dialog displays when "Add Patient" button is tapped',
      (WidgetTester tester) async {
    const Size screenSize =
        Size(1488, 2266); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      home: const PatientView(),
    ));

    final fab = find.byType(FloatingActionButton);
    await tapAndSettle(tester, fab);
    final addPatientDialog = find.byType(AddLeadDialogView);
    expect(addPatientDialog, findsOneWidget);

    // Verify that tapping "Add" button when nothing is selected
    // does not dismiss the view
    final addButton = find.text('Add');
    expect(addButton, findsOneWidget);
    await tapAndSettle(tester, addButton);
    expect(addPatientDialog, findsOneWidget);

    // Verify that tapping "Add" button when only birth year is selected
    // does not dismiss the view
    final newYear = find.text('2004');
    final scrollableFinder = find.descendant(
      of: find.byType(GridView),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(newYear, 100, scrollable: scrollableFinder);
    await tester.pumpAndSettle();
    await tapAndSettle(tester, newYear);
    final newYearText = find.text('Year of Birth - 2004');
    expect(newYearText, findsOneWidget);
    await tapAndSettle(tester, addButton);
    expect(addPatientDialog, findsOneWidget);

    // Verify that tapping "Add" button when both birth year and sex is selected dismisses the view
    final newSex = find.byWidgetPredicate((Widget w) =>
    w is ChoiceChip && ((w.label as Text).data!.contains('Neither')));
    await tapAndSettle(tester, newSex);
    expect((tester.widget(newSex) as ChoiceChip).selected, true);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(addPatientDialog, findsNothing);

    final patientId = find.byWidgetPredicate((Widget w) =>
    w is Text && w.data!.contains(RegExp(r'^JK0001-[0-9a-fA-F]{4}-04N$')));
    final patientTile = find.byType(ListTile);
    expect(patientTile, findsOneWidget);
    expect(patientId, findsOneWidget);
  });

  testWidgets(
      'Verify edit patient dialog displays when "Edit Patient" button is tapped',
      (WidgetTester tester) async {

    Patient tp1 = Patient(
        id: 'TEST-PATIENT-001',
        firstName: 'Test',
        lastName: 'Patient',
        email: 'testpatient001@test.com');
    tp1.sexAtBirthIndex = 0;
    tp1.dob = DateTime(2000, 5, 30);
    tp1.creationTime = DateTime.now();
    patients.add(tp1);
    const Size screenSize =
        Size(1488, 2266); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      home: const PatientView(),
    ));

    final patientTile = find.byType(ListTile);
    await tester.drag(patientTile, const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();
    final editButton = find.text('Edit');
    expect(editButton, findsOneWidget);

    await tapAndSettle(tester, editButton);
    final updatePatientDialog = find.byType(AddLeadDialogView);
    expect(updatePatientDialog, findsOneWidget);

    final yearText = find.text('Year of Birth - 2000');
    expect(yearText, findsOneWidget);

    final selectedSex = find.byWidgetPredicate((Widget w) =>
        w is ChoiceChip && ((w.label as Text).data!.contains('Male')));
    expect((tester.widget(selectedSex) as ChoiceChip).selected, true);

    final newYear = find.text('2004');
    final scrollableFinder = find.descendant(
      of: find.byType(GridView),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(newYear, 100, scrollable: scrollableFinder);
    await tester.pumpAndSettle();
    await tapAndSettle(tester, newYear);
    final newYearText = find.text('Year of Birth - 2004');
    expect(newYearText, findsOneWidget);

    final newSex = find.byWidgetPredicate((Widget w) =>
        w is ChoiceChip && ((w.label as Text).data!.contains('Neither')));
    await tapAndSettle(tester, newSex);
    expect((tester.widget(newSex) as ChoiceChip).selected, true);

    final updateButton = find.text('Update');
    expect(updateButton, findsOneWidget);
    await tester.tap(updateButton);
    await tester.pumpAndSettle();
    expect(updatePatientDialog, findsNothing);

    final updatedText = find.byWidgetPredicate((Widget w) =>
    w is Text && w.data!.contains('Neither') && w.data!.contains('2004'));
    expect(updatedText, findsOneWidget);
  });
}
