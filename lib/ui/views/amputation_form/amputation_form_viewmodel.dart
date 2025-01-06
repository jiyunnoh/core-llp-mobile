import 'package:async/async.dart';
import 'package:biot/constants/amputation_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.dialogs.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../mixin/dialog_mixin.dart';
import '../../../model/amputation.dart';
import '../../../model/encounter.dart';
import '../../../model/patient.dart';
import '../../../services/cloud_service.dart';
import '../../../services/database_service.dart';
import '../../../services/logger_service.dart';

class AmputationFormViewModel extends BaseViewModel with OIDialog{
  final _navigationService = locator<NavigationService>();
  final _localdbService = locator<DatabaseService>();
  final _dialogService = locator<DialogService>();
  final _apiService = locator<BiotService>();
  final _logger = locator<LoggerService>().getLogger((AmputationFormViewModel).toString());

  GlobalKey<FormState> amputationFormKey = GlobalKey<FormState>();

  final Encounter? encounter;

  Patient get currentPatient => _localdbService.currentPatient!.value;
  final bool isEdit;
  final bool isAmputationUpdate;
  late List<Amputation> _amputations;

  List<Amputation> get amputations => _amputations;

  bool get isModified =>
      isEdit ? !listEquals(currentPatient.amputations, amputations) : false;

  AmputationFormViewModel({required this.encounter, required this.isEdit, required this.isAmputationUpdate}) {
    _logger.d('');

    if (isEdit) {
      _amputations = currentPatient.amputations.map((e) => e.clone()).toList();
    } else {
      _amputations = [];
      createNewAmputation();
    }
  }

  void createNewAmputation() {
    _logger.d('');
    _amputations.add(Amputation());
    notifyListeners();
  }

  void removeAmputation(int index) {
    _logger.d('');

    _amputations.removeAt(index);
    notifyListeners();
  }

  void onChangeAmputationSide(int index, value) {
    amputations[index].side = value;
    notifyListeners();
  }

  void onChangeDateOfAmputation(int index, value) {
    amputations[index].dateOfAmputation = value;
    notifyListeners();
  }

  void onChangeCauseOfAmputation(int index, value) {
    amputations[index].cause = value;
    notifyListeners();
  }

  void onChangeOtherCauseOfAmputation(int index, value) {
    amputations[index].otherPrimaryCause = value;
    notifyListeners();
  }

  void onChangeTypeOfAmputation(int index, value) {
    amputations[index].type = value;
    notifyListeners();
  }

  void onChangeLevelOfAmputation(int index, value) {
    amputations[index].level = value;
    if(value == LevelOfAmputation.hemicorporectomy){
      amputations[index].side = AmputationSide.hemicorporectomy;
    }else{
      if(amputations.length <= currentPatient.amputations.length){
        amputations[index].side = currentPatient.amputations[index].side;
      }else{
        amputations[index].side = null;
      }
    }
    notifyListeners();
  }

  void onChangeAbilityToWalk(int index, value) {
    amputations[index].abilityToWalk = value;
    notifyListeners();
  }

  void showInfoDialog({required String title, required String body}) {
    _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: title,
        data: body,
        barrierDismissible: true);
  }

  void validateForm() {
    _logger.d('');

    final isAmputationFormValid = amputationFormKey.currentState?.validate();
    if (isAmputationFormValid!) {
      if(isAmputationUpdate){
        updateCloud();
      }else{
        currentPatient.amputations = amputations;
        navigateToNext();
      }
    }
  }

  void updateCloud() async{
    try{
      showBusyDialog();
      FutureGroup futureGroup = FutureGroup();
      for (int i = 0; i < amputations.length; i++) {
        Amputation amputation = amputations[i];
        futureGroup.add(
            _apiService.addAmputation(amputation, patient: currentPatient));
      }
      futureGroup.close();
      await futureGroup.future;
      closeBusyDialog();
      currentPatient.amputations = amputations;
      navigateToNext();
    }catch(e){
      print('transmission failed');
      closeBusyDialog();
      handleHTTPError(e);
    }
  }

  void navigateToNext() {
    if (isEdit) {
      _navigationService.back();
    } else {
      if(encounter != null) {
        _navigationService.replaceWithPrePostView(
            encounter: encounter!, isEdit: false);
      }
    }
  }

  void onCancelDataCollection() async{
    DialogResponse? response = await _dialogService.showCustomDialog(
        variant: DialogType.cancelLeadCompass,
      barrierDismissible: true
    );
    if (response != null && response.confirmed) {
      navigateBack();
    }
  }

  void navigateBack() {
    _navigationService.back();
  }
}
