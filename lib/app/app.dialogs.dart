// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/dialogs/busy/busy_dialog.dart';
import '../ui/dialogs/cancel_lead_compass/cancel_lead_compass_dialog.dart';
import '../ui/dialogs/confirm_alert/confirm_alert_dialog.dart';
import '../ui/dialogs/info_alert/info_alert_dialog.dart';
import '../ui/dialogs/loading_indicator/loading_indicator_dialog.dart';

enum DialogType {
  infoAlert,
  confirmAlert,
  loadingIndicator,
  cancelLeadCompass,
  busy,
}

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.infoAlert: (context, request, completer) =>
        InfoAlertDialog(request: request, completer: completer),
    DialogType.confirmAlert: (context, request, completer) =>
        ConfirmAlertDialog(request: request, completer: completer),
    DialogType.loadingIndicator: (context, request, completer) =>
        LoadingIndicatorDialog(request: request, completer: completer),
    DialogType.cancelLeadCompass: (context, request, completer) =>
        CancelLeadCompassDialog(request: request, completer: completer),
    DialogType.busy: (context, request, completer) =>
        BusyDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
