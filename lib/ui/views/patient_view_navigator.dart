import 'package:biot/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class PatientViewNavigator extends StatelessWidget {
  const PatientViewNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Navigator(
      initialRoute: PatientViewNavigatorRoutes.patientView,
      observers: [StackedService.routeObserver],
      onGenerateRoute: PatientViewNavigatorRouter(),
      key: StackedService.nestedNavigationKey(0),
    ));
  }
}
