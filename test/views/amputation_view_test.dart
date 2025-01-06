import 'package:biot/app/app.dialogs.dart';
import 'package:biot/app/app.locator.dart';
import 'package:biot/app/app.router.dart';
import 'package:biot/constants/amputation_info.dart';
import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/model/amputation.dart';
import 'package:biot/services/database_service.dart';
import 'package:biot/services/logger_service.dart';
import 'package:biot/ui/views/amputation/amputation_view.dart';
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
  });

  tearDown(() {
    amputations.clear();
    unregisterService();
  });

  testWidgets('Verify amputation info is displayed is displayed correctly',
      (WidgetTester tester) async {
    Amputation left = Amputation()
      ..side = AmputationSide.left
      ..level = LevelOfAmputation.transfemoral
      ..dateOfAmputation = DateTime(2023, 1, 5)
      ..cause = CauseOfAmputation.cancer
      ..type = TypeOfAmputation.majorAmputation
      ..abilityToWalk = YesOrNo.no;
    Amputation right = Amputation()
      ..side = AmputationSide.right
      ..level = LevelOfAmputation.toeAmputation
      ..dateOfAmputation = DateTime(2024, 2, 10)
      ..cause = CauseOfAmputation.other
      ..otherPrimaryCause = 'Bear Attack'
      ..type = TypeOfAmputation.softTissueRevisionAtSameLevel
      ..abilityToWalk = YesOrNo.yes;
    amputations.add(left);
    amputations.add(right);

    const Size screenSize =
        Size(1488, 2266); // iPad screen size in portrait mode
    await tester.binding.setSurfaceSize(screenSize);
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      home: const AmputationView(),
    ));

    expect(find.text('Left'), findsOneWidget);
    expect(find.text('2023-01-05'), findsOneWidget);
    expect(find.text(LevelOfAmputation.transfemoral.displayName), findsOneWidget);
    expect(find.text(CauseOfAmputation.cancer.displayName), findsOneWidget);
    expect(find.text(TypeOfAmputation.majorAmputation.displayName), findsOneWidget);
    expect(find.text('No'), findsOneWidget);

    expect(find.text('Right'), findsOneWidget);
    expect(find.text('2024-02-10'), findsOneWidget);
    expect(find.text(LevelOfAmputation.toeAmputation.displayName), findsOneWidget);
    expect(find.text('Bear Attack'), findsOneWidget);
    expect(find.text(TypeOfAmputation.softTissueRevisionAtSameLevel.displayName), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
  });
}
