import 'package:biot/app/app.dialogs.dart';
import 'package:biot/app/app.locator.dart';
import 'package:biot/app/app.router.dart';
import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/model/encounter.dart';
import 'package:biot/model/pre_post_episode_of_care.dart';
import 'package:biot/services/logger_service.dart';
import 'package:biot/ui/common/app_colors.dart';
import 'package:biot/ui/views/pre_post/pre_post_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  late var mockLoggerService;

  late Encounter encounter;
  late PrePostEpisodeOfCare prePostEpisodeOfCare;

  setUp(() {
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

    encounter = MockEncounter();
    when(encounter.prefix).thenReturn(EpisodePrefix.pre);

    prePostEpisodeOfCare = PrePostEpisodeOfCare()
      ..dateOfCare = DateTime(2000, 10, 10)
      ..mobilityDevices = []
      ..communityParticipation = IcfQualifiers.noProblem
      ..communityParticipationWithLimb = IcfQualifiers.noProblem
      ..abilityToWork = IcfQualifiers.noProblem
      ..abilityToWorkWithLimb = IcfQualifiers.noProblem
      ..standingTimeInHour = AmbulatoryActivityLevel.noActivity
      ..walkingTimeInHour = AmbulatoryActivityLevel.noActivity
      ..fall = YesOrNo.yes
      ..fallFrequency = FallFrequency.lessThanOnceIn6Months
      ..isInjuriousFall = YesOrNo.no
      ..socialSupportAccess = YesOrNo.yes
      ..socialSupportUtil = YesOrNo.no
      ..communityServiceAccess = YesOrNo.yes
      ..communityService = CommunityService.government;

    when(encounter.prePostEpisodeOfCare).thenReturn(prePostEpisodeOfCare);
  });

  tearDown(() => unregisterService());

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

  // Configure the test binding with the custom screen size.
  Future<void> setScreenSize(WidgetTester tester, Size screenSize) async {
    await tester.binding.setSurfaceSize(screenSize);
  }

  Future<void> pumpTargetWidget(WidgetTester tester) async {
    // JK: Do not put Scaffold inside Scaffold. PrePostView has Scaffold as its top widget.
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        home: PrePostView(
          encounter,
          isEdit: false,
        ),
      ),
    );
  }

  Future<void> pumpTargetWidgetOnEdit(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        home: PrePostView(
          encounter,
          isEdit: true,
        ),
      ),
    );
  }

  Finder findByTypeAndKey<T>(Key key) {
    return find
        .byWidgetPredicate((widget) => widget is T && widget.key == key)
        .last;
  }

  Finder findDropdownMenuItem<T>(Key key, String displayName) {
    return find.byWidgetPredicate((widget) =>
        widget is DropdownMenuItem<T> &&
        widget.key == key &&
        widget.child is Text &&
        (widget.child as Text).data == displayName);
  }

  // Function to verify checkbox state
  Future<void> verifyCheckBoxState(WidgetTester tester,
      MobilityDevice mobilityDevice, bool expectedState) async {
    // Find the checkbox widget
    final checkboxFinder =
        findByTypeAndKey(Key('mobilityDevices_${mobilityDevice.index}'));

    // Tap the checkbox
    await tapAndSettle(tester, checkboxFinder);

    // Get the state of the Checkbox after tapping it
    final tappedState = tester.widget<Checkbox>(checkboxFinder);

    // Verify that the state matches the expected state
    expect(tappedState.value, expectedState);
  }

  Future<void> tapInfoAndCheckDialog(WidgetTester tester, String key) async {
    final infoFinder = findByTypeAndKey<IconButton>(Key('${key}_info'));

    await tapAndSettle(tester, infoFinder);
    expect(find.byType(Dialog), findsOneWidget);

    await tapOffsetZero(tester);
    expect(find.byType(Dialog), findsNothing);

    await tapAndSettle(tester, infoFinder);
    expect(find.byType(Dialog), findsOneWidget);

    // Verify the dialog view is dismissible when tapped 'Close' button
    final closeButton = find.text('Close');
    expect(closeButton, findsOneWidget);

    await tapAndSettle(tester, closeButton);
    expect(find.byType(Dialog), findsNothing);
  }

  Future<void> changeDate(
      WidgetTester tester, Finder dateFinder, String date) async {
    await tapAndSettle(tester, dateFinder);

    final inputSwitch = find.byWidgetPredicate((Widget w) =>
        w is IconButton && (w.tooltip?.startsWith('Switch to input') ?? false));
    await tapAndSettle(tester, inputSwitch);

    final textField = find.byWidgetPredicate((Widget w) =>
        w is TextField &&
        (w.decoration?.labelText?.startsWith('Enter Date') ?? false));
    await tester.enterText(textField, date);
    await tapAndSettle(tester, find.text('OK'));
  }

  final updateButton = findByTypeAndKey<Container>(const Key('updateButton'));

  group(
      'Verify all user interactable elements are interactable and exhibit proper interaction behavior.',
      () {
    /// **Test ID**: TC-LPP-003A
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
        'TC-LPP-003A - Verify the date picker is visible when icon or text field is tapped.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);

      // Find the date icon button
      final dateIconButton =
          findByTypeAndKey<IconButton>(const Key('dateOfCare'));

      expect(dateIconButton, findsOneWidget);

      await tapAndSettle(tester, dateIconButton);

      // Verify that the date picker dialog is displayed
      expect(find.byType(DatePickerDialog), findsOneWidget);

      await tapOffsetZero(tester);

      // Find the date text form field
      final dateTextFormField =
          findByTypeAndKey<TextFormField>(const Key('dateOfCare'));
      expect(dateTextFormField, findsOneWidget);

      // Tap the date text form field
      await tapAndSettle(tester, dateTextFormField);

      // Verify that the date picker dialog is displayed
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    /// **Test ID**: TC-LPP-003B
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
        'TC-LPP-003B - Verify that the date selected in the date picker dialog is correctly reflected in the date text field.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);

      // Find the date icon button
      final dateIconButton =
          findByTypeAndKey<IconButton>(const Key('dateOfCare'));

      // Verify selected date in the form field
      await changeDate(tester, dateIconButton, '1/5/1968');
      expect(find.text('1968-01-05'), findsOneWidget);
    });

    /// **Test ID**: TC-LPP-003C
    /// **Objective**: Verify that the participation drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap participation drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap participation drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003C - Verify that the participation drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      // JK: By default, screenSize is set to Size(600, 800), which is in landscape mode.
      // This is why it said the dropdown menu was out of bound.
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('participation'));

      // Tap participation dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over IcfQualifiers values and verify that each option is displayed
      for (final qualifier in IcfQualifiers.values) {
        expect(find.text(qualifier.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      // JK: number in findsNWidgets represents the total number of dropdown menus in this view
      // as the test goes on, this number will reduce down to 1, since you can't
      // unselect once selected. W
      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final qualifier in IcfQualifiers.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(qualifier.displayName));
        expect(find.text(qualifier.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003D
    /// **Objective**: Verify that the participationWithLimb drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap participationWithLimb drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap participationWithLimb drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003D - Verify that the participationWithLimb drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('participationWithLimb'));

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over IcfQualifiers values and verify that each option is displayed
      for (final qualifier in IcfQualifiers.values) {
        expect(find.text(qualifier.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      // JK: number in findsNWidgets represents the total number of dropdown menus in this view
      // as the test goes on, this number will reduce down to 1, since you can't
      // unselect once selected. W
      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final qualifier in IcfQualifiers.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(qualifier.displayName));
        expect(find.text(qualifier.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003E
    /// **Objective**: Verify that the abilityToWork drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap abilityToWork drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap abilityToWork drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003E - Verify that the abilityToWork drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('abilityToWork'));

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over IcfQualifiers values and verify that each option is displayed
      for (final qualifier in IcfQualifiers.values) {
        expect(find.text(qualifier.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      // JK: number in findsNWidgets represents the total number of dropdown menus in this view
      // as the test goes on, this number will reduce down to 1, since you can't
      // unselect once selected. W
      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final qualifier in IcfQualifiers.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(qualifier.displayName));
        expect(find.text(qualifier.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003F
    /// **Objective**: Verify that the abilityToWorkWithLimb drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap abilityToWorkWithLimb drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap abilityToWorkWithLimb drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003F - Verify that the abilityToWorkWithLimb drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('abilityToWorkWithLimb'));

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over IcfQualifiers values and verify that each option is displayed
      for (final qualifier in IcfQualifiers.values) {
        expect(find.text(qualifier.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      // JK: number in findsNWidgets represents the total number of dropdown menus in this view
      // as the test goes on, this number will reduce down to 1, since you can't
      // unselect once selected. W
      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final qualifier in IcfQualifiers.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(qualifier.displayName));
        expect(find.text(qualifier.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003G
    /// **Objective**: Verify that the standingTime drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap standingTime drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap standingTime drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003G - Verify that the standingTime drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('standingTime'));

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over AmbulatoryActivityLevel values and verify that each option is displayed
      for (final value in AmbulatoryActivityLevel.values) {
        expect(find.text(value.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in AmbulatoryActivityLevel.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));
        expect(find.text(value.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003H
    /// **Objective**: Verify that the walkingTime drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap walkingTime drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap walkingTime drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003H - Verify that the walkingTime drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('walkingTime'));

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over AmbulatoryActivityLevel values and verify that each option is displayed
      for (final value in AmbulatoryActivityLevel.values) {
        expect(find.text(value.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in AmbulatoryActivityLevel.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));
        expect(find.text(value.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003I
    /// **Objective**: Verify that the fall drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap fall drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap fall drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003I - Verify that the fall drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('fall'));

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over YesOrNo values and verify that each option is displayed
      for (final value in YesOrNo.values) {
        expect(find.text(value.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in YesOrNo.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));
        expect(find.text(value.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003J
    /// **Objective**: Verify that the fallFrequency drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: Ensure tapping fall drop down menu and tap Yes.
    /// **Test Steps**:
    ///   1. Find and tap fallFrequency drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap fallFrequency drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003J - Verify that the fallFrequency drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final fallFinder = find.byKey(const Key('fall'));
      await tapAndSettle(tester, fallFinder);

      // Find the DropdownMenuItem for 'Yes' under 'fall'
      final fallYesFinder = findDropdownMenuItem(
        Key('fall_${YesOrNo.yes.displayName}'),
        YesOrNo.yes.displayName,
      );

      await tapAndSettle(tester, fallYesFinder);

      final targetWidget = find.byKey(const Key('fallFrequency'));

      expect(targetWidget, findsOneWidget);
      expect(find.text('Fall frequency - Not Selected'), findsOneWidget);

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over FallFrequency values and verify that each option is displayed
      for (final value in FallFrequency.values) {
        expect(find.text(value.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in FallFrequency.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));
        expect(find.text(value.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003K
    /// **Objective**: Test the injuriousFall info dialog and verify the injuriousFall drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: Ensure tapping fall drop down menu and tap Yes.
    /// **Test Steps**:
    ///   1. Find and tap injuriousFall info icon.
    ///   2. Observe the info dialog is visible.
    ///   3. Tap outside of the widget to dismiss it.
    ///   4. Tap injuriousFall info icon again.
    ///   5. Tap Close button to dismiss it.
    ///   6. Find and tap injuriousFall drop down menu.
    ///   7. Observe all options are visible.
    ///   8. Tap outside of the widget to collapse it.
    ///   9. Observe nothing is selected.
    ///   10. Tap injuriousFall drop down menu again.
    ///   11. Tap each option.
    ///   12. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003K - Test the injuriousFall info dialog and verify the injuriousFall drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final fallFinder = find.byKey(const Key('fall'));
      await tapAndSettle(tester, fallFinder);

      // Find the DropdownMenuItem for 'Yes' under 'fall'
      final fallYesFinder = findDropdownMenuItem(
        Key('fall_${YesOrNo.yes.displayName}'),
        YesOrNo.yes.displayName,
      );

      await tapAndSettle(tester, fallYesFinder);

      await tapInfoAndCheckDialog(tester, 'injuriousFall');

      final targetWidget = find.byKey(const Key('injuriousFall'));

      expect(targetWidget, findsOneWidget);

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over YesOrNo values and verify that each option is displayed
      for (final value in YesOrNo.values) {
        final menuItemFinder = findDropdownMenuItem(
          Key('injuriousFall_${value.displayName}'),
          value.displayName,
        );
        expect(menuItemFinder, findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in YesOrNo.values) {
        await tapAndSettle(tester, targetWidget);

        final menuItemFinder = findDropdownMenuItem(
          Key('injuriousFall_${value.displayName}'),
          value.displayName,
        );

        await tapAndSettle(tester, menuItemFinder);

        expect(menuItemFinder, findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003L
    /// **Objective**: Verify the supportAtHome drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap supportAtHome drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap supportAtHome drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003L - Verify the supportAtHome drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('supportAtHome'));

      expect(targetWidget, findsOneWidget);

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over YesOrNo values and verify that each option is displayed
      for (final value in YesOrNo.values) {
        expect(find.text(value.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in YesOrNo.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));
        expect(find.text(value.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003M
    /// **Objective**: Verify the utilizeSupport drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: Ensure tapping supportAtHome drop down menu and tap Yes.
    /// **Test Steps**:
    ///   1. Find and tap utilizeSupport drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap utilizeSupport drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003M - Verify the utilizeSupport drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final parentFinder = find.byKey(const Key('supportAtHome'));
      await tapAndSettle(tester, parentFinder);

      // Find the DropdownMenuItem for 'Yes' under 'supportAtHome'
      final parentItemFinder = findDropdownMenuItem(
        Key('supportAtHome_${YesOrNo.yes.displayName}'),
        YesOrNo.yes.displayName,
      );

      await tapAndSettle(tester, parentItemFinder);

      final targetWidget = find.byKey(const Key('utilizeSupport'));

      expect(targetWidget, findsOneWidget);

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over YesOrNo values and verify that each option is displayed
      for (final value in YesOrNo.values) {
        final menuItemFinder = findDropdownMenuItem(
          Key('utilizeSupport_${value.displayName}'),
          value.displayName,
        );
        expect(menuItemFinder, findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in YesOrNo.values) {
        await tapAndSettle(tester, targetWidget);

        final menuItemFinder = findDropdownMenuItem(
          Key('utilizeSupport_${value.displayName}'),
          value.displayName,
        );

        await tapAndSettle(tester, menuItemFinder);

        expect(menuItemFinder, findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003N
    /// **Objective**: Verify the accessToService drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap accessToService drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap accessToService drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003N - Verify the accessToService drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('accessToService'));

      expect(targetWidget, findsOneWidget);

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over YesOrNo values and verify that each option is displayed
      for (final value in YesOrNo.values) {
        expect(find.text(value.displayName), findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in YesOrNo.values) {
        await tapAndSettle(tester, targetWidget);
        await tapAndSettle(tester, find.text(value.displayName));
        expect(find.text(value.displayName), findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003O
    /// **Objective**: Verify the serviceOption drop down menu populates its expected options and all options are selectable.
    /// **Preconditions**: Ensure tapping accessToService drop down menu and tap Yes.
    /// **Test Steps**:
    ///   1. Find and tap serviceOption drop down menu.
    ///   2. Observe all options are visible.
    ///   3. Tap outside of the widget to collapse it.
    ///   4. Observe nothing is selected.
    ///   5. Tap serviceOption drop down menu again.
    ///   6. Tap each option.
    ///   7. Observe tapped option is displayed in the drop down menu.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003O - Verify the serviceOption drop down menu populates its expected options and all options are selectable.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);

      // Find the widget you want to scroll to
      final parentFinder = find.byKey(const Key('accessToService'));
      await tapAndSettle(tester, parentFinder);

      // Find the DropdownMenuItem for 'Yes' under 'accessToService'
      final parentItemFinder = findDropdownMenuItem(
        Key('accessToService_${YesOrNo.yes.displayName}'),
        YesOrNo.yes.displayName,
      );

      await tapAndSettle(tester, parentItemFinder);

      final targetWidget = find.byKey(const Key('serviceOption'));

      expect(targetWidget, findsOneWidget);

      // Tap target widget dropdown menu and wait for the frame to build
      await tapAndSettle(tester, targetWidget);

      // Iterate over CommunityService values and verify that each option is displayed
      for (final value in CommunityService.values) {
        final menuItemFinder = findDropdownMenuItem(
          Key('serviceOption_${value.displayName}'),
          value.displayName,
        );
        expect(menuItemFinder, findsOneWidget);
      }

      await tapOffsetZero(tester);

      expect(find.text('Not Selected'), findsNWidgets(9));

      // Tap dropdown menu and tap each option and
      // verify that the selected item is displayed
      for (final value in CommunityService.values) {
        await tapAndSettle(tester, targetWidget);

        final menuItemFinder = findDropdownMenuItem(
          Key('serviceOption_${value.displayName}'),
          value.displayName,
        );

        await tapAndSettle(tester, menuItemFinder);

        expect(menuItemFinder, findsOneWidget);
      }
    });

    /// **Test ID**: TC-LPP-003P
    /// **Objective**: Verify the functionality of the mobility device check boxes.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap all mobility device checkboxes.
    ///   2. Observe that the 'noWalkingAids' checkbox is unchecked when any other checkbox is checked.
    ///   3. If the 'noWalkingAids' checkbox is checked, ensure all other checkboxes are unchecked.
    /// **Automated**: Yes
    testWidgets('TC-LPP-003P - Verify the functionality of the mobility device check boxes.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpTargetWidget(tester);

      // Check all checkboxes
      for (final value in MobilityDevice.values) {
        await verifyCheckBoxState(tester, value, true);
      }

      // Given noWalkingAids checked, if any other checkboxes are also checked, noWalkingAids should be unchecked.
      expect(
          tester
              .widget<Checkbox>(findByTypeAndKey(
                  Key('mobilityDevices_${MobilityDevice.noWalkingAids.index}')))
              .value,
          false);

      // When any other checkboxes are checked, if the noWalkingAids is also checked, all the other checkboxes should be unchecked.
      for (final value in MobilityDevice.values) {
        if (value == MobilityDevice.noWalkingAids) {
          await verifyCheckBoxState(tester, value, true);
        } else {
          expect(
              tester
                  .widget<Checkbox>(
                      findByTypeAndKey(Key('mobilityDevices_${value.index}')))
                  .value,
              false);
        }
      }
    });

    /// **Test ID**: TC-LPP-003Q
    /// **Objective**: Verify the functionality of the mobility device usage drop-down list.
    /// **Preconditions**: Ensure tapping each mobility device checkbox to mark it as checked.
    /// **Test Steps**:
    ///   1. Find and tap each mobility device checkbox.
    ///   2. If it's not 'noWalkingAids', observe the corresponding usage drop down menu pops up.
    ///   3. Tap the drop down menu.
    ///   4. Observe all options are visible.
    ///   5. Tap outside of the widget to collapse it.
    ///   6. Observe nothing is selected.
    ///   7. Tap the usage drop down menu again.
    ///   8. Tap each option.
    ///   9. Observe the tapped option is displayed in the drop down menu.
    ///   10. Tap the selected checkbox again to uncheck it.
    ///   11. Observe the checkbox is unchecked.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003Q - Verify the functionality of the mobility device usage drop-down list.',
        (WidgetTester tester) async {
      //TODO: when deselecting, verify the value is clear.
      await setScreenSize(tester, const Size(1488, 2266));

      await pumpTargetWidget(tester);

      for (final value in MobilityDevice.values) {
        await verifyCheckBoxState(tester, value, true);

        // Check if following questions pops up when corresponding checkbox is checked.
        if (value != MobilityDevice.noWalkingAids) {
          expect(
              find.text('${value.displayName} - Not Selected'), findsOneWidget);

          // Find the widget you want to scroll to
          final targetWidget =
              find.byKey(Key('mobilityDevices_${value.index}_usage'));

          // Tap dropdown menu and wait for the frame to build
          await tapAndSettle(tester, targetWidget);

          for (final value in MobilityDeviceUsage.values) {
            expect(find.text(value.displayName), findsOneWidget);
          }

          await tapOffsetZero(tester);

          // Tap dropdown menu and tap each option and
          // verify that the selected item is displayed
          for (final value in MobilityDeviceUsage.values) {
            await tapAndSettle(tester, targetWidget);
            await tapAndSettle(tester, find.text(value.displayName));
            expect(find.text(value.displayName), findsOneWidget);
          }
        }

        await verifyCheckBoxState(tester, value, false);
      }
    });

    /// **Test ID**: TC-LPP-003R
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
        'TC-LPP-003R - Verify that all info dialogs can be opened and closed successfully.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);

      List<String> infoKeys = [
        'dateOfCare',
        'mobilityDevices',
        'participation',
        'participationWithLimb',
        'abilityToWork',
        'abilityToWorkWithLimb',
        'fall',
        'supportAtHome',
        'accessToService',
      ];

      for (int i = 0; i < infoKeys.length; i++) {
        await tapInfoAndCheckDialog(tester, infoKeys[i]);
      }
    });

    /// **Test ID**: TC-LPP-003S
    /// **Objective**: Verify the widget title and some text in Pre episode.
    /// **Preconditions**: Start a Pre episode of care.
    /// **Test Steps**:
    ///   1. Verify the widget title is 'Pre Episode of Care'.
    ///   2. Verify the title of date section is 'Date of commencement of rehab care'.
    /// **Automated**: Yes
    testWidgets('TC-LPP-003S - Verify widget title and some text in Pre episode.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);
      expect(find.text('Pre Episode of Care'), findsOneWidget);
      expect(find.text('Date of commencement of rehab care'), findsOneWidget);
    });

    /// **Test ID**: TC-LPP-003T
    /// **Objective**: Verify the widget title and some text in Post episode.
    /// **Preconditions**: Start a Post episode of care.
    /// **Test Steps**:
    ///   1. Verify the widget title is 'Post Episode of Care'.
    ///   2. Verify the title of date section is 'Date of completion of rehab care'.
    /// **Automated**: Yes
    testWidgets('TC-LPP-003T - Verify widget title and some text in Post episode.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      encounter = MockEncounter();
      when(encounter.prefix).thenReturn(EpisodePrefix.post);
      await pumpTargetWidget(tester);
      expect(find.text('Post Episode of Care'), findsOneWidget);
      expect(find.text('Date of completion of rehab care'), findsOneWidget);
    });

    /// **Test ID**: TC-LPP-003U
    /// **Objective**: Verify a prompt displayed when dismissing the widget by tapping the back button.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Find and tap back button.
    ///   2. Observe a prompt displayed.
    ///   3. Tap outside of the prompt to dismiss the prompt.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-003U - Verify a prompt displayed when dismissing the widget by tapping the back button.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidget(tester);

      // Find the date icon button
      final backButton = findByTypeAndKey<IconButton>(const Key('backButton'));

      expect(backButton, findsOneWidget);

      await tapAndSettle(tester, backButton);

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byKey(const Key('cancelLeadCompassDialog')), findsOneWidget);

      await tapOffsetZero(tester);
    });
  });

  group(
      'Verify that the user can correctly edit Pre/Post responses and any changes triggers its modify state.',
      () {
    /// **Test ID**: TC-LPP-007A
    /// **Objective**: Verify the state of update button when the date is updated.
    /// **Preconditions**: Date of rehabilitation care is set.
    /// **Test Steps**:
    ///   1. Find and tap date icon.
    ///   2. Change date.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap date icon again, change date to the original and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets('TC-LPP-007A - Verify the state of update button when the date is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidgetOnEdit(tester);

      // Find the date icon button
      final dateIconButton =
          findByTypeAndKey<IconButton>(const Key('dateOfCare'));

      await changeDate(tester, dateIconButton, '1/5/1968');
      expect(find.text('1968-01-05'), findsOneWidget);
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      await changeDate(tester, dateIconButton, '10/10/2000');
      expect(find.text('2000-10-10'), findsOneWidget);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007B
    /// **Objective**: Verify the state of update button when the participation item is updated.
    /// **Preconditions**: One of items under participation drop down menu is selected.
    /// **Test Steps**:
    ///   1. Find and tap participation drop down menu.
    ///   2. Tap another item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap participation drop down menu again, tap the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007B - Verify the state of update button when the participation item is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidgetOnEdit(tester);

      final targetWidget =
          findByTypeAndKey<DropdownButtonFormField>(const Key('participation'));
      await tapAndSettle(tester, targetWidget);

      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('participation_${IcfQualifiers.mildProblem.displayName}')));
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('participation_${IcfQualifiers.noProblem.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007C
    /// **Objective**: Verify the state of update button when the participationWithLimb item is updated.
    /// **Preconditions**: One of items under participationWithLimb drop down menu is selected.
    /// **Test Steps**:
    ///   1. Find and tap participationWithLimb drop down menu.
    ///   2. Tap another item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap participationWithLimb drop down menu again, tap the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007C - Verify the state of update button when the participationWithLimb item is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidgetOnEdit(tester);

      final targetWidget = findByTypeAndKey<DropdownButtonFormField>(
          const Key('participationWithLimb'));
      await tapAndSettle(tester, targetWidget);

      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'participationWithLimb_${IcfQualifiers.mildProblem.displayName}')));
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'participationWithLimb_${IcfQualifiers.noProblem.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007D
    /// **Objective**: Verify the state of update button when the abilityToWork item is updated.
    /// **Preconditions**: One of items under abilityToWork drop down menu is selected.
    /// **Test Steps**:
    ///   1. Find and tap abilityToWork drop down menu.
    ///   2. Tap another item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap abilityToWork drop down menu again, tap the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007D - Verify the state of update button when the abilityToWork item is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidgetOnEdit(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('abilityToWork'));
      await tapAndSettle(tester, targetWidget);

      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('abilityToWork_${IcfQualifiers.mildProblem.displayName}')));
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('abilityToWork_${IcfQualifiers.noProblem.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007E
    /// **Objective**: Verify the state of update button when the abilityToWorkWithLimb item is updated.
    /// **Preconditions**: One of items under abilityToWorkWithLimb drop down menu is selected.
    /// **Test Steps**:
    ///   1. Find and tap abilityToWorkWithLimb drop down menu.
    ///   2. Tap another item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap abilityToWorkWithLimb drop down menu again, tap the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007E - Verify the state of update button when the abilityToWorkWithLimb item is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidgetOnEdit(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('abilityToWorkWithLimb'));
      await tapAndSettle(tester, targetWidget);

      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'abilityToWorkWithLimb_${IcfQualifiers.mildProblem.displayName}')));
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'abilityToWorkWithLimb_${IcfQualifiers.noProblem.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007F
    /// **Objective**: Verify the state of update button when the standingTime item is updated.
    /// **Preconditions**: One of items under standingTime drop down menu is selected.
    /// **Test Steps**:
    ///   1. Find and tap standingTime drop down menu.
    ///   2. Tap another item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap standingTime drop down menu again, tap the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007F - Verify the state of update button when the standingTime item is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidgetOnEdit(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('standingTime'));
      await tapAndSettle(tester, targetWidget);

      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'standingTime_${AmbulatoryActivityLevel.little.displayName}')));
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'standingTime_${AmbulatoryActivityLevel.noActivity.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007G
    /// **Objective**: Verify the state of update button when the walkingTime item is updated.
    /// **Preconditions**: One of items under walkingTime drop down menu is selected.
    /// **Test Steps**:
    ///   1. Find and tap walkingTime drop down menu.
    ///   2. Tap another item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap walkingTime drop down menu again, tap the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007G - Verify the state of update button when the walkingTime item is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidgetOnEdit(tester);

      // Find the widget you want to scroll to
      final targetWidget = find.byKey(const Key('walkingTime'));
      await tapAndSettle(tester, targetWidget);

      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'walkingTime_${AmbulatoryActivityLevel.little.displayName}')));
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'walkingTime_${AmbulatoryActivityLevel.noActivity.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007H
    /// **Objective**: Verify the state of update button when the fall item and following questions are updated.
    /// **Preconditions**: 'Yes' is selected for fall drop down menu, and one of options is selected for each following question.
    /// **Test Steps**:
    ///   1. Find and tap fall drop down menu.
    ///   2. Tap 'No' item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap fall drop down menu again and tap 'Yes' to revert the change.
    ///   5. Tap the original option for each following question and make sure the change is reverted.
    ///   6. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007H - Verify the state of update button when the fall item and following questions are updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidgetOnEdit(tester);

      final targetWidget = find.byKey(const Key('fall'));
      await tapAndSettle(tester, targetWidget);

      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('fall_${YesOrNo.no.displayName}')));
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('fall_${YesOrNo.yes.displayName}')));
      await tapAndSettle(tester, find.byKey(const Key('fallFrequency')));
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'fallFrequency_${FallFrequency.lessThanOnceIn6Months.displayName}')));
      await tapAndSettle(tester, find.byKey(const Key('injuriousFall')));
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('injuriousFall_${YesOrNo.no.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007I
    /// **Objective**: Verify the state of update button when the supportAtHome item and following question is updated.
    /// **Preconditions**: 'Yes' is selected for supportAtHome drop down menu, and one of options is selected for the following question.
    /// **Test Steps**:
    ///   1. Find and tap supportAtHome drop down menu.
    ///   2. Tap 'No' item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap supportAtHome drop down menu again and tap 'Yes' to revert the change.
    ///   5. Tap the original option for the following question and make sure the change is reverted.
    ///   6. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007I - Verify the state of update button when the supportAtHome item and following question is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidgetOnEdit(tester);

      final targetWidget = find.byKey(const Key('supportAtHome'));
      await tapAndSettle(tester, targetWidget);

      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('supportAtHome_${YesOrNo.no.displayName}')));
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('supportAtHome_${YesOrNo.yes.displayName}')));
      await tapAndSettle(tester, find.byKey(const Key('utilizeSupport')));
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('utilizeSupport_${YesOrNo.no.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007J
    /// **Objective**: Verify the state of update button when the accessToService item and following question is updated.
    /// **Preconditions**: 'Yes' is selected for accessToService drop down menu, and one of options is selected for the following question.
    /// **Test Steps**:
    ///   1. Find and tap accessToService drop down menu.
    ///   2. Tap 'No' item.
    ///   3. Observe the update button color changes to red.
    ///   4. Tap accessToService drop down menu again and tap 'Yes' to revert the change.
    ///   5. Tap the original option for the following question and make sure the change is reverted.
    ///   6. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007J - Verify the state of update button when the accessToService item and following question is updated.',
        (WidgetTester tester) async {
      await setScreenSize(tester, const Size(768, 1024));

      await pumpTargetWidgetOnEdit(tester);

      final targetWidget = find.byKey(const Key('accessToService'));
      await tapAndSettle(tester, targetWidget);

      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('accessToService_${YesOrNo.no.displayName}')));
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      await tapAndSettle(tester, targetWidget);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('accessToService_${YesOrNo.yes.displayName}')));
      await tapAndSettle(tester, find.byKey(const Key('serviceOption')));
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(
              Key('serviceOption_${CommunityService.government.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007K
    /// **Objective**: Verify the state of update button when the mobility device list is empty and the list is updated.
    /// **Preconditions**: None of mobility devices is selected.
    /// **Test Steps**:
    ///   1. Tap one of mobility devices to mark it as checked.
    ///   2. Observe the update button color changes to red.
    ///   3. Tap the checked item again to mark it as unchecked and make sure the change is reverted.
    ///   4. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007K - Verify the state of update button when the mobility device list is empty and the list is updated.',
        (WidgetTester tester) async {
      prePostEpisodeOfCare.mobilityDevices = [];

      await setScreenSize(tester, const Size(1488, 2266));

      await pumpTargetWidgetOnEdit(tester);

      await verifyCheckBoxState(tester, MobilityDevice.singlePointStick, true);
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));
      await verifyCheckBoxState(tester, MobilityDevice.singlePointStick, false);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007L
    /// **Objective**: Verify the state of update button when 'No walking aids' is selected for mobility devices and the list is updated.
    /// **Preconditions**: 'No walking aids' is selected.
    /// **Test Steps**:
    ///   1. Tap one of mobility devices to mark it as checked.
    ///   2. Observe the update button color changes to red.
    ///   3. Tap the checked item again to mark it as unchecked and make sure the change is reverted.
    ///   4. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007L - Verify the state of update button when \'No walking aids\' is selected for mobility devices and the list is updated.',
        (WidgetTester tester) async {
      prePostEpisodeOfCare.mobilityDevices = [MobilityDevice.noWalkingAids];
      prePostEpisodeOfCare.noWalkingAidsUsage = MobilityDeviceUsage.noUsage;

      await setScreenSize(tester, const Size(1488, 2266));

      await pumpTargetWidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(tester, MobilityDevice.noWalkingAids, false);
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await verifyCheckBoxState(tester, MobilityDevice.noWalkingAids, true);
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007M
    /// **Objective**: Verify the state of update button when 'Single point stick' is selected for mobility devices and the list is updated.
    /// **Preconditions**: 'Single point stick' is selected and one of options is selected under device usage drop down menu.
    /// **Test Steps**:
    ///   1. Tap 'Single point stick' to mark it as unchecked.
    ///   2. Observe the update button color changes to red.
    ///   3. Tap it again to mark it as checked to revert the change.
    ///   4. Tap device usage drop down menu, select the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007M - Verify the state of update button when \'Single point stick\' is selected for mobility devices and the list is updated.',
        (WidgetTester tester) async {
      prePostEpisodeOfCare.mobilityDevices = [MobilityDevice.singlePointStick];
      prePostEpisodeOfCare.singlePointStickUsage = MobilityDeviceUsage.noUsage;

      await setScreenSize(tester, const Size(1488, 2266));

      await pumpTargetWidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(tester, MobilityDevice.singlePointStick, false);
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await verifyCheckBoxState(tester, MobilityDevice.singlePointStick, true);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownButtonFormField>(Key(
              'mobilityDevices_${MobilityDevice.singlePointStick.index}_usage')));
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'mobilityDevices_${MobilityDevice.singlePointStick.index}_usage_${MobilityDeviceUsage.noUsage.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007N
    /// **Objective**: Verify the state of update button when 'Quad base walking stick' is selected for mobility devices and the list is updated.
    /// **Preconditions**: 'Quad base walking stick' is selected and one of options is selected under device usage drop down menu.
    /// **Test Steps**:
    ///   1. Tap 'Quad base walking stick' to mark it as unchecked.
    ///   2. Observe the update button color changes to red.
    ///   3. Tap it again to mark it as checked to revert the change.
    ///   4. Tap device usage drop down menu, select the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007N - Verify the state of update button when \'Quad base walking stick\' is selected for mobility devices and the list is updated.',
        (WidgetTester tester) async {
      prePostEpisodeOfCare.mobilityDevices = [
        MobilityDevice.quadBaseWalkingStick
      ];
      prePostEpisodeOfCare.quadBaseWalkingStickUsage =
          MobilityDeviceUsage.noUsage;

      await setScreenSize(tester, const Size(1488, 2266));

      await pumpTargetWidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(
          tester, MobilityDevice.quadBaseWalkingStick, false);
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await verifyCheckBoxState(
          tester, MobilityDevice.quadBaseWalkingStick, true);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownButtonFormField>(Key(
              'mobilityDevices_${MobilityDevice.quadBaseWalkingStick.index}_usage')));
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'mobilityDevices_${MobilityDevice.quadBaseWalkingStick.index}_usage_${MobilityDeviceUsage.noUsage.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007O
    /// **Objective**: Verify the state of update button when 'Single crutch' is selected for mobility devices and the list is updated.
    /// **Preconditions**: 'Single crutch' is selected and one of options is selected under device usage drop down menu.
    /// **Test Steps**:
    ///   1. Tap 'Single crutch' to mark it as unchecked.
    ///   2. Observe the update button color changes to red.
    ///   3. Tap it again to mark it as checked to revert the change.
    ///   4. Tap device usage drop down menu, select the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007O - Verify the state of update button when \'Single crutch\' is selected for mobility devices and the list is updated.',
        (WidgetTester tester) async {
      prePostEpisodeOfCare.mobilityDevices = [MobilityDevice.singleCrutch];
      prePostEpisodeOfCare.singleCrutchUsage = MobilityDeviceUsage.noUsage;

      await setScreenSize(tester, const Size(1488, 2266));

      await pumpTargetWidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(tester, MobilityDevice.singleCrutch, false);
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await verifyCheckBoxState(tester, MobilityDevice.singleCrutch, true);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownButtonFormField>(Key(
              'mobilityDevices_${MobilityDevice.singleCrutch.index}_usage')));
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'mobilityDevices_${MobilityDevice.singleCrutch.index}_usage_${MobilityDeviceUsage.noUsage.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007P
    /// **Objective**: Verify the state of update button when 'Pair of crutches' is selected for mobility devices and the list is updated.
    /// **Preconditions**: 'Pair of crutches' is selected and one of options is selected under device usage drop down menu.
    /// **Test Steps**:
    ///   1. Tap 'Pair of crutches' to mark it as unchecked.
    ///   2. Observe the update button color changes to red.
    ///   3. Tap it again to mark it as checked to revert the change.
    ///   4. Tap device usage drop down menu, select the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007P - Verify the state of update button when \'Pair of crutches\' is selected for mobility devices and the list is updated.',
        (WidgetTester tester) async {
      prePostEpisodeOfCare.mobilityDevices = [MobilityDevice.pairOfCrutches];
      prePostEpisodeOfCare.pairOfCrutchesUsage = MobilityDeviceUsage.noUsage;

      await setScreenSize(tester, const Size(1488, 2266));

      await pumpTargetWidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(tester, MobilityDevice.pairOfCrutches, false);
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await verifyCheckBoxState(tester, MobilityDevice.pairOfCrutches, true);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownButtonFormField>(Key(
              'mobilityDevices_${MobilityDevice.pairOfCrutches.index}_usage')));
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'mobilityDevices_${MobilityDevice.pairOfCrutches.index}_usage_${MobilityDeviceUsage.noUsage.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007Q
    /// **Objective**: Verify the state of update button when 'Walking frame/walker' is selected for mobility devices and the list is updated.
    /// **Preconditions**: 'Walking frame/walker' is selected and one of options is selected under device usage drop down menu.
    /// **Test Steps**:
    ///   1. Tap 'Walking frame/walker' to mark it as unchecked.
    ///   2. Observe the update button color changes to red.
    ///   3. Tap it again to mark it as checked to revert the change.
    ///   4. Tap device usage drop down menu, select the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007Q - Verify the state of update button when \'Walking frame/walker\' is selected for mobility devices and the list is updated.',
        (WidgetTester tester) async {
      prePostEpisodeOfCare.mobilityDevices = [
        MobilityDevice.walkingFrameWalker
      ];
      prePostEpisodeOfCare.walkingFrameWalkerUsage =
          MobilityDeviceUsage.noUsage;

      await setScreenSize(tester, const Size(1488, 2266));

      await pumpTargetWidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(
          tester, MobilityDevice.walkingFrameWalker, false);
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await verifyCheckBoxState(
          tester, MobilityDevice.walkingFrameWalker, true);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownButtonFormField>(Key(
              'mobilityDevices_${MobilityDevice.walkingFrameWalker.index}_usage')));
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'mobilityDevices_${MobilityDevice.walkingFrameWalker.index}_usage_${MobilityDeviceUsage.noUsage.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007R
    /// **Objective**: Verify the state of update button when 'Wheeled walker' is selected for mobility devices and the list is updated.
    /// **Preconditions**: 'Wheeled walker' is selected and one of options is selected under device usage drop down menu.
    /// **Test Steps**:
    ///   1. Tap 'Wheeled walker' to mark it as unchecked.
    ///   2. Observe the update button color changes to red.
    ///   3. Tap it again to mark it as checked to revert the change.
    ///   4. Tap device usage drop down menu, select the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007R - Verify the state of update button when \'Wheeled walker\' is selected for mobility devices and the list is updated.',
        (WidgetTester tester) async {
      prePostEpisodeOfCare.mobilityDevices = [MobilityDevice.wheeledWalker];
      prePostEpisodeOfCare.wheeledWalkerUsage = MobilityDeviceUsage.noUsage;

      await setScreenSize(tester, const Size(1488, 2266));

      await pumpTargetWidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(tester, MobilityDevice.wheeledWalker, false);
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await verifyCheckBoxState(tester, MobilityDevice.wheeledWalker, true);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownButtonFormField>(Key(
              'mobilityDevices_${MobilityDevice.wheeledWalker.index}_usage')));
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'mobilityDevices_${MobilityDevice.wheeledWalker.index}_usage_${MobilityDeviceUsage.noUsage.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007S
    /// **Objective**: Verify the state of update button when 'Manual wheelchair' is selected for mobility devices and the list is updated.
    /// **Preconditions**: 'Manual wheelchair' is selected and one of options is selected under device usage drop down menu.
    /// **Test Steps**:
    ///   1. Tap 'Manual wheelchair' to mark it as unchecked.
    ///   2. Observe the update button color changes to red.
    ///   3. Tap it again to mark it as checked to revert the change.
    ///   4. Tap device usage drop down menu, select the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007S - Verify the state of update button when \'Manual wheelchair\' is selected for mobility devices and the list is updated.',
        (WidgetTester tester) async {
      prePostEpisodeOfCare.mobilityDevices = [MobilityDevice.manualWheelchair];
      prePostEpisodeOfCare.manualWheelchairUsage = MobilityDeviceUsage.noUsage;

      await setScreenSize(tester, const Size(1488, 2266));

      await pumpTargetWidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(tester, MobilityDevice.manualWheelchair, false);
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await verifyCheckBoxState(tester, MobilityDevice.manualWheelchair, true);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownButtonFormField>(Key(
              'mobilityDevices_${MobilityDevice.manualWheelchair.index}_usage')));
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'mobilityDevices_${MobilityDevice.manualWheelchair.index}_usage_${MobilityDeviceUsage.noUsage.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });

    /// **Test ID**: TC-LPP-007T
    /// **Objective**: Verify the state of update button when 'Powered wheelchair or mobility scooter' is selected for mobility devices and the list is updated.
    /// **Preconditions**: 'Powered wheelchair or mobility scooter' is selected and one of options is selected under device usage drop down menu.
    /// **Test Steps**:
    ///   1. Tap 'Powered wheelchair or mobility scooter' to mark it as unchecked.
    ///   2. Observe the update button color changes to red.
    ///   3. Tap it again to mark it as checked to revert the change.
    ///   4. Tap device usage drop down menu, select the original item and make sure the change is reverted.
    ///   5. Observe the update button color changes to grey.
    /// **Automated**: Yes
    testWidgets(
        'TC-LPP-007T - Verify the state of update button when \'Powered wheelchair or mobility scooter\' is selected for mobility devices and the list is updated.',
        (WidgetTester tester) async {
      prePostEpisodeOfCare.mobilityDevices = [
        MobilityDevice.poweredWheelchairOrMobilityScooter
      ];
      prePostEpisodeOfCare.poweredWheeledOrMobilityScooterUsage =
          MobilityDeviceUsage.noUsage;

      await setScreenSize(tester, const Size(1488, 2266));

      await pumpTargetWidgetOnEdit(tester);

      // Verify update button is enabled when making a change.
      await verifyCheckBoxState(
          tester, MobilityDevice.poweredWheelchairOrMobilityScooter, false);
      expect(
          (tester.widget(updateButton) as Container).color, equals(kcBackgroundColor));

      // Verify update button is disabled when reverting the change.
      await verifyCheckBoxState(
          tester, MobilityDevice.poweredWheelchairOrMobilityScooter, true);
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownButtonFormField>(Key(
              'mobilityDevices_${MobilityDevice.poweredWheelchairOrMobilityScooter.index}_usage')));
      await tapAndSettle(
          tester,
          findByTypeAndKey<DropdownMenuItem>(Key(
              'mobilityDevices_${MobilityDevice.poweredWheelchairOrMobilityScooter.index}_usage_${MobilityDeviceUsage.noUsage.displayName}')));
      expect((tester.widget(updateButton) as Container).color,
          equals(Colors.grey));
    });
  });

  /// **Test ID**: TC-LPP-004
  /// **Objective**: Verify all Pre/Post Episode questions are optional to be completed.
  /// **Preconditions**: None.
  /// **Test Steps**:
  ///   1. Make sure all questions are not answered and tap 'Next' button.
  /// **Automated**: Yes
  testWidgets(
      'TC-LPP-004 - Verify all Pre/Post Episode questions are optional to be completed.',
      (WidgetTester tester) async {
    await setScreenSize(tester, const Size(768, 1024));

    await pumpTargetWidget(tester);

    await tester.tap(find.byKey(const Key('updateButton')));

    expect(tester.takeException(), isNull);
  });
}
