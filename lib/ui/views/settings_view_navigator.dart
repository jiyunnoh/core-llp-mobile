import 'package:biot/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class SettingsViewNavigator extends StatelessWidget {
  const SettingsViewNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Navigator(
      initialRoute: SettingsViewNavigatorRoutes.settingsView,
      observers: [StackedService.routeObserver],
      onGenerateRoute: SettingsViewNavigatorRouter(),
      key: StackedService.nestedNavigationKey(2),
    ));
  }
}
