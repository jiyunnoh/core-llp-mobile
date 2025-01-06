import 'package:biot/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../model/patient.dart';
import '../../../services/database_service.dart';
import '../../../services/logger_service.dart';
import '../amputation_form/amputation_form_view.dart';

class AmputationViewModel extends BaseViewModel {

  final _localdbService = locator<DatabaseService>();
  final _navigationService = locator<NavigationService>();
  final _logger =
  locator<LoggerService>().getLogger((AmputationViewModel).toString());
  Patient get currentPatient => _localdbService.currentPatient!.value;

  void navigateToAmputationFormView() async{
    _logger.d('');
    await _navigationService.navigateWithTransition(const AmputationFormView(isEdit: true, shouldUpdateCloud: true,), routeName: Routes.amputationFormView, fullscreenDialog: true);
    notifyListeners();
  }
}
