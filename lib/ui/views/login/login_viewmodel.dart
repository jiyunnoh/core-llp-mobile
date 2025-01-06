import 'package:biot/app/app.router.dart';
import 'package:biot/mixin/dialog_mixin.dart';
import 'package:biot/services/analytics_service.dart';
import 'package:biot/services/logger_service.dart';
import 'package:biot/ui/views/settings/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../services/cloud_service.dart';
import '../../../services/package_info_service.dart';
import '../bottom_nav_view.dart';

class LoginViewModel extends ReactiveViewModel with OIDialog {
  final _apiService = locator<BiotService>();
  final _packageInfoService = locator<PackageInfoService>();
  final _navigationService = locator<NavigationService>();
  final _logger =
      locator<LoggerService>().getLogger((LoginViewModel).toString());
  final _analyticsService = locator<AnalyticsService>();

  bool isPwdVisible = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();

  LoginViewModel() {
    _logger.d('');

    emailController.text = '';
    pwdController.text = '';
  }

  String get appVersion => (_packageInfoService.info == null)
      ? ''
      : '${_packageInfoService.info!.version} (${_packageInfoService.info!.buildNumber})';

  Future<bool> login(id, pwd) async {
    _logger.d('');

    showBusyDialog();

    try {
      await _apiService.loginWithCredentials(id, pwd);
      _analyticsService.logLogin();

      // Get organization code
      //TODO: JK - not all org has code. this should be nullable. This may be always true in the future however depends on whether we make this field required or not.
      _apiService.getOrganizationCodeById();

      closeBusyDialog();

      await _navigationService.navigateWithTransition(const BottomNavView(),
          routeName: BottomNavViewRoutes.patientViewNavigator,
          transitionStyle: Transition.fade);

      //TODO: Jiyun - refactor. replace loginView with next view. pwdController.text is always empty. emailController.text = _apiService.userId ?? ''
      // reset password in case when logging out.
      emailController.text = _apiService.userId;
      pwdController.text = '';

      return true;
    } catch (e) {
      closeBusyDialog();

      handleHTTPError(e);
    }
    return false;
  }

  void onTogglePwdVisible() {
    isPwdVisible = !isPwdVisible;
    notifyListeners();
  }

  void navigateToSettingsView() {
    _navigationService.navigateWithTransition(
        const SettingsView(
          isBeforeLogin: true,
        ),
        routeName: SettingsViewNavigatorRoutes.settingsView,
        fullscreenDialog: true);
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [_packageInfoService];
}
