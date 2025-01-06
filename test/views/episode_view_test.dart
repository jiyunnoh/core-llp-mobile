import 'package:biot/app/app.dialogs.dart';
import 'package:biot/app/app.locator.dart';
import 'package:biot/app/app.router.dart';
import 'package:biot/constants/amputation_info.dart';
import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/model/amputation.dart';
import 'package:biot/model/encounter.dart';
import 'package:biot/model/episode_of_care.dart';
import 'package:biot/model/socket_info.dart';
import 'package:biot/services/cloud_service.dart';
import 'package:biot/services/database_service.dart';
import 'package:biot/services/logger_service.dart';
import 'package:biot/services/pdf_service.dart';
import 'package:biot/ui/common/app_colors.dart';
import 'package:biot/ui/dialogs/busy/busy_dialog.dart';
import 'package:biot/ui/dialogs/confirm_alert/confirm_alert_dialog.dart';
import 'package:biot/ui/dialogs/loading_indicator/loading_indicator_dialog.dart';
import 'package:biot/ui/views/episode/episode_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:pdf_merger/pdf_merger.dart';
import 'package:stacked/src/reactive/reactive_value/reactive_value.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:http/http.dart' as http;

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

// Enum to represent the checkbox type
enum CheckboxType {
  profession,
  rehabilitationServices,
  ct,
  socketType,
  suspension,
  prostheticFoot,
  prostheticKnee,
  prostheticHip,
}

