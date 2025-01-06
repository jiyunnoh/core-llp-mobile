import 'package:biot/app/app.locator.dart';
import 'package:biot/app/app.router.dart';
import 'package:biot/services/logger_service.dart';
import 'package:biot/ui/views/login/login_view.dart';
import 'package:biot/ui/views/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  late var mockLoggerService;
  late var mockNavigationService;

  setUp(() {
    registerServices();

    mockLoggerService = locator<LoggerService>();
    mockNavigationService = locator<NavigationService>();
    when(mockLoggerService.getLogger(any))
        .thenReturn(Logger(printer: SimplePrinter(), output: ConsoleOutput()));
  });

  tearDown(() => unregisterService());

  // testWidgets('IconButton opens SettingsView', (WidgetTester tester) async {
  //   // Build your widget tree with MaterialApp or Material widget
  //   await tester.pumpWidget(
  //     MaterialApp(
  //       home: LoginView(),
  //     ),
  //   );
  //
  //   // Verify that the IconButton is initially present
  //   expect(find.byIcon(Icons.settings), findsOneWidget);
  //
  //   // Tap the IconButton
  //   await tester.tap(find.byIcon(Icons.settings));
  //   await tester.pumpAndSettle(); // Wait for the transition animation to complete
  //
  //   // Verify that the SettingsView is displayed
  //   expect(find.byType(SettingsView), findsOneWidget);
  // });
}
