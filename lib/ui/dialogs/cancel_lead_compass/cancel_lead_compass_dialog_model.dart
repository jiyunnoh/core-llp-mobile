import 'package:stacked/stacked.dart';

class CancelLeadCompassDialogModel extends BaseViewModel {
  final title = 'Exit Data Collection';
  final description = 'Please note that the data collected so far will be deleted when you proceed. Continue to exit?';
  final mainButtonTitle = 'Cancel';
  final secondaryButtonTitle = 'Exit';

  CancelLeadCompassDialogModel(){
    setBusy(true);
  }

  void onModelReady(){
    setBusy(false);
    notifyListeners();
  }
}
