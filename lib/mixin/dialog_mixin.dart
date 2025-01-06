import 'package:http/http.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../app/app.dialogs.dart';
import '../app/app.locator.dart';
import '../services/cloud_service.dart';
import '../services/logger_service.dart';

mixin OIDialog on BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _mixinLogger =
      locator<LoggerService>().getLogger((OIDialog).toString());

  Future<DialogResponse?> showClientIDWarning(String id) async{
    _mixinLogger.d('');
    return _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Save Client ID',
      description: 'Please write down the client\'s ID, ${id}',
      barrierDismissible: false,
      mainButtonTitle: 'OK'
    );
  }

  Future<DialogResponse?> showPostEpisodeWarning() async {
    _mixinLogger.d('');
    return _dialogService.showCustomDialog(
        variant: DialogType.confirmAlert,
        title: 'Warning',
        description:
            'Proceeding will create a post-episode without a corresponding pre-episode. Are you sure you want to continue?',
        mainButtonTitle: 'Cancel',
        secondaryButtonTitle: 'Proceed');
  }

  Future<void> showGeneratingPDFDialog() async {
    _mixinLogger.d('');
    _dialogService.showCustomDialog(
        variant: DialogType.busy,
        title: 'Generating PDF',
        description:
            "Your PDF report is being generated.\nThis may take up to 1 minute.");
  }

  Future<void> showBusyDialog() async {
    _mixinLogger.d('');
    _dialogService.showCustomDialog(variant: DialogType.loadingIndicator);
  }

  void closeBusyDialog() {
    _mixinLogger.d('close');

    _dialogService.completeDialog(DialogResponse(confirmed: true));
  }

  void showBadRequest() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Error',
      description: 'Please contact your study administrator.',
    );
  }

  void showServerError() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Server Error',
      description:
          'The server encountered an error and could not complete your request.\nIf the problem persists, please report your problem and mention this error message and the query that caused it.',
    );
  }

  void showCommunicationError() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Communication Error',
      description: 'Please check the network connection.',
    );
  }

  void showAlreadyExist() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Email Already Exists!',
      description: 'Please try again with another one.',
    );
  }

  void showCannotDeleteDialog() {
    _dialogService.showCustomDialog(
        variant: DialogType.confirmAlert,
        title: 'This Patient is already referenced by another entity.',
        description: 'Please delete all sessions and try again.',
        mainButtonTitle: 'Cancel');
  }

  Future<void> showLoginError(UnauthorisedException e) async {
    _mixinLogger.d('');

    DialogResponse? response = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Login Error!',
      description:
          //TODO: Jiyun - e.crc16 code
          'Please check your email and password. (${e.response.statusCode})',
    );

    if (response != null && response.confirmed) {
      _mixinLogger.d('close');
    }

    notifyListeners();
  }

  void handleHTTPError(Object e) {
    _mixinLogger.d('Failed: $e');

    if (e is ClientException) {
      // There is a transport-level failure when communication with the server.
      // For example, the server could not be reached.
      showCommunicationError();
    }
    if (e is UnauthorisedException) {
      showLoginError(e);
    }
    if (e is BadRequestException) {
      showBadRequest();
    }
    if (e is ServerErrorException) {
      showServerError();
    }
  }
}
