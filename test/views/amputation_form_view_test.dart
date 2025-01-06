import 'package:biot/app/app.dialogs.dart';
import 'package:biot/app/app.locator.dart';
import 'package:biot/app/app.router.dart';
import 'package:biot/constants/amputation_info.dart';
import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/model/amputation.dart';
import 'package:biot/services/cloud_service.dart';
import 'package:biot/services/database_service.dart';
import 'package:biot/services/logger_service.dart';
import 'package:biot/ui/common/app_colors.dart';
import 'package:biot/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:biot/ui/dialogs/loading_indicator/loading_indicator_dialog.dart';
import 'package:biot/ui/views/amputation_form/amputation_form_view.dart';
import 'package:biot/ui/widgets/amputation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:http/http.dart' as http;

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  late var mockLoggerService;
  late BiotService service;
  late ReactiveValue<MockPatient> patient;
  late List<Amputation> amputations;

  setUp(() async {
    getAndRegisterBottomSheetService();
    getAndRegisterBiotService();
    getAndRegisterLocaldbService();
    getAndRegisterLoggerService();
    StackedLocator.instance.registerLazySingleton(() => NavigationService());
    StackedLocator.instance.registerLazySingleton(() => DialogService());
    setupDialogUi();

    mockLoggerService = locator<LoggerService>();
    when(mockLoggerService.getLogger(any))
        .thenReturn(Logger(printer: SimplePrinter(), output: ConsoleOutput()));

    service = locator<BiotService>();
    patient = ReactiveValue<MockPatient>(MockPatient());
    final localdbService = locator<DatabaseService>();
    when(localdbService.currentPatient).thenReturn(patient);

    MockAmputation mockAmp = MockAmputation();
    when(mockAmp.side).thenReturn(AmputationSide.left);
    amputations = [mockAmp];
    when(patient.value.amputations).thenReturn(amputations);
  });

  tearDown(() => unregisterService());

  // Function to tap a widget and wait for frame to build
  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapDropDownMenuAndSelect(
      WidgetTester tester, Finder finder, String targetText) async {
    final textFinder = find.text(targetText).last;
    await tapAndSettle(tester, finder);
    await tapAndSettle(tester, textFinder);
    expect(textFinder, findsOneWidget);
  }

  // Test tapping info button
  // Verify a dialog view is displayed
  // Verify the dialog view is dismissible when tapped outside
  // Verify the dialog view is dismissible when tapped 'Close' button
  Future<void> testDialogButton(
      WidgetTester tester, Finder finder, List<String> closeButtonTexts) async {
    // Verify a dialog view is displayed
    await tapAndSettle(tester, finder);
    expect(find.byType(Dialog), findsOneWidget);

    // Verify the dialog view is dismissible when tapped outside
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);

    // Verify that each button triggers the dialog to dismiss
    for (var i = 0; i < closeButtonTexts.length; i++) {
      // Open the dialog again
      await tapAndSettle(tester, finder);

      final closeButton = find.text(closeButtonTexts[i]);
      expect(closeButton, findsOneWidget);
      await tapAndSettle(tester, closeButton);
      expect(find.byType(Dialog), findsNothing);
    }
  }

  Future<void> changeDate(
      WidgetTester tester, Finder dateFormField, String date) async {
    final inputSwitch = find.byWidgetPredicate((Widget w) =>
        w is IconButton && (w.tooltip?.startsWith('Switch to input') ?? false));
    await tapAndSettle(tester, inputSwitch);
    final textField = find.byWidgetPredicate((Widget w) =>
        w is TextField &&
        (w.decoration?.labelText?.startsWith('Enter Date') ?? false));
    await tester.enterText(textField, date);
    await tapAndSettle(tester, find.text('OK'));
  }

  // Test filling out amputation info form
  testWidgets('Test filling out amputation info form',
      (WidgetTester tester) async {
    const Size screenSize =
        Size(768, 1024); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);

    await tester.pumpWidget(MaterialApp(
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        home: const AmputationFormView(isEdit: false)));

    // Check initial state of the view
    // There should be only one Amputation Card widget
    final amputationCardFinder = find.byType(AmputationCard);
    expect(amputationCardFinder, findsOneWidget);

    // Verify all info buttons are visible and functions properly when tapped
    List<String> infoKeys = const [
      'side',
      'level',
      'date',
      'cause',
      'type',
      'abilityToWalk'
    ];
    for (int i = 0; i < infoKeys.length; i++) {
      final infoButtonFinder = find.byKey(Key('${infoKeys[i]}Info_0'));
      expect(infoButtonFinder, findsOneWidget);
      await testDialogButton(tester, infoButtonFinder, ['Close']);
    }

    // Verify date form field
    final dateFinder = find.byKey(const Key('dateFormField_0'));
    expect(dateFinder, findsOneWidget);
    await tapAndSettle(tester, dateFinder);
    expect(find.byType(DatePickerDialog), findsOneWidget);

    // Verify selected date in the form field
    await changeDate(tester, dateFinder, '1/5/1968');
    expect(find.text('1968-01-05'), findsOneWidget);

    final ampSide = find.byKey(const Key('sideDropDownMenu_0'));
    expect(ampSide, findsOneWidget);
    // Tap dropdown menu and tap each option and
    // verify that the selected item is displayed
    for (final side in AmputationSide.values) {
      if (side == AmputationSide.hemicorporectomy) {
        continue;
      }
      await tapDropDownMenuAndSelect(tester, ampSide, side.displayName);
    }

    final ampLevel = find.byKey(const Key('levelDropDownMenu_0'));
    expect(ampLevel, findsOneWidget);
    // Tap dropdown menu and tap each option and
    // verify that the selected item is displayed
    for (final level in LevelOfAmputation.values) {
      final textFinder = find.text(level.displayName);
      await tapAndSettle(tester, ampLevel);
      await tapAndSettle(tester, textFinder);
      if (level.displayName == 'Hemicorporectomy') {
        expect(textFinder, findsNWidgets(2));
      } else {
        expect(textFinder, findsOneWidget);
      }
    }

    await tapAndSettle(tester, ampLevel);
    await tapAndSettle(
        tester, find.text(LevelOfAmputation.toeAmputation.displayName));

    final ampType = find.byKey(const Key('typeDropDownMenu_0'));
    expect(ampType, findsOneWidget);
    // Tap dropdown menu and tap each option and
    // verify that the selected item is displayed
    for (final type in TypeOfAmputation.values) {
      await tapDropDownMenuAndSelect(tester, ampType, type.displayName);
    }

    final ampCause = find.byKey(const Key('causeDropDownMenu_0'));
    expect(ampCause, findsOneWidget);
    // Tap dropdown menu and tap each option and
    // verify that the selected item is displayed
    for (final cause in CauseOfAmputation.values) {
      await tapDropDownMenuAndSelect(tester, ampCause, cause.displayName);
    }

    final abilityToWalk = find.byKey(const Key('abilityToWalkDropDownMenu_0'));
    expect(abilityToWalk, findsOneWidget);
    // Tap dropdown menu and tap each option and
    // verify that the selected item is displayed
    for (final response in YesOrNo.values) {
      await tapDropDownMenuAndSelect(
          tester, abilityToWalk, response.displayName);
    }

    // Verify entered inputs are validated when the 'Next' button is tapped
    final nextButton = find.text('next');
    await tapAndSettle(tester, nextButton);
    final errorText = find.byWidgetPredicate((Widget w) =>
        w is Text && (w.data?.contains(RegExp(r'\b[Rr]equired\b')) ?? false));
    expect(errorText, findsNothing);

    // Verify back button is displayed and prompts properly when tapped
    final closeButton = find.byKey(const Key('closeButton'));
    final backButton = find.byKey(const Key('backButton'));
    expect(closeButton, findsNothing);
    expect(backButton, findsOneWidget);
    await testDialogButton(tester, backButton, ['Cancel', 'Exit']);
  });

  testWidgets('Test no input error', (WidgetTester tester) async {
    const Size screenSize =
        Size(768, 1024); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);

    await tester.pumpWidget(MaterialApp(
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        home: const AmputationFormView(isEdit: false)));

    final nextButton = find.text('next');
    await tapAndSettle(tester, nextButton);
    final errorText = find.byWidgetPredicate((Widget w) =>
        w is Text && (w.data?.contains(RegExp(r'\b[Rr]equired\b')) ?? false));
    expect(errorText, findsNWidgets(6));
  });

  testWidgets('Test adding and removing amputation',
      (WidgetTester tester) async {
    const Size screenSize =
        Size(768, 1024); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);

    await tester.pumpWidget(MaterialApp(
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        home: const AmputationFormView(isEdit: false)));

    final attentionText = find.byWidgetPredicate((Widget w) =>
        w is Text && (w.data?.contains(RegExp(r'\bAttention\b')) ?? false));
    final otherSide = find.text('Add Other Side');
    await tapAndSettle(tester, otherSide);
    expect(find.byType(AmputationCard), findsNWidgets(2));
    expect(attentionText, findsNothing);
    expect(otherSide, findsNothing);

    final removeButton = find.byKey(const Key('removeAmputation_0'));
    await tapAndSettle(tester, removeButton);
    expect(find.byType(AmputationCard), findsOneWidget);
    expect(otherSide, findsOneWidget);
    expect(removeButton, findsNothing);
  });

  testWidgets('Test adding amputations with same side',
      (WidgetTester tester) async {
    Amputation ampLeft = Amputation()
      ..level = LevelOfAmputation.toeAmputation
      ..type = TypeOfAmputation.majorAmputation
      ..cause = CauseOfAmputation.cancer
      ..abilityToWalk = YesOrNo.no
      ..dateOfAmputation = DateTime(2020, 2, 3)
      ..side = AmputationSide.left;
    Amputation ampRight = Amputation()
      ..level = LevelOfAmputation.toeAmputation
      ..type = TypeOfAmputation.majorAmputation
      ..cause = CauseOfAmputation.cancer
      ..abilityToWalk = YesOrNo.no
      ..dateOfAmputation = DateTime(2020, 2, 3)
      ..side = AmputationSide.right;
    amputations = [ampLeft, ampRight];
    when(patient.value.amputations).thenReturn(amputations);
    const Size screenSize =
        Size(768, 1024); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);

    await tester.pumpWidget(MaterialApp(
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        home: const AmputationFormView(isEdit: true)));

    // Verify side change triggers modified state
    final ampLeftSide = find.byKey(const Key('sideDropDownMenu_0'));
    final ampRightSide = find.byKey(const Key('sideDropDownMenu_1'));
    final updateButton = find.byKey(const Key('nextUpdateButton'));
    final errorText = find.text('Amputation side must be distinct.');
    expect(ampLeftSide, findsOneWidget);
    expect(ampRightSide, findsOneWidget);

    // Change both Left and Right amputation card's side to left
    await tapDropDownMenuAndSelect(
        tester, ampLeftSide, AmputationSide.left.displayName);
    await tapDropDownMenuAndSelect(
        tester, ampRightSide, AmputationSide.left.displayName);
    // Verify two left amputations trigger invalid input error
    await tapAndSettle(tester, updateButton);
    expect(errorText, findsNWidgets(2));

    // Change both Left and Right amputation card's side to right
    await tapDropDownMenuAndSelect(
        tester, ampLeftSide, AmputationSide.right.displayName);
    await tapDropDownMenuAndSelect(
        tester, ampRightSide, AmputationSide.right.displayName);
    // Verify two left amputations trigger invalid input error
    await tapAndSettle(tester, updateButton);
    expect(errorText, findsNWidgets(2));
  });

  testWidgets('Test adding amputation with hemicorporectomy level',
      (WidgetTester tester) async {
    const Size screenSize =
        Size(768, 1024); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);

    await tester.pumpWidget(MaterialApp(
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        home: const AmputationFormView(isEdit: false)));

    final ampLevel = find.byKey(const Key('levelDropDownMenu_0'));
    await tapDropDownMenuAndSelect(
        tester, ampLevel, LevelOfAmputation.hemicorporectomy.displayName);
    final ampSide = find.byKey(const Key('sideDropDownMenu_0'));
    await tapDropDownMenuAndSelect(
        tester, ampSide, AmputationSide.hemicorporectomy.displayName);
    final ampDate = find.byKey(const Key('dateFormField_0'));
    await tapAndSettle(tester, ampDate);
    await changeDate(tester, ampDate, '2/6/2020');
    final ampType = find.byKey(const Key('typeDropDownMenu_0'));
    await tapDropDownMenuAndSelect(
        tester, ampType, TypeOfAmputation.majorAmputation.displayName);
    final ampCause = find.byKey(const Key('causeDropDownMenu_0'));
    await tapDropDownMenuAndSelect(
        tester, ampCause, CauseOfAmputation.congenital.displayName);
    final abilityToWalk = find.byKey(const Key('abilityToWalkDropDownMenu_0'));
    await tapDropDownMenuAndSelect(
        tester, abilityToWalk, YesOrNo.yes.displayName);

    final attentionText = find.byWidgetPredicate((Widget w) =>
        w is Text && (w.data?.contains(RegExp(r'\bAttention\b')) ?? false));
    final otherSide = find.text('Add Other Side');
    expect(attentionText, findsNothing);
    expect(otherSide, findsNothing);
  });

  // Test editing amputation info form for Pre episode encounter
  testWidgets('Test editing amputation info for pre episode track',
      (WidgetTester tester) async {
    Amputation amp = Amputation()
      ..level = LevelOfAmputation.toeAmputation
      ..type = TypeOfAmputation.majorAmputation
      ..cause = CauseOfAmputation.cancer
      ..abilityToWalk = YesOrNo.no
      ..dateOfAmputation = DateTime(2020, 2, 3)
      ..side = AmputationSide.left;
    amputations = [amp];
    when(patient.value.amputations).thenReturn(amputations);

    const Size screenSize =
        Size(768, 1024); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);

    await tester.pumpWidget(MaterialApp(
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        home: const AmputationFormView(isEdit: true)));
    final sideFinder = find.text(AmputationSide.left.displayName);
    final levelFinder = find.text(LevelOfAmputation.toeAmputation.displayName);
    final typeFinder = find.text(TypeOfAmputation.majorAmputation.displayName);
    final causeFinder = find.text(CauseOfAmputation.cancer.displayName);
    final abilityToWalkFinder = find.text(YesOrNo.no.displayName);
    final dateFinder = find.text('2020-02-03');
    expect(sideFinder, findsOneWidget);
    expect(levelFinder, findsOneWidget);
    expect(typeFinder, findsOneWidget);
    expect(causeFinder, findsOneWidget);
    expect(abilityToWalkFinder, findsOneWidget);
    expect(dateFinder, findsOneWidget);

    // Verify that 'Next' button is changed to 'Update'
    final nextUpdateButton = find.byKey(const Key('nextUpdateButton'));
    final updateFinder = find.text('Update');
    final nextFinder = find.text('next');
    expect(updateFinder, findsOneWidget);
    expect(nextFinder, findsNothing);
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(Colors.grey));

    // Verify level change triggers modified state
    final ampLevel = find.byKey(const Key('levelDropDownMenu_0'));
    expect(ampLevel, findsOneWidget);
    await tapDropDownMenuAndSelect(
        tester, ampLevel, LevelOfAmputation.kneeDisarticulation.displayName);

    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(kcBackgroundColor));

    await tapDropDownMenuAndSelect(
        tester, ampLevel, LevelOfAmputation.toeAmputation.displayName);
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(Colors.grey));

    // Verify side change triggers modified state
    final ampSide = find.byKey(const Key('sideDropDownMenu_0'));
    expect(ampSide, findsOneWidget);
    await tapDropDownMenuAndSelect(
        tester, ampSide, AmputationSide.right.displayName);
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(kcBackgroundColor));

    await tapDropDownMenuAndSelect(
        tester, ampSide, AmputationSide.left.displayName);
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(Colors.grey));

    // Verify type change triggers modified state
    final ampType = find.byKey(const Key('typeDropDownMenu_0'));
    expect(ampType, findsOneWidget);
    await tapDropDownMenuAndSelect(
        tester, ampType, TypeOfAmputation.boneRevisionAtSameLevel.displayName);
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(kcBackgroundColor));

    await tapDropDownMenuAndSelect(
        tester, ampType, TypeOfAmputation.majorAmputation.displayName);
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(Colors.grey));

    // Verify cause change triggers modified state
    final ampCause = find.byKey(const Key('causeDropDownMenu_0'));
    expect(ampCause, findsOneWidget);
    await tapDropDownMenuAndSelect(
        tester, ampCause, CauseOfAmputation.diabetes.displayName);
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(kcBackgroundColor));

    await tapDropDownMenuAndSelect(
        tester, ampCause, CauseOfAmputation.cancer.displayName);
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(Colors.grey));

    // Verify ability to walk change triggers modified state
    final abilityToWalk = find.byKey(const Key('abilityToWalkDropDownMenu_0'));
    expect(abilityToWalk, findsOneWidget);
    await tapDropDownMenuAndSelect(
        tester, abilityToWalk, YesOrNo.yes.displayName);
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(kcBackgroundColor));

    await tapDropDownMenuAndSelect(
        tester, abilityToWalk, YesOrNo.no.displayName);
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(Colors.grey));

    // Verify date change triggers modified state
    final dateFormFieldFinder = find.byKey(const Key('dateFormField_0'));
    await tapAndSettle(tester, dateFormFieldFinder);
    await changeDate(tester, dateFormFieldFinder, '1/5/1968');
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(kcBackgroundColor));
    await tapAndSettle(tester, dateFormFieldFinder);
    await changeDate(tester, dateFormFieldFinder, '2/3/2020');
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(Colors.grey));
  });

  // Test editing amputation info form for subsequent amputation status change
  testWidgets(
      'Test adding edited amputation info for subsequent amputation status change',
      (WidgetTester tester) async {
    Amputation amp = Amputation()
      ..level = LevelOfAmputation.toeAmputation
      ..type = TypeOfAmputation.majorAmputation
      ..cause = CauseOfAmputation.cancer
      ..abilityToWalk = YesOrNo.no
      ..dateOfAmputation = DateTime(2020, 2, 3)
      ..side = AmputationSide.left;
    amputations = [amp];
    Amputation changedAmp = amp.clone();
    changedAmp.level = LevelOfAmputation.kneeDisarticulation;
    when(patient.value.amputations).thenReturn(amputations);
    when(service.addAmputation(changedAmp, patient: patient.value)).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 5), () => true));

    const Size screenSize =
        Size(768, 1024); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);

    await tester.pumpWidget(MaterialApp(
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        home: const AmputationFormView(
          isEdit: true,
          shouldUpdateCloud: true,
        )));

    // Verify that 'Next' button is changed to 'Update'
    final nextUpdateButton = find.byKey(const Key('nextUpdateButton'));
    final updateFinder = find.text('Update');
    final nextFinder = find.text('next');
    expect(updateFinder, findsOneWidget);
    expect(nextFinder, findsNothing);
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(Colors.grey));

    final ampLevel = find.byKey(const Key('levelDropDownMenu_0'));
    await tapDropDownMenuAndSelect(
        tester, ampLevel, LevelOfAmputation.kneeDisarticulation.displayName);
    expect((tester.widget(nextUpdateButton) as Container).color,
        equals(kcBackgroundColor));

    await tester.tap(nextUpdateButton);
    await tester.pump();
    final loadingIndicatorDialog = find.byType(LoadingIndicatorDialog);
    expect(loadingIndicatorDialog, findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    expect(loadingIndicatorDialog, findsNothing);

    when(service.addAmputation(changedAmp, patient: patient.value)).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 5),
            () => throw BadRequestException(http.Response('', 404))));

    await tester.tap(nextUpdateButton);
    await tester.pump();
    expect(loadingIndicatorDialog, findsOneWidget);

    final errorDialog = find.byType(InfoAlertDialog);
    await tester.pump(const Duration(seconds: 5));
    expect(loadingIndicatorDialog, findsNothing);
    expect(errorDialog, findsOneWidget);
    final closeButton = find.text('Close');
    await tapAndSettle(tester, closeButton);


    when(service.addAmputation(changedAmp, patient: patient.value)).thenAnswer(
            (_) => Future.delayed(const Duration(seconds: 5),
                () => throw ServerErrorException(http.Response('', 500))));

    await tester.tap(nextUpdateButton);
    await tester.pump();
    expect(loadingIndicatorDialog, findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    expect(loadingIndicatorDialog, findsNothing);
    expect(errorDialog, findsOneWidget);
    await tapAndSettle(tester, closeButton);

    when(service.addAmputation(changedAmp, patient: patient.value)).thenAnswer(
            (_) => Future.delayed(const Duration(seconds: 5),
                () => throw http.ClientException('')));

    await tester.tap(nextUpdateButton);
    await tester.pump();
    expect(loadingIndicatorDialog, findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    expect(loadingIndicatorDialog, findsNothing);
    expect(errorDialog, findsOneWidget);
    await tapAndSettle(tester, closeButton);
  });
}
