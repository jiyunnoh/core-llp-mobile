import 'package:biot/app/app.router.dart';
import 'package:biot/mixin/dialog_mixin.dart';
import 'package:biot/services/analytics_service.dart';
import 'package:biot/ui/views/app_description/app_description_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app.dialogs.dart';
import '../../../app/app.locator.dart';
import '../../../services/cloud_service.dart';
import '../../../services/logger_service.dart';
import '../../../services/package_info_service.dart';

class SettingsViewModel extends BaseViewModel with OIDialog {
  final _navigationService = locator<NavigationService>();
  final _apiService = locator<BiotService>();
  final _dialogService = locator<DialogService>();
  final _packageInfoService = locator<PackageInfoService>();
  final _logger =
      locator<LoggerService>().getLogger((SettingsViewModel).toString());
  final _analyticsService = locator<AnalyticsService>();

  bool isBeforeLogin;

  SettingsViewModel({this.isBeforeLogin = false}) {
    _logger.d('');
  }

  String get appVersion => (_packageInfoService.info == null)
      ? ''
      : '${_packageInfoService.info!.version} (${_packageInfoService.info!.buildNumber})';

  void dataPrivacyTapped() {
    launchUrl(Uri.parse('https://orthocareinnovations.com/privacy-policy/'),
        mode: LaunchMode.inAppWebView);
  }

  void sendEmailTapped() async {
    final Email email = Email(
        recipients: ['z3542423@ad.unsw.edu.au'],
        subject: 'RE: Core LLP Support');
    await FlutterEmailSender.send(email);
  }

  void navigateToAppDescriptionView() {
    if (isBeforeLogin) {
      _navigationService.navigateWithTransition(const AppDescriptionView(),
          routeName: SettingsViewNavigatorRoutes.appDescriptionView);
    } else {
      _navigationService
          .navigateTo(SettingsViewNavigatorRoutes.appDescriptionView, id: 2);
    }
  }

  void showConfirmLogoutDialog(BuildContext context) async {
    DialogResponse? response = await _dialogService.showCustomDialog(
        variant: DialogType.confirmAlert,
        title: 'Are you sure you want to log out?',
        mainButtonTitle: 'Cancel',
        secondaryButtonTitle: 'Log out');

    if (response != null && response.confirmed) {
      try {
        _apiService.logOut();
        _analyticsService.logLogout();
        _navigationService.back();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You are logged out!'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.black,
        ));
      } catch (e) {
        handleHTTPError(e);
      }
    }
  }
}
