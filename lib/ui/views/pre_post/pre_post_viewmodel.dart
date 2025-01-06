import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/services/database_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.dialogs.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../model/encounter.dart';
import '../../../model/pre_post_episode_of_care.dart';
import '../../../services/logger_service.dart';

class PrePostViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _localdbService = locator<DatabaseService>();
  final _logger =
      locator<LoggerService>().getLogger((PrePostViewModel).toString());

  final Encounter encounter;
  final bool isEdit;

  bool get isModified =>
      isEdit ? encounter.prePostEpisodeOfCare != prePostEpisodeOfCare : false;

  List<bool> mobilityDevices = List.filled(MobilityDevice.values.length, false);

  TextEditingController dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  DateTime? pickedDate;

  PrePostEpisodeOfCare get prePostEpisodeOfCare => _prePostEpisodeOfCare;

  late PrePostEpisodeOfCare _prePostEpisodeOfCare;

  PrePostViewModel({required this.encounter, required this.isEdit}) {
    _logger.d('');

    if (isEdit) {
      _prePostEpisodeOfCare = encounter.prePostEpisodeOfCare!.clone();

      dateController.text =
          DateFormat('yyyy-MM-dd').format(prePostEpisodeOfCare.dateOfCare!);
      pickedDate = prePostEpisodeOfCare.dateOfCare;

      for (MobilityDevice elem in prePostEpisodeOfCare.mobilityDevices) {
        mobilityDevices[elem.index] = true;
      }
    } else {
      _prePostEpisodeOfCare =
          PrePostEpisodeOfCare(dateOfCare: DateTime.parse(dateController.text));
    }
  }

  void onChangeDateOfCare() {
    dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate!);
    prePostEpisodeOfCare.dateOfCare = DateTime.parse(dateController.text);

    notifyListeners();
  }

  void onChangeMobilityDevices(int index) {
    mobilityDevices[index] = !mobilityDevices[index];

    if (!mobilityDevices[index]) {
      onChangeMobilityDeviceUsage(index, null);
    }

    // no walking aids is exclusive
    if (index == MobilityDevice.noWalkingAids.index) {
      for (int i = 0; i < mobilityDevices.length; i++) {
        if (i != index) {
          mobilityDevices[i] = false;
          onChangeMobilityDeviceUsage(i, null);
        }
      }
    } else {
      mobilityDevices[MobilityDevice.noWalkingAids.index] = false;
    }

    prePostEpisodeOfCare.mobilityDevices = mobilityDevices
        .asMap()
        .entries
        .where((element) => element.value)
        .map((e) => MobilityDevice.values[e.key])
        .toList();

    notifyListeners();
  }

  void onChangeMobilityDeviceUsage(int i, MobilityDeviceUsage? value) {
    switch (i) {
      case 0:
        prePostEpisodeOfCare.noWalkingAidsUsage = null;
      case 1:
        prePostEpisodeOfCare.singlePointStickUsage = value;
      case 2:
        prePostEpisodeOfCare.quadBaseWalkingStickUsage = value;
      case 3:
        prePostEpisodeOfCare.singleCrutchUsage = value;
      case 4:
        prePostEpisodeOfCare.pairOfCrutchesUsage = value;
      case 5:
        prePostEpisodeOfCare.walkingFrameWalkerUsage = value;
      case 6:
        prePostEpisodeOfCare.wheeledWalkerUsage = value;
      case 7:
        prePostEpisodeOfCare.manualWheelchairUsage = value;
      case 8:
        prePostEpisodeOfCare.poweredWheeledOrMobilityScooterUsage = value;
    }

    notifyListeners();
  }

  void onChangeParticipation(IcfQualifiers value) {
    prePostEpisodeOfCare.communityParticipation = value;

    notifyListeners();
  }

  void onChangeParticipationWithLimb(IcfQualifiers value) {
    prePostEpisodeOfCare.communityParticipationWithLimb = value;

    notifyListeners();
  }

  void onChangeAbilityToWork(IcfQualifiers value) {
    prePostEpisodeOfCare.abilityToWork = value;

    notifyListeners();
  }

  void onChangeAbilityToWorkWithLimb(IcfQualifiers value) {
    prePostEpisodeOfCare.abilityToWorkWithLimb = value;

    notifyListeners();
  }

  void onChangeStandingTime(AmbulatoryActivityLevel value) {
    prePostEpisodeOfCare.standingTimeInHour = value;

    notifyListeners();
  }

  void onChangeWalkingTime(AmbulatoryActivityLevel value) {
    prePostEpisodeOfCare.walkingTimeInHour = value;

    notifyListeners();
  }

  void onChangeFall(YesOrNo value) {
    prePostEpisodeOfCare.fall = value;

    if (value == YesOrNo.no) {
      onChangeFallFrequency(null);
      onChangeInjury(null);
    }

    notifyListeners();
  }

  void onChangeFallFrequency(FallFrequency? value) {
    prePostEpisodeOfCare.fallFrequency = value;

    notifyListeners();
  }

  void onChangeInjury(YesOrNo? value) {
    prePostEpisodeOfCare.isInjuriousFall = value;

    notifyListeners();
  }

  void onChangeSupportAtHome(YesOrNo value) {
    prePostEpisodeOfCare.socialSupportAccess = value;

    if (value == YesOrNo.no) {
      onChangeUtilizeSupport(null);
    }

    notifyListeners();
  }

  void onChangeUtilizeSupport(YesOrNo? value) {
    prePostEpisodeOfCare.socialSupportUtil = value;

    notifyListeners();
  }

  void onChangeCommunityService(YesOrNo value) {
    prePostEpisodeOfCare.communityServiceAccess = value;

    if (value == YesOrNo.no) {
      onChangeCommunityServiceOptions(null);
    }
    notifyListeners();
  }

  void onChangeCommunityServiceOptions(CommunityService? value) {
    prePostEpisodeOfCare.communityService = value;

    notifyListeners();
  }

  void showInfoDialog({required String title, required String body}) {
    _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: title,
        data: body,
        barrierDismissible: true);
  }

  Future<void> navigateBack() async {
    _navigationService.back();
  }

  void navigateToEvaluationView() {
    encounter.prePostEpisodeOfCare = prePostEpisodeOfCare;

    _navigationService.replaceWithEvaluationView(encounter: encounter);
  }

  void onCancelDataCollection() async {
    DialogResponse? response = await _dialogService.showCustomDialog(
        barrierDismissible: true, variant: DialogType.cancelLeadCompass);
    if (response != null && response.confirmed) {
      if(encounter.prefix == EpisodePrefix.pre){
        _localdbService.currentPatient!.value.amputations.clear();
      }
      navigateBack();
    }
  }
}