void main() {
  late var mockLoggerService;
  late BiotService service;
  late PdfService pdfService;

  late Encounter encounter;
  late EpisodeOfCare episodeOfCare;
  late SocketInfo socketInfo;
  late ReactiveValue<MockPatient> patient;
  List<Amputation> amputations = [];

  setUp(() {
    getAndRegisterBottomSheetService();
    getAndRegisterBiotService();
    getAndRegisterLocaldbService();
    getAndRegisterLoggerService();
    getAndRegisterPdfService();
    getAndRegisterAnalyticsService();
    StackedLocator.instance.registerLazySingleton(() => NavigationService());
    StackedLocator.instance.registerLazySingleton(() => DialogService());
    setupDialogUi();

    mockLoggerService = locator<LoggerService>();
    when(mockLoggerService.getLogger(any))
        .thenReturn(Logger(printer: SimplePrinter(), output: ConsoleOutput()));

    service = locator<BiotService>();
    pdfService = locator<PdfService>();

    socketInfo = SocketInfo()
      ..side = AmputationSide.left
      ..dateOfDelivery = DateTime(2000, 10, 10)
      ..socket = Socket.partialFoot
      ..partialFootDesign = PartialFootDesign.withinShoe
      ..socketTypes = [SocketType.fiberglassLamination]
      ..liner = Liner.noLiner
      ..suspension = Suspension.selfSuspending
      ..prostheticFootTypes = [ProstheticFootType.hardRubberBareFootDesign];

    episodeOfCare = EpisodeOfCare()
      ..height = 180
      ..weight = 68
      ..tobaccoUsage = TobaccoUsage.never
      ..maxEducationLevel = MaxEducationLevel.noFormalEducation
      ..icdCodesOfConditions = 'A001'
      ..professionsInvolved = [Profession.prosthetist]
      ..rehabilitationServices = [RehabilitationServices.compressionTherapy]
      ..compressionTherapies = [CompressionTherapy.other]
      ..ctOther = 'ct other text'
      ..prostheticIntervention = ProstheticIntervention.prosthesis
      ..socketInfoList = [socketInfo];

    encounter = MockEncounter();
    when(encounter.prefix).thenReturn(EpisodePrefix.post);
    when(encounter.episodeOfCare).thenReturn(episodeOfCare);

    patient = ReactiveValue<MockPatient>(MockPatient());
    final localdbService = locator<DatabaseService>();
    when(localdbService.currentPatient).thenReturn(patient);
    when(patient.value.amputations).thenReturn(amputations);
    when(patient.value.id).thenReturn('any');
  });

  tearDown(() {
    unregisterService();
    amputations.clear();
  });

  // Function to tap a widget and wait for frame to build
  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  // Test tapping outside of the menu for no selection
  Future<void> tapOffsetZero(WidgetTester tester) async {
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
  }

  Future<void> setScreenSize(WidgetTester tester, Size screenSize) async {
    await tester.binding.setSurfaceSize(screenSize);
  }

  Future<void> pumpMainWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        home: EpisodeView(encounter, isEdit: false),
      ),
    );
  }

  Future<void> pumpMainWidgetOnEdit(WidgetTester tester) async {
    amputations.add(Amputation(side: AmputationSide.hemicorporectomy));

    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        home: EpisodeView(encounter, isEdit: true),
      ),
    );
  }

  Future<void> pumpPage2Widget(WidgetTester tester) async {
    amputations.add(Amputation(side: AmputationSide.hemicorporectomy));

    await pumpMainWidget(tester);

    // Target 'Next' button and Tap to navigate to page 2
    final targetWidget = find.text('next');
    expect(targetWidget, findsOneWidget);
    await tapAndSettle(tester, targetWidget);
  }

  Future<void> pumpPage2WidgetOnEdit(WidgetTester tester) async {
    await pumpMainWidgetOnEdit(tester);

    // Target 'Next' button and Tap to navigate to page 2
    final targetWidget = find.text('next');
    expect(targetWidget, findsOneWidget);
    await tapAndSettle(tester, targetWidget);
  }

  Finder findByTypeAndKey<T>(Key key) {
    return find.byWidgetPredicate((widget) => widget is T && widget.key == key);
  }

  // Function to verify checkbox state
  Future<void> verifyCheckBoxState(WidgetTester tester, CheckboxType type,
      dynamic value, bool expectedState) async {
    String typeName;
    switch (type) {
      case CheckboxType.profession:
        typeName = 'profession';
        break;
      case CheckboxType.rehabilitationServices:
        typeName = 'rehabService';
        break;
      case CheckboxType.ct:
        typeName = 'ct';
        break;
      case CheckboxType.socketType:
        typeName = 'socketType';
      case CheckboxType.suspension:
        typeName = 'suspension';
      case CheckboxType.prostheticFoot:
        typeName = 'prostheticFoot';
      case CheckboxType.prostheticKnee:
        typeName = 'prostheticKnee';
      case CheckboxType.prostheticHip:
        typeName = 'prostheticHip';
    }

    // Find the checkbox widget
    final checkboxFinder = findByTypeAndKey(Key('${typeName}_${value.index}'));

    // Tap the checkbox
    await tapAndSettle(tester, checkboxFinder);

    // Get the state of the Checkbox after tapping it
    final tappedState = tester.widget<Checkbox>(checkboxFinder);

    // Verify that the state matches the expected state
    expect(tappedState.value, expectedState);
  }

  Future<void> tapInfoAndCheckDialog(WidgetTester tester, String key) async {
    final infoFinder = findByTypeAndKey<IconButton>(Key('${key}_info'));

    expect(infoFinder, findsOneWidget);

    await tapAndSettle(tester, infoFinder);
    expect(find.byType(Dialog), findsOneWidget);

    await tapOffsetZero(tester);
  }

  Future<void> changeDate(
      WidgetTester tester, Finder dateFormField, String date) async {
    await tapAndSettle(tester, dateFormField);

    final inputSwitch = find.byWidgetPredicate((Widget w) =>
        w is IconButton && (w.tooltip?.startsWith('Switch to input') ?? false));
    await tapAndSettle(tester, inputSwitch);

    final textField = find.byWidgetPredicate((Widget w) =>
        w is TextField &&
        (w.decoration?.labelText?.startsWith('Enter Date') ?? false));
    await tester.enterText(textField, date);
    await tapAndSettle(tester, find.text('OK'));
  }

  Future<void> setupToVerifyProstheticCheckbox(WidgetTester tester) async {
    final targetWidget = find.byKey(const Key('socket'));
    final socketFinder =
        find.byKey(Key('socket_${Socket.hemicorporectomy.displayName}'));
    await tapAndSettle(tester, targetWidget);
    await tapAndSettle(tester, socketFinder);
    expect(find.text(Socket.hemicorporectomy.displayName), findsOneWidget);
  }

  final nextButton = findByTypeAndKey<Container>(const Key('nextButton'));
  final updateButton = findByTypeAndKey<Container>(const Key('updateButton'));
  final backButton = findByTypeAndKey<IconButton>(const Key('backButton'));
  final loadingIndicatorDialog = find.byType(LoadingIndicatorDialog);
  final busyDialog = find.byType(BusyDialog);

  /// **Test ID**: TC-LERC-005
  /// **Objective**: Verify user can navigate from page 1 to page 2 and vice versa.
  /// **Preconditions**: None.
  /// **Test Steps**:
  ///   1. Navigate from page 1 to page 2 by tapping the 'Next' button.
  ///   2. Verify that page 2 is displayed.
  ///   3. Navigate back to page 1 by tapping the 'Back' button.
  ///   4. Verify that page 1 is displayed.
  /// **Automated**: Yes
  testWidgets('TC-LERC-005 - Verify user can navigate from page 1 to page 2 and vice versa.',
      (WidgetTester tester) async {
    amputations.add(Amputation(side: AmputationSide.hemicorporectomy));

    await setScreenSize(tester, const Size(768, 1024));

    await pumpMainWidget(tester);
    // Verify that the page 1 is displayed
    final page1Title = find.text('Episode of Rehabilitation Care (1/2)');
    expect(page1Title, findsOneWidget);

    // Target 'Next' button and Tap to navigate to page 2
    final targetWidget = find.text('next');
    expect(targetWidget, findsOneWidget);
    await tapAndSettle(tester, targetWidget);

    // Verify that the page 2 is displayed
    final page2Title = find.text('Episode of Rehabilitation Care (2/2)');
    expect(page2Title, findsOneWidget);

    // Target 'Back Button' and Tap to navigate back to page 1
    expect(backButton, findsOneWidget);
    await tapAndSettle(tester, backButton);

    // Verify that the page 1 is displayed
    expect(page1Title, findsOneWidget);
  });

  group(
      'Verify all user interactable elements are interactable and exhibit proper interaction behavior in page 1.',
      () {
    /// **Test ID**: TC-LERC-006A
    /// **Objective**: Verify the functionality of height/weight widget.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and drag height pointer to a specific point.
    ///   2. Observe that the pointer text value and the text input field value are matched.
    ///   3. Find text input field and enter '0'.
    ///   4. Observe that the pointer text value and the text input field value reset to empty.
    ///   5. Enter some numbers to the text input field and observe the values are matched.
    ///   6. Repeat the same steps for weight pointer.
    ///   7. Tap 'Imperial' or 'Metric' and verify the conversion is correct.
    /// **Automated**: Yes
    testWidgets('TC-LERC-006A - Verify the functionality of height/weight widget.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpMainWidget(tester);

      final heightPointer = find.byKey(const Key('height_pointer'));
      expect(heightPointer, findsOneWidget);

      // Verify the point value and the text field value
      await tester.drag(heightPointer, const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(find.text('217'), findsExactly(2));
      await tester.drag(heightPointer, const Offset(-654, 0));
      await tester.pumpAndSettle();
      expect(find.text('125'), findsExactly(2));
      await tester.drag(heightPointer, const Offset(327, 0));
      await tester.pumpAndSettle();
      expect(find.text('175'), findsExactly(2));

      final heightCmText = find.byKey(const Key('cm_text'));
      expect(heightCmText, findsOneWidget);

      // Verify both the text field value and the marker text is reset when '0' is entered to the text field.
      await tester.enterText(heightCmText, '0');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(
          (tester.widget(find.byKey(const Key('cm_text'))) as TextField)
              .controller!
              .text,
          '');
      expect(
          (tester.widget(find.byKey(const Key('heightMarkerText'))) as Text)
              .data,
          "");

      // Verify the marker text is updated when the new input is entered to the text field.
      await tester.enterText(heightCmText, '160');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text('160'), findsExactly(2));

      final weightPointer = find.byKey(const Key('weight_pointer'));
      expect(weightPointer, findsOneWidget);

      // Verify the point value and the text field value
      await tester.drag(weightPointer, const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(find.text('140'), findsExactly(2));
      await tester.drag(weightPointer, const Offset(-654, 0));
      await tester.pumpAndSettle();
      expect(find.text('30'), findsExactly(2));
      await tester.drag(weightPointer, const Offset(327, 0));
      await tester.pumpAndSettle();
      expect(find.text('90'), findsExactly(2));

      final weightText = find.byKey(const Key('weight_text'));
      expect(weightText, findsOneWidget);

      // Verify both the text field value and the marker text is reset when '0' is entered to the text field.
      await tester.enterText(weightText, '0');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(
          (tester.widget(find.byKey(const Key('weight_text'))) as TextField)
              .controller!
              .text,
          '');
      expect(
          (tester.widget(find.byKey(const Key('weightMarkerText'))) as Text)
              .data,
          "");

      await tester.enterText(weightText, '100');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text('100'), findsExactly(2));

      // Verify conversion from metric to imperial
      await tapAndSettle(tester, find.text('Imperial'));
      expect(
          (tester.widget(find.byKey(const Key('ft_text'))) as TextField)
              .controller!
              .text,
          '5');
      expect(
          (tester.widget(find.byKey(const Key('inch_text'))) as TextField)
              .controller!
              .text,
          '3');
      expect(
          (tester.widget(find.byKey(const Key('heightMarkerText'))) as Text)
              .data,
          "5' 3\"");
      expect(find.text('220'), findsExactly(2));
    });

    /// **Test ID**: TC-LERC-006B
    /// **Objective**: Verify the tobacco usage drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap tobacco usage drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap tobacco usage drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006B - Verify the tobacco usage drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpMainWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('tobaccoUsage'));

      expect(targetWidget, findsOneWidget);

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over TobaccoUsage values and verify that each option is displayed
      for (final value in TobaccoUsage.values) {
        expect(find.text(value.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(3));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in TobaccoUsage.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));
        expect(find.text(value.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LERC-006C
    /// **Objective**: Verify the max education drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap max education drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap max education drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006C - Verify the max education drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpMainWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('maxEducation'));

      expect(targetWidget, findsOneWidget);

      await tapAndSettle(tester, targetWidget);

      // Iterate over MaxEducationLevel values and verify that each option is displayed
      for (final value in MaxEducationLevel.values) {
        expect(find.text(value.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(3));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in MaxEducationLevel.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));
        expect(find.text(value.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LERC-006D
    /// **Objective**: Verify the functionality of the ICD codes text field.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find the ICD codes text field.
    ///   2. Observe the keyboard is not visible.
    ///   3. Tap the ICD codes text field.
    ///   4. Observe the keyboard is visible.
    ///   5. Enter text into the text field.
    ///   6. Observe the entered text matches the value in the text field.
    /// **Automated**: Yes
    testWidgets('TC-LERC-006D - Verify the functionality of the ICD codes text field.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpMainWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('icdCodesOfConditions'));

      expect(targetWidget, findsOneWidget);
      expect(tester.testTextInput.isVisible, false);

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Check if keyboard is visible after tapping TextField
      expect(tester.testTextInput.isVisible, true);

      // Verify valid input
      await tester.enterText(
          targetWidget, 'Test 1. abc, ABC, 001 Test 2. ~!@#\$%^&*()_+`-=;:|<>');
      await tester.pumpAndSettle();
      expect(find.text('Test 1. abc, ABC, 001 Test 2. '), findsOneWidget);
    });

    /// **Test ID**: TC-LERC-006E
    /// **Objective**: Verify the functionality of the professions check boxes.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap all professions checkboxes to mark them as checked.
    ///   2. Tap all professions checkboxes again to mark them as unchecked.
    /// **Automated**: Yes
    testWidgets('TC-LERC-006E - Verify the functionality of the professions check boxes.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpMainWidget(tester);

      // Check all checkboxes
      for (final value in Profession.values) {
        await verifyCheckBoxState(tester, CheckboxType.profession, value, true);
      }

      // Uncheck all checkboxes
      for (final value in Profession.values) {
        await verifyCheckBoxState(
            tester, CheckboxType.profession, value, false);
      }
    });

    /// **Test ID**: TC-LERC-006F
    /// **Objective**: Verify the functionality of the rehabilitation intervention check boxes.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap all rehabilitation intervention checkboxes to mark them as checked.
    ///   2. Tap all rehabilitation intervention checkboxes again to mark them as unchecked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006F - Verify the functionality of the rehabilitation intervention check boxes.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpMainWidget(tester);

      // Check all checkboxes
      for (final value in RehabilitationServices.values) {
        await verifyCheckBoxState(
            tester, CheckboxType.rehabilitationServices, value, true);
      }

      // Uncheck all checkboxes
      for (final value in RehabilitationServices.values) {
        await verifyCheckBoxState(
            tester, CheckboxType.rehabilitationServices, value, false);
      }
    });

    /// **Test ID**: TC-LERC-006G
    /// **Objective**: Verify the functionality of the compression therapy check boxes.
    /// **Preconditions**: Ensure tapping the 'Compression Therapy' checkbox under rehabilitation intervention to mark it as checked.
    /// **Test Steps**:
    ///   1. Find and tap all compression therapy checkboxes to mark them as checked.
    ///   2. When the 'Other' checkbox is marked as checked, observe text field is visible.
    ///   3. Observe the keyboard is not visible.
    ///   4. Tap the text field.
    ///   5. Observe the keyboard is visible.
    ///   6. Enter text into the text field.
    ///   7. Observe the entered text matches the value in the text field.
    ///   8. Tap all compression therapy checkboxes again to mark them as unchecked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006G - Verify the functionality of the compression therapy check boxes.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpMainWidget(tester);

      final checkboxFinder = findByTypeAndKey(Key(
          'rehabService_${RehabilitationServices.compressionTherapy.index}'));

      // Tap the checkbox
      await tapAndSettle(tester, checkboxFinder);

      // Get the state of the Checkbox after tapping it
      final tappedState = tester.widget<Checkbox>(checkboxFinder);

      // Verify that the state matches the expected state
      expect(tappedState.value, true);

      // Check all checkboxes
      for (final value in CompressionTherapy.values) {
        expect(find.text(value.displayName), findsOneWidget);

        await verifyCheckBoxState(tester, CheckboxType.ct, value, true);

        // Verify that following question pops up when corresponding checkbox is checked.
        if (value == CompressionTherapy.other) {
          final textFieldFinder =
              findByTypeAndKey<TextField>(const Key('ct_other'));
          expect(textFieldFinder, findsOneWidget);
          expect(find.text('Please specify'), findsOneWidget);

          expect(tester.testTextInput.isVisible, false);
          await tapAndSettle(tester, textFieldFinder);

          // Check if keyboard is visible after tapping TextField
          expect(tester.testTextInput.isVisible, true);

          // Enter text into the TextField
          await tester.enterText(textFieldFinder, 'ct other test input');
          await tester.pumpAndSettle();

          // Verify if the TextField has the expected value
          expect(find.text('ct other test input'), findsOneWidget);
        }
      }

      // Uncheck all checkboxes
      for (final value in CompressionTherapy.values) {
        await verifyCheckBoxState(tester, CheckboxType.ct, value, false);
      }
    });

    /// **Test ID**: TC-LERC-006H
    /// **Objective**: Verify the prosthetic intervention drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap prosthetic intervention drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap prosthetic intervention drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006H - Verify the prosthetic intervention drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpMainWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('prostheticIntervention'));

      expect(targetWidget, findsOneWidget);

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over ProstheticIntervention values and verify that each option is displayed
      for (final value in ProstheticIntervention.values) {
        expect(find.text(value.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(3));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in ProstheticIntervention.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));
        expect(find.text(value.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LERC-006I
    /// **Objective**: Verify that all info dialogs can be opened and closed successfully.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap each info icon.
    ///   2. Observe the corresponding info dialog is visible.
    ///   3. Tap outside of the widget to dismiss it.
    ///   4. Tap each info icon again.
    ///   5. Tap Close button to dismiss it.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006I - Verify that all info dialogs can be opened and closed successfully.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpMainWidget(tester);

      List<String> infoKeys = [
        'height',
        'weight',
        'tobaccoUsage',
        'maxEducation',
        'icdCodes',
        'profession',
        'prostheticIntervention'
      ];

      for (int i = 0; i < infoKeys.length; i++) {
        await tapInfoAndCheckDialog(tester, infoKeys[i]);
      }
    });

    /// **Test ID**: TC-LERC-006AB
    /// **Objective**: Verify a prompt displayed when dismissing the page 1 by tapping the back button.
    /// **Preconditions**: Make sure the page 1 is loaded.
    /// **Test Steps**:
    ///   1. Find and tap back button.
    ///   2. Observe a prompt displayed.
    ///   3. Tap outside of the prompt to dismiss the prompt.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006AB - Verify a prompt displayed when dismissing the page 1 by tapping the back button.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpMainWidget(tester);

      await tapAndSettle(tester, backButton);

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byKey(const Key('cancelLeadCompassDialog')), findsOneWidget);

      await tapOffsetZero(tester);
    });

    /// **Test ID**: TC-LERC-006AC
    /// **Objective**: Verify the functionality of tapping on the tab bar.
    /// **Preconditions**: Ensure the widget has two tab bars.
    /// **Test Steps**:
    ///   1. Find and tap each tab bar.
    ///   2. Observe corresponding tab bar view is visible.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006AC - Verify the functionality of tapping on the tab bar.',
        (WidgetTester tester) async {
      amputations.add(Amputation(side: AmputationSide.left));
      amputations.add(Amputation(side: AmputationSide.right));

      await setScreenSize(tester, const Size(768, 1024));

      await pumpMainWidget(tester);

      // Target 'Next' button and Tap to navigate to page 2
      final targetWidget = find.text('next');
      expect(targetWidget, findsOneWidget);
      await tapAndSettle(tester, targetWidget);

      for (final value in amputations) {
        expect(find.text('${value.side?.displayName} Prosthesis Description'),
            findsOneWidget);
        final tabFinder =
            findByTypeAndKey<Tab>(Key('${value.side?.displayName}_tab'));
        await tapAndSettle(tester, tabFinder);
        expect(findByTypeAndKey(Key('${value.side?.displayName}_tabBarView')),
            findsOneWidget);
      }
    });
  });

  group(
      'Verify all user interactable elements are interactable and exhibit proper interaction behavior in page 2.',
      () {
    /// **Test ID**: TC-LERC-006J
    /// **Objective**: Verify the date picker is visible when icon or text field is tapped.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap the date icon button.
    ///   2. Verify that the date picker dialog is displayed.
    ///   3. Tap outside of the dialog to dismiss it.
    ///   4. Find and tap the date text form field.
    ///   5. Verify that the date picker dialog is displayed.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006J - Verify the date picker is visible when icon or text field is tapped.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpPage2Widget(tester);

      await tapInfoAndCheckDialog(tester, 'dateOfDelivery');

      // Find the date icon button
      final dateIconButton =
          findByTypeAndKey<IconButton>(const Key('dateOfDelivery'));

      expect(dateIconButton, findsOneWidget);

      await tapAndSettle(tester, dateIconButton);

      // Verify that the date picker dialog is displayed
      expect(find.byType(DatePickerDialog), findsOneWidget);

      await tapOffsetZero(tester);

      // Find the date text form field
      final dateTextFormField =
          findByTypeAndKey<TextFormField>(const Key('dateOfDelivery'));
      expect(dateTextFormField, findsOneWidget);

      // Tap the date text form field
      await tapAndSettle(tester, dateTextFormField);

      // Verify that the date picker dialog is displayed
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    /// **Test ID**: TC-LERC-006K
    /// **Objective**: Verify that the date selected in the date picker dialog is correctly reflected in the date text field.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap the date icon button.
    ///   2. Tap pencil icon on the dialog to change the input mode.
    ///   3. Enter the date.
    ///   4. Tap OK button to dismiss the dialog.
    ///   5. Verify that the input date matches the date displayed in the date text field.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006K - Verify that the date selected in the date picker dialog is correctly reflected in the date text field.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpPage2Widget(tester);

      // Find the date icon button
      final dateIconButton =
          findByTypeAndKey<IconButton>(const Key('dateOfDelivery'));

      // Verify selected date in the form field
      await changeDate(tester, dateIconButton, '1/5/1968');
      expect(find.text('1968-01-05'), findsOneWidget);
    });

    /// **Test ID**: TC-LERC-006L
    /// **Objective**: Verify that the socket drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap socket drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap socket drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    ///   8. Verify the corresponding info icon is visible when 'Transfemoral' or 'Transtibial' is selected.
    ///   9. Verify the functionality of info dialog for these two options.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006L - Verify that the socket drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('socket'));

      expect(targetWidget, findsOneWidget);

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over Socket values and verify that each option is displayed
      for (final value in Socket.values) {
        expect(find.text(value.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(3));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in Socket.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));
        expect(find.text(value.displayName), findsOneWidget);

        // Check for info dialog for specific socket types
        if (value == Socket.transfemoral || value == Socket.transTibial) {
          final infoKey =
              value == Socket.transfemoral ? 'transfemoral' : 'transtibial';

          await tapInfoAndCheckDialog(tester, infoKey);
        }

        // Verify corresponding following question is visible depending on the socket.
        final prostheticFootFinder = find.byKey(const Key('prostheticFoot'));
        expect(prostheticFootFinder, findsOneWidget);

        // Verify corresponding following question is visible depending on the socket.
        if (value.isAboveKnee) {
          final prostheticKneeFinder = find.byKey(const Key('prostheticKnee'));
          expect(prostheticKneeFinder, findsOneWidget);
        }

        // Verify corresponding following question is visible depending on the socket.
        if (value.isHip) {
          final prostheticHipFinder = find.byKey(const Key('prostheticHip'));
          expect(prostheticHipFinder, findsOneWidget);
        }
      }

      await tapInfoAndCheckDialog(tester, 'footType');
    });

    /// **Test ID**: TC-LERC-006M
    /// **Objective**: Verify that the design drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: Ensure tapping socket drop down menu and tap each option which is not hip socket.
    /// **Test Steps**:
    ///   1. Find and tap design drop down menu.
    ///   2. Observe all corresponding options are visible.
    ///   3. Tap each option.
    ///   4. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006M - Verify that the design drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      for (final value in Socket.values) {
        final targetWidget = find.byKey(const Key('socket'));
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));

        // Verify selected item is displayed
        expect(find.text(value.displayName), findsOneWidget);

        // Check corresponding Design dropdown menu if it's not Hip
        if (!value.isHip) {
          final designFinder = findByTypeAndKey<DropdownButtonFormField>(
              Key('${value.type}_design'));
          expect(designFinder, findsOneWidget);

          // Iterate over respective design values and verify each option is displayed
          switch (value) {
            case Socket.partialFoot:
              for (final value in PartialFootDesign.values) {
                await tapAndSettle(tester, designFinder);
                await tapAndSettle(tester, find.text(value.displayName));
                expect(find.text(value.displayName), findsOneWidget);
              }
              break;
            case Socket.ankleDisarticulation:
              for (final value in AnkleDisarticulationDesign.values) {
                await tapAndSettle(tester, designFinder);
                await tapAndSettle(tester, find.text(value.displayName));
                expect(find.text(value.displayName), findsOneWidget);
              }
              break;
            case Socket.transTibial:
              for (final value in TransTibialDesign.values) {
                await tapAndSettle(tester, designFinder);
                await tapAndSettle(tester, find.text(value.displayName));
                expect(find.text(value.displayName), findsOneWidget);
              }
              break;
            case Socket.kneeDisarticulation:
              for (final value in KneeDisarticulationDesign.values) {
                await tapAndSettle(tester, designFinder);
                await tapAndSettle(tester, find.text(value.displayName));
                expect(find.text(value.displayName), findsOneWidget);
              }
              break;
            case Socket.transfemoral:
              for (final value in TransfemoralDesign.values) {
                await tapAndSettle(tester, designFinder);
                await tapAndSettle(tester, find.text(value.displayName));
                expect(find.text(value.displayName), findsOneWidget);
              }
              break;
            case Socket.hipDisarticulation:
            case Socket.hemiPelvectomy:
            case Socket.hemicorporectomy:
              break;
          }
        }
      }
    });

    /// **Test ID**: TC-LERC-006N
    /// **Objective**: Verify the functionality of the prosthetic foot type check boxes.
    /// **Preconditions**: Ensure tapping one of options under socket drop down menu (Hemicorporectomy).
    /// **Test Steps**:
    ///   1. Find and tap all prosthetic foot type checkboxes to mark them as checked.
    ///   2. Tap all prosthetic foot type checkboxes again to mark them as unchecked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006N - Verify the functionality of the prosthetic foot type check boxes.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      await setupToVerifyProstheticCheckbox(tester);

      // Toggle all checkboxes
      for (final value in ProstheticFootType.values) {
        await verifyCheckBoxState(
            tester, CheckboxType.prostheticFoot, value, true);

        await verifyCheckBoxState(
            tester, CheckboxType.prostheticFoot, value, false);
      }
    });

    /// **Test ID**: TC-LERC-006O
    /// **Objective**: Verify the functionality of the 'Hard rubber bare foot design' option under prosthetic foot types.
    /// **Preconditions**: Ensure tapping one of options under socket drop down menu (Hemicorporectomy).
    /// **Test Steps**:
    ///   1. Find and tap all prosthetic foot type checkboxes to mark them as checked.
    ///   2. Observe 'Hard rubber bare foot design' is marked as unchecked when other options are checked.
    ///   3. Tap 'Hard rubber bare foot design' to mark it as checked.
    ///   4. Observe other options are marked as unchecked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006O - Verify the functionality of the \'Hard rubber bare foot design\' option under prosthetic foot types.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      await setupToVerifyProstheticCheckbox(tester);

      // Check all checkboxes
      for (final value in ProstheticFootType.values) {
        await verifyCheckBoxState(
            tester, CheckboxType.prostheticFoot, value, true);
      }

      // Test the hardRubberBareFootDesign check box
      final hardRubberFinder = findByTypeAndKey(Key(
          'prostheticFoot_${ProstheticFootType.hardRubberBareFootDesign.index}'));

      expect(tester.widget<Checkbox>(hardRubberFinder).value, false);

      await tapAndSettle(tester, hardRubberFinder);

      expect(tester.widget<Checkbox>(hardRubberFinder).value, true);

      // Verify all other options are unchecked.
      for (final value in ProstheticFootType.values) {
        if (value != ProstheticFootType.hardRubberBareFootDesign) {
          // Find the checkbox widget
          final otherCheckBoxFinder =
              findByTypeAndKey(Key('prostheticFoot_${value.index}'));

          expect(tester.widget<Checkbox>(otherCheckBoxFinder).value, false);
        }
      }
    });

    /// **Test ID**: TC-LERC-006P
    /// **Objective**: Verify the functionality of the 'SACH' option under prosthetic foot types.
    /// **Preconditions**: Ensure tapping one of options under socket drop down menu (Hemicorporectomy).
    /// **Test Steps**:
    ///   1. Find and tap all prosthetic foot type checkboxes to mark them as checked.
    ///   2. Observe 'SACH' is marked as unchecked when other options are checked.
    ///   3. Tap 'SACH' to mark it as checked.
    ///   4. Observe other options are marked as unchecked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006P - Verify the functionality of the \'SACH\' option under prosthetic foot types.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      await setupToVerifyProstheticCheckbox(tester);

      // Check all checkboxes
      for (final value in ProstheticFootType.values) {
        await verifyCheckBoxState(
            tester, CheckboxType.prostheticFoot, value, true);
      }

      // Test the SACH check box
      final sachFinder = findByTypeAndKey(
          Key('prostheticFoot_${ProstheticFootType.sach.index}'));
      await tapAndSettle(tester, sachFinder);

      expect(tester.widget<Checkbox>(sachFinder).value, true);

      // Verify all other options are unchecked.
      for (final value in ProstheticFootType.values) {
        if (value != ProstheticFootType.sach) {
          // Find the checkbox widget
          final otherCheckBoxFinder =
              findByTypeAndKey(Key('prostheticFoot_${value.index}'));

          expect(tester.widget<Checkbox>(otherCheckBoxFinder).value, false);
        }
      }
    });

    /// **Test ID**: TC-LERC-006Q
    /// **Objective**: Verify the functionality of the 'Single axis' and 'Multiaxial' option under prosthetic foot types.
    /// **Preconditions**: Ensure tapping one of options under socket drop down menu (Hemicorporectomy).
    /// **Test Steps**:
    ///   1. Find and tap 'Single axis' checkbox under prosthetic foot types checkbox.
    ///   2. Observe 'Single axis' is marked as checked, and 'Multiaxial' is marked as unchecked.
    ///   3. Find and tap 'Multiaxial' checkbox under prosthetic foot types checkbox.
    ///   4. Observe 'Single axis' is marked as unchecked, and 'Multiaxial' is marked as checked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006Q - Verify the functionality of the \'Single axis\' and \'Multiaxial\' option under prosthetic foot types.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      await setupToVerifyProstheticCheckbox(tester);

      final singleAxisFinder = findByTypeAndKey(
          Key('prostheticFoot_${ProstheticFootType.singleAxis.index}'));
      final multiaxialFinder = findByTypeAndKey(
          Key('prostheticFoot_${ProstheticFootType.multiaxial.index}'));

      await tapAndSettle(tester, singleAxisFinder);

      // Verify multiaxial unchecked when singleAxis checked
      expect(tester.widget<Checkbox>(singleAxisFinder).value, true);
      expect(tester.widget<Checkbox>(multiaxialFinder).value, false);

      await tapAndSettle(tester, multiaxialFinder);

      // Verify singleAxis unchecked when multiaxial checked
      expect(tester.widget<Checkbox>(singleAxisFinder).value, false);
      expect(tester.widget<Checkbox>(multiaxialFinder).value, true);
    });

    /// **Test ID**: TC-LERC-006R
    /// **Objective**: Verify the functionality of the 'Pneumatic' and 'Hydraulic' option under prosthetic foot types.
    /// **Preconditions**: Ensure tapping one of options under socket drop down menu (Hemicorporectomy).
    /// **Test Steps**:
    ///   1. Find and tap 'Pneumatic' checkbox under prosthetic foot types checkbox.
    ///   2. Observe 'Pneumatic' is marked as checked, and 'Hydraulic' is marked as unchecked.
    ///   3. Find and tap 'Hydraulic' checkbox under prosthetic foot types checkbox.
    ///   4. Observe 'Pneumatic' is marked as unchecked, and 'Hydraulic' is marked as checked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006R - Verify the functionality of the \'Pneumatic\' and \'Hydraulic\' option under prosthetic foot types.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      await setupToVerifyProstheticCheckbox(tester);

      final pneumaticFinder = findByTypeAndKey(
          Key('prostheticFoot_${ProstheticFootType.pneumatic.index}'));
      final hydraulicFinder = findByTypeAndKey(
          Key('prostheticFoot_${ProstheticFootType.hydraulic.index}'));

      await tapAndSettle(tester, pneumaticFinder);

      // Verify hydraulic unchecked when pneumatic checked
      expect(tester.widget<Checkbox>(pneumaticFinder).value, true);
      expect(tester.widget<Checkbox>(hydraulicFinder).value, false);

      await tapAndSettle(tester, hydraulicFinder);

      // Verify pneumatic unchecked when hydraulic checked
      expect(tester.widget<Checkbox>(pneumaticFinder).value, false);
      expect(tester.widget<Checkbox>(hydraulicFinder).value, true);
    });

    /// **Test ID**: TC-LERC-006S
    /// **Objective**: Verify the functionality of the prosthetic knee type check boxes.
    /// **Preconditions**: Ensure tapping one of options under socket drop down menu which is above knee socket (Hemicorporectomy).
    /// **Test Steps**:
    ///   1. Find and tap all prosthetic knee type checkboxes to mark them as checked.
    ///   2. Tap all prosthetic knee type checkboxes again to mark them as unchecked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006S - Verify the functionality of the prosthetic knee type check boxes.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      await setupToVerifyProstheticCheckbox(tester);

      // Toggle all checkboxes
      for (final value in ProstheticKneeType.values) {
        await verifyCheckBoxState(
            tester, CheckboxType.prostheticKnee, value, true);

        await verifyCheckBoxState(
            tester, CheckboxType.prostheticKnee, value, false);
      }
    });

    /// **Test ID**: TC-LERC-006T
    /// **Objective**: Verify the functionality of the 'Single axis' and 'Multiaxial' option under prosthetic knee types.
    /// **Preconditions**: Ensure tapping one of options under socket drop down menu which is above knee socket (Hemicorporectomy).
    /// **Test Steps**:
    ///   1. Find and tap 'Single axis' checkbox under prosthetic knee types checkbox.
    ///   2. Observe 'Single axis' is marked as checked, and 'Multiaxial' is marked as unchecked.
    ///   3. Find and tap 'Multiaxial' checkbox under prosthetic knee types checkbox.
    ///   4. Observe 'Single axis' is marked as unchecked, and 'Multiaxial' is marked as checked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006T - Verify the functionality of the \'Single axis\' and \'Multiaxial\' option under prosthetic knee types.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      await setupToVerifyProstheticCheckbox(tester);

      final singleAxisFinder = findByTypeAndKey(
          Key('prostheticKnee_${ProstheticKneeType.singleAxis.index}'));
      final multiaxialFinder = findByTypeAndKey(
          Key('prostheticKnee_${ProstheticKneeType.multiaxial.index}'));

      await tapAndSettle(tester, singleAxisFinder);

      // Verify multiaxial unchecked when singleAxis checked
      expect(tester.widget<Checkbox>(singleAxisFinder).value, true);
      expect(tester.widget<Checkbox>(multiaxialFinder).value, false);

      await tapAndSettle(tester, multiaxialFinder);

      // Verify singleAxis unchecked when multiaxial checked
      expect(tester.widget<Checkbox>(singleAxisFinder).value, false);
      expect(tester.widget<Checkbox>(multiaxialFinder).value, true);
    });

    /// **Test ID**: TC-LERC-006U
    /// **Objective**: Verify the functionality of the 'Pneumatic' and 'Hydraulic' option under prosthetic knee types.
    /// **Preconditions**: Ensure tapping one of options under socket drop down menu which is above knee socket (Hemicorporectomy).
    /// **Test Steps**:
    ///   1. Find and tap 'Pneumatic' checkbox under prosthetic knee types checkbox.
    ///   2. Observe 'Pneumatic' is marked as checked, and 'Hydraulic' is marked as unchecked.
    ///   3. Find and tap 'Hydraulic' checkbox under prosthetic knee types checkbox.
    ///   4. Observe 'Pneumatic' is marked as unchecked, and 'Hydraulic' is marked as checked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006U - Verify the functionality of the \'Pneumatic\' and \'Hydraulic\' option under prosthetic knee types.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      await setupToVerifyProstheticCheckbox(tester);

      final pneumaticFinder = findByTypeAndKey(
          Key('prostheticKnee_${ProstheticKneeType.pneumatic.index}'));
      final hydraulicFinder = findByTypeAndKey(
          Key('prostheticKnee_${ProstheticKneeType.hydraulic.index}'));

      await tapAndSettle(tester, pneumaticFinder);

      // Verify hydraulic unchecked when pneumatic checked
      expect(tester.widget<Checkbox>(pneumaticFinder).value, true);
      expect(tester.widget<Checkbox>(hydraulicFinder).value, false);

      await tapAndSettle(tester, hydraulicFinder);

      // Verify pneumatic unchecked when hydraulic checked
      expect(tester.widget<Checkbox>(pneumaticFinder).value, false);
      expect(tester.widget<Checkbox>(hydraulicFinder).value, true);
    });

    /// **Test ID**: TC-LERC-006V
    /// **Objective**: Verify the functionality of the prosthetic hip type check boxes.
    /// **Preconditions**: Ensure tapping one of options under socket drop down menu which is hip socket (Hemicorporectomy).
    /// **Test Steps**:
    ///   1. Find and tap all prosthetic hip type checkboxes to mark them as checked.
    ///   2. Tap all prosthetic hip type checkboxes again to mark them as unchecked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006V - Verify the functionality of the prosthetic hip type check boxes.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      await setupToVerifyProstheticCheckbox(tester);

      // Toggle all checkboxes
      for (final value in ProstheticHipType.values) {
        await verifyCheckBoxState(
            tester, CheckboxType.prostheticHip, value, true);

        await verifyCheckBoxState(
            tester, CheckboxType.prostheticHip, value, false);
      }
    });

    /// **Test ID**: TC-LERC-006W
    /// **Objective**: Verify the functionality of the 'Single axis' and 'Multiaxial' option under prosthetic hip types.
    /// **Preconditions**: Ensure tapping one of options under socket drop down menu which is hip socket (Hemicorporectomy).
    /// **Test Steps**:
    ///   1. Find and tap 'Single axis' checkbox under prosthetic hip types checkbox.
    ///   2. Observe 'Single axis' is marked as checked, and 'Multiaxial' is marked as unchecked.
    ///   3. Find and tap 'Multiaxial' checkbox under prosthetic hip types checkbox.
    ///   4. Observe 'Single axis' is marked as unchecked, and 'Multiaxial' is marked as checked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006W - Verify the functionality of the \'Single axis\' and \'Multiaxial\' option under prosthetic hip types.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      await setupToVerifyProstheticCheckbox(tester);

      final singleAxisFinder = findByTypeAndKey(
          Key('prostheticHip_${ProstheticHipType.singleAxis.index}'));
      final multiaxialFinder = findByTypeAndKey(
          Key('prostheticHip_${ProstheticHipType.multiaxial.index}'));

      await tapAndSettle(tester, singleAxisFinder);

      // Verify multiaxial unchecked when singleAxis checked
      expect(tester.widget<Checkbox>(singleAxisFinder).value, true);
      expect(tester.widget<Checkbox>(multiaxialFinder).value, false);

      await tapAndSettle(tester, multiaxialFinder);

      // Verify singleAxis unchecked when multiaxial checked
      expect(tester.widget<Checkbox>(singleAxisFinder).value, false);
      expect(tester.widget<Checkbox>(multiaxialFinder).value, true);
    });

    /// **Test ID**: TC-LERC-006X
    /// **Objective**: Verify the functionality of the 'Pneumatic' and 'Hydraulic' option under prosthetic hip types.
    /// **Preconditions**: Ensure tapping one of options under socket drop down menu which is hip socket (Hemicorporectomy).
    /// **Test Steps**:
    ///   1. Find and tap 'Pneumatic' checkbox under prosthetic hip types checkbox.
    ///   2. Observe 'Pneumatic' is marked as checked, and 'Hydraulic' is marked as unchecked.
    ///   3. Find and tap 'Hydraulic' checkbox under prosthetic hip types checkbox.
    ///   4. Observe 'Pneumatic' is marked as unchecked, and 'Hydraulic' is marked as checked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006X - Verify the functionality of the \'Pneumatic\' and \'Hydraulic\' option under prosthetic hip types.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2Widget(tester);

      await setupToVerifyProstheticCheckbox(tester);

      final pneumaticFinder = findByTypeAndKey(
          Key('prostheticHip_${ProstheticHipType.pneumatic.index}'));
      final hydraulicFinder = findByTypeAndKey(
          Key('prostheticHip_${ProstheticHipType.hydraulic.index}'));

      await tapAndSettle(tester, pneumaticFinder);

      // Verify hydraulic unchecked when pneumatic checked
      expect(tester.widget<Checkbox>(pneumaticFinder).value, true);
      expect(tester.widget<Checkbox>(hydraulicFinder).value, false);

      await tapAndSettle(tester, hydraulicFinder);

      // Verify pneumatic unchecked when hydraulic checked
      expect(tester.widget<Checkbox>(pneumaticFinder).value, false);
      expect(tester.widget<Checkbox>(hydraulicFinder).value, true);
    });

    /// **Test ID**: TC-LERC-006Y
    /// **Objective**: Verify the functionality of the socket type check boxes.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap all socket type checkboxes to mark them as checked.
    ///   2. Tap all socket type checkboxes again to mark them as unchecked.
    /// **Automated**: Yes
    testWidgets('TC-LERC-006Y - Verify the functionality of the socket type check boxes.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpPage2Widget(tester);

      await tapInfoAndCheckDialog(tester, 'socketType');

      // Check all checkboxes
      for (final value in SocketType.values) {
        await verifyCheckBoxState(tester, CheckboxType.socketType, value, true);
      }

      // Uncheck all checkboxes
      for (final value in SocketType.values) {
        await verifyCheckBoxState(
            tester, CheckboxType.socketType, value, false);
      }
    });

    /// **Test ID**: TC-LERC-006Z
    /// **Objective**: Verify that the liner drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap liner drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap liner drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006Z - Verify that the liner drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpPage2Widget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('liner'));

      expect(targetWidget, findsOneWidget);

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over Liner values and verify that each option is displayed
      for (final value in Liner.values) {
        expect(find.text(value.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(3));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in Liner.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));
        expect(find.text(value.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LERC-006AA
    /// **Objective**: Verify that the suspension drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap suspension drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap suspension drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-006AA - Verify that the suspension drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpPage2Widget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('suspension'));

      expect(targetWidget, findsOneWidget);

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over Suspension values and verify that each option is displayed
      for (final value in Suspension.values) {
        expect(find.text(value.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(3));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in Suspension.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));
        expect(find.text(value.displayName), findsOneWidget);
      }
    });
  });

  group(
      'Verify that the user can correctly edit Episode of Rehab Care responses and any changes triggers its modify state in page 1',
      () {
    /// **Test ID**: TC-LERC-004A
    /// **Objective**: Verify the state of update button when height/weight is updated.
    /// **Preconditions**: Height/weight is set.
    /// **Test Steps**:
    ///   1. Find and drag height pointer to a specific point.
    ///   2. Find and tap 'Next' button to navigate to page 2.
    ///   3. Observe the update button color is red.
    ///   4. Tap back button to navigate back to page 1.
    ///   5. Enter the original value to the text input field and make sure the change is reverted.
    ///   6. Tap 'Next' button and observe the update button color is grey.
    ///   7. Tap back button to navigate back to page 1.
    ///   8. Repeat the same steps for weight value.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-004A - Verify the state of update button when height/weight is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpMainWidgetOnEdit(tester);

      final heightPointer = find.byKey(const Key('height_pointer'));
      final heightTextCmText = find.byKey(const Key('cm_text'));

      // Verify update button is enabled when making a change.
      await tester.drag(heightPointer, const Offset(-100, 0));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, updateButton);
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Navigate back to page 1.
      await tapAndSettle(tester, backButton);
      expect(find.text('Episode of Rehabilitation Care (1/2)'), findsOneWidget);

      // Verify update button is disabled when reverting the change.
      await tester.enterText(heightTextCmText, '180');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tapAndSettle(tester, updateButton);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));

      // Navigate back to page 1.
      await tapAndSettle(tester, backButton);
      expect(find.text('Episode of Rehabilitation Care (1/2)'), findsOneWidget);

      final weightPointer = find.byKey(const Key('weight_pointer'));
      final weightText = find.byKey(const Key('weight_text'));

      // Verify update button is enabled when making a change.
      await tester.drag(weightPointer, const Offset(-100, 0));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, updateButton);
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Navigate back to page 1.
      await tapAndSettle(tester, backButton);
      expect(find.text('Episode of Rehabilitation Care (1/2)'), findsOneWidget);

      // Verify update button is disabled when reverting the change.
      await tester.enterText(weightText, '68');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tapAndSettle(tester, updateButton);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LERC-004B
    /// **Objective**: Verify the state of update button when tobacco usage drop down item is updated.
    /// **Preconditions**: One of items under tobacco usage drop down menu is selected.
    /// **Test Steps**:
    ///   1. Find and tap tobacco usage drop down menu.
    ///   2. Tap another item.
    ///   3. Find and tap 'Next' button to navigate to page 2.
    ///   4. Observe the update button color is red.
    ///   5. Tap back button to navigate back to page 1.
    ///   6. Tap tobacco usage drop down menu again, tap the original item and make sure the change is reverted.
    ///   7. Tap 'Next' button and observe the update button color is grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-004B - Verify the state of update button when tobacco usage drop down item is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpMainWidgetOnEdit(tester);

      final targetWidget = find.byKey(const Key('tobaccoUsage'));

      // Verify update button is enabled when making a change.
      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'tobaccoUsage_${TobaccoUsage.dailyOrAlmostDaily.displayName}')));
      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Navigate back to page 1.
      await tapAndSettle(tester, backButton);
      expect(find.text('Episode of Rehabilitation Care (1/2)'), findsOneWidget);

      // Verify update button is disabled when reverting the change.
      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('tobaccoUsage_${TobaccoUsage.never.displayName}')));
      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LERC-004C
    /// **Objective**: Verify the state of update button when max education drop down item is updated.
    /// **Preconditions**: One of items under max education drop down menu is selected.
    /// **Test Steps**:
    ///   1. Find and tap max education drop down menu.
    ///   2. Tap another item.
    ///   3. Find and tap 'Next' button to navigate to page 2.
    ///   4. Observe the update button color is red.
    ///   5. Tap back button to navigate back to page 1.
    ///   6. Tap max education drop down menu again, tap the original item and make sure the change is reverted.
    ///   7. Tap 'Next' button and observe the update button color is grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-004C - Verify the state of update button when max education drop down item is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpMainWidgetOnEdit(tester);

      final targetWidget = find.byKey(const Key('maxEducation'));

      // Verify update button is enabled when making a change.
      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'maxEducation_${MaxEducationLevel.postgraduateDegree.displayName}')));
      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Navigate back to page 1.
      await tapAndSettle(tester, backButton);
      expect(find.text('Episode of Rehabilitation Care (1/2)'), findsOneWidget);

      // Verify update button is disabled when reverting the change.
      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'maxEducation_${MaxEducationLevel.noFormalEducation.displayName}')));
      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LERC-004D
    /// **Objective**: Verify the state of update button when ICD code is updated.
    /// **Preconditions**: ICD code is set.
    /// **Test Steps**:
    ///   1. Find and tap ICD code text input field to enter some text.
    ///   3. Find and tap 'Next' button to navigate to page 2.
    ///   4. Observe the update button color is red.
    ///   5. Tap back button to navigate back to page 1.
    ///   6. Tap the text input field again, enter the original value and make sure the change is reverted.
    ///   7. Tap 'Next' button and observe the update button color is grey.
    /// **Automated**: Yes
    testWidgets('TC-LERC-004D - Verify the state of update button when ICD code is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpMainWidgetOnEdit(tester);

      final targetWidget = find.byKey(const Key('icdCodesOfConditions'));

      // Verify update button is enabled when making a change.
      await tapAndSettle(tester, targetWidget);
      await tester.enterText(targetWidget, 'B001');

      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Navigate back to page 1.
      await tapAndSettle(tester, backButton);
      expect(find.text('Episode of Rehabilitation Care (1/2)'), findsOneWidget);

      // Verify update button is disabled when reverting the change.
      await tapAndSettle(tester, targetWidget);
      await tester.enterText(targetWidget, 'A001');
      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LERC-004E
    /// **Objective**: Verify the state of update button when professions checkbox is updated.
    /// **Preconditions**: Professions checkbox is filled.
    /// **Test Steps**:
    ///   1. Tap one of options to mark it as checked.
    ///   3. Find and tap 'Next' button to navigate to page 2.
    ///   4. Observe the update button color is red.
    ///   5. Tap back button to navigate back to page 1.
    ///   6. Tap the checkbox again to mark it as unchecked and make sure the change is reverted.
    ///   7. Tap 'Next' button and observe the update button color is grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-004E - Verify the state of update button when professions checkbox is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpMainWidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(tester, CheckboxType.profession,
          Profession.occupationalTherapist, true);
      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Navigate back to page 1.
      await tapAndSettle(tester, backButton);
      expect(find.text('Episode of Rehabilitation Care (1/2)'), findsOneWidget);

      // Verify update button is disabled when reverting the change.
      await verifyCheckBoxState(tester, CheckboxType.profession,
          Profession.occupationalTherapist, false);
      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LERC-004F
    /// **Objective**: Verify the state of update button when rehabilitation services checkbox and following questions are updated.
    /// **Preconditions**: 'Compression therapy' is checked, 'Other' is checked under compression therapy section, and some text is entered to the text input field.
    /// **Test Steps**:
    ///   1. Tap 'Compression therapy' to mark is as unchecked.
    ///   3. Find and tap 'Next' button to navigate to page 2.
    ///   4. Observe the update button color is red.
    ///   5. Tap back button to navigate back to page 1.
    ///   6. Tap the checkbox again to mark it as checked to revert the change.
    ///   7. Tap 'Next' button and observe the update button color is still red.
    ///   8. Tap back button to navigate back to page 1.
    ///   9. Tap 'Other' under compression therapy section to mark it as checked.
    ///   10. Enter the original text value to text input field and make sure the change is reverted.
    ///   11. Tap 'Next' button and observe the update button color is grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-004F - Verify the state of update button when rehabilitation services checkbox and following questions are updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpMainWidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(tester, CheckboxType.rehabilitationServices,
          RehabilitationServices.compressionTherapy, false);
      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Navigate back to page 1.
      await tapAndSettle(tester, backButton);
      expect(find.text('Episode of Rehabilitation Care (1/2)'), findsOneWidget);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(tester, CheckboxType.rehabilitationServices,
          RehabilitationServices.compressionTherapy, true);
      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Navigate back to page 1.
      await tapAndSettle(tester, backButton);
      expect(find.text('Episode of Rehabilitation Care (1/2)'), findsOneWidget);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(
          tester, CheckboxType.ct, CompressionTherapy.other, true);
      await tester.enterText(
          find.byKey(const Key('ct_other')), 'ct other text');
      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LERC-004G
    /// **Objective**: Verify the state of update button when prosthetic interventions drop down item is updated.
    /// **Preconditions**: One of items under prosthetic interventions drop down menu is selected.
    /// **Test Steps**:
    ///   1. Find and tap prosthetic interventions drop down menu.
    ///   2. Tap another item.
    ///   3. Find and tap 'Next' button to navigate to page 2.
    ///   4. Observe the update button color is red.
    ///   5. Tap back button to navigate back to page 1.
    ///   6. Tap prosthetic interventions drop down menu again, tap the original item and make sure the change is reverted.
    ///   7. Tap 'Next' button and observe the update button color is grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-004G - Verify the state of update button when prosthetic interventions drop down item is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpMainWidgetOnEdit(tester);

      final targetWidget = find.byKey(const Key('prostheticIntervention'));

      // Verify update button is enabled when making a change.
      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'prostheticIntervention_${ProstheticIntervention.repairAdjustments.displayName}')));
      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Navigate back to page 1.
      await tapAndSettle(tester, backButton);
      expect(find.text('Episode of Rehabilitation Care (1/2)'), findsOneWidget);

      // Verify update button is disabled when reverting the change.
      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'prostheticIntervention_${ProstheticIntervention.prosthesis.displayName}')));
      await tapAndSettle(tester, updateButton);
      expect(find.text('Episode of Rehabilitation Care (2/2)'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });
  });

  group(
      'Verify that the user can correctly edit Episode of Rehab Care responses and any changes triggers its modify state in page 2',
      () {
    /// **Test ID**: TC-LERC-004H
    /// **Objective**: Verify the state of update button when the date is updated.
    /// **Preconditions**: Date of delivery is set.
    /// **Test Steps**:
    ///   1. Find and tap date icon.
    ///   2. Change date.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap date icon again, change date to the original and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets('TC-LERC-004H - Verify the state of update button when the date is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2WidgetOnEdit(tester);

      // Find the date icon button
      final dateIconButton =
          findByTypeAndKey<IconButton>(const Key('dateOfDelivery'));

      await changeDate(tester, dateIconButton, '1/5/1968');
      expect(find.text('1968-01-05'), findsOneWidget);

      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      await changeDate(tester, dateIconButton, '10/10/2000');
      expect(find.text('2000-10-10'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LERC-004I
    /// **Objective**: Verify the state of update button when socket drop down item and following questions are updated.
    /// **Preconditions**: One of items under socket drop down menu is selected, one of items under design drop down menu is selected if needed, and one of checkboxes under prosthetic foot, knee or hip is selected if needed.
    /// **Test Steps**:
    ///   1. Find and tap socket drop down menu.
    ///   2. Tap another item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap socket drop down menu again, tap the original item to revert the change.
    ///   5. Tap design drop down menu and tap the original item.
    ///   6. Select checkboxes under prosthetic foot, knee, or hip to mark it as checked and make sure the change is reverted.
    ///   7. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-004I - Verify the state of update button when socket drop down item and following questions are updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2WidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      final targetWidget = find.byKey(const Key('socket'));
      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(tester,
          find.byKey(Key('socket_${Socket.ankleDisarticulation.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester, find.byKey(Key('socket_${Socket.partialFoot.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await tapAndSettle(tester, find.byKey(const Key('partialFoot_design')));
      await tapAndSettle(
          tester,
          find.byKey(Key(
              'partialFoot_design_${PartialFootDesign.withinShoe.displayName}')));
      await verifyCheckBoxState(tester, CheckboxType.prostheticFoot,
          ProstheticFootType.hardRubberBareFootDesign, true);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LERC-004J
    /// **Objective**: Verify the state of update button when socket type drop down item is updated.
    /// **Preconditions**: One of items under socket type drop down menu is selected.
    /// **Test Steps**:
    ///   1. Find and tap socket type drop down menu.
    ///   2. Tap another item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap socket type drop down menu again, tap the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-004J - Verify the state of update button when socket type drop down item is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2WidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(tester, CheckboxType.socketType,
          SocketType.fiberglassLamination, false);
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await verifyCheckBoxState(tester, CheckboxType.socketType,
          SocketType.fiberglassLamination, true);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LERC-004K
    /// **Objective**: Verify the state of update button when liner drop down item is updated.
    /// **Preconditions**: One of items under liner drop down menu is selected.
    /// **Test Steps**:
    ///   1. Find and tap liner drop down menu.
    ///   2. Tap another item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap liner drop down menu again, tap the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-004K - Verify the state of update button when liner drop down item is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2WidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      final targetWidget = find.byKey(const Key('liner'));
      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('liner_${Liner.foamPelite.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('liner_${Liner.noLiner.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LERC-004L
    /// **Objective**: Verify the state of update button when suspension drop down item is updated.
    /// **Preconditions**: One of items under suspension drop down menu is selected.
    /// **Test Steps**:
    ///   1. Find and tap suspension drop down menu.
    ///   2. Tap another item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap suspension drop down menu again, tap the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LERC-004L - Verify the state of update button when suspension drop down item is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpPage2WidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      final targetWidget = find.byKey(const Key('suspension'));
      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('suspension_${Suspension.expulsionValve.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('suspension_${Suspension.selfSuspending.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });
  });

  /// **Test ID**: TC-LERC-007
  /// **Objective**: Verify user is notified for any cloud communication error when 'Finished' button is tapped.
  /// **Preconditions**: Make sure the page 2 is loaded.
  /// **Test Steps**:
  ///   1. Find and tap Finish button.
  ///   2. Observe the incomplete prompt is displayed, and tap 'Yes, continue' to proceed.
  ///   3. Observe the loading indicator is visible.
  ///   4. Observe the loading indicator is invisible after a few seconds.
  ///   5. Observe the indicator for pdf generating is visible.
  ///   6. Observe the indicator for pdf generating is invisible.
  /// **Automated**: Yes
  testWidgets(
      'TC-LERC-007 - Verify user is notified for any cloud communication error when \'Finished\' button is tapped.',
      (WidgetTester tester) async {
    await setScreenSize(tester, const Size(768, 1024));

    await pumpPage2Widget(tester);

    await tapAndSettle(
        tester, findByTypeAndKey<Container>(const Key('nextButton')));

    expect(find.byType(ConfirmAlertDialog), findsOneWidget);

    when(service.addEncounterWithDetails(encounter, patient.value)).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 5),
            () => throw ServerErrorException(http.Response('', 500))));

    when(pdfService.exportPdf(encounter, patient.value,
            saveToDocDir: true, locale: 'en'))
        .thenAnswer((_) async => Future.delayed(const Duration(seconds: 5),
            () => MergeMultiplePDFResponse(status: "success", response: '')));

    // Tap 'Yes, continue' on the dialog for incomplete dialog
    await tester.tap(find.byKey(const Key('secondaryButton')));
    await tester.pump();
    expect(loadingIndicatorDialog, findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
    expect(loadingIndicatorDialog, findsNothing);
    expect(busyDialog, findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 300));
    expect(busyDialog, findsNothing);
  });

  /// **Test ID**: TC-LERC-003
  /// **Objective**: Verify all Episode of Rehabilitation Care questionsare optional to be completed.
  /// **Preconditions**: None.
  /// **Test Steps**:
  ///   1. Make sure all questions in page 1 are not answered and tap 'Next' button.
  ///   2. Make sure all questions in page 2 are not answered and tap 'Finish' button.
  /// **Automated**: Yes
  testWidgets(
      'TC-LERC-003 - Verify all Episode of Rehabilitation Care questionsare optional to be completed.',
      (WidgetTester tester) async {
    amputations.add(Amputation(side: AmputationSide.hemicorporectomy));

    await setScreenSize(tester, const Size(768, 1024));

    await pumpMainWidget(tester);

    await tapAndSettle(tester, nextButton);

    expect(tester.takeException(), isNull);

    await tester.tap(nextButton);

    expect(tester.takeException(), isNull);
  });
}
