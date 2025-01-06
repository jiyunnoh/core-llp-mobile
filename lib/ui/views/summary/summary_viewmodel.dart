import 'dart:async';

import 'package:async/async.dart';
import 'package:biot/app/app.locator.dart';
import 'package:biot/mixin/dialog_mixin.dart';
import 'package:biot/model/outcome_measures/outcome_measure.dart';
import 'package:biot/model/encounter.dart';
import 'package:biot/model/pre_post_episode_of_care.dart';
import 'package:biot/services/cloud_service.dart';
import 'package:biot/ui/views/complete/complete_view.dart';
import 'package:biot/ui/views/episode/episode_view.dart';
import 'package:biot/ui/views/pre_post/pre_post_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.dialogs.dart';
import '../../../app/app.router.dart';
import '../../../constants/compass_lead_enum.dart';
import '../../../model/amputation.dart';
import '../../../model/episode_of_care.dart';
import '../../../model/patient.dart';
import '../../../services/database_service.dart';
import '../../../services/logger_service.dart';
import '../../../services/outcome_measure_selection_service.dart';
import '../../common/constants.dart';
import '../amputation_form/amputation_form_view.dart';
import '../login/login_view.dart';

class SummaryViewModel extends FutureViewModel with OIDialog {
  final _apiService = locator<BiotService>();
  final _navigationService = locator<NavigationService>();
  final _localdbService = locator<DatabaseService>();
  final _dialogService = locator<DialogService>();
  final _outcomeMeasureSelectionService =
      locator<OutcomeMeasureSelectionService>();
  final _logger =
      locator<LoggerService>().getLogger((SummaryViewModel).toString());

  bool shouldDrawGraph = false;

  Patient get currentPatient => _localdbService.currentPatient!.value;

  bool get isAnonymous => _localdbService.currentPatient == null;
  String? patientID;
  BuildContext context;

  final Encounter encounter;
  final bool isNewAdded;
  ValueNotifier<bool> isLoginLoading = ValueNotifier(false);

  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();

  PrePostEpisodeOfCare? prePostEpisodeOfCare;
  EpisodeOfCare? episodeOfCare;
  late List<Amputation> amputations;

  SummaryViewModel(
      {required this.encounter,
      required this.isNewAdded,
      required this.context}) {
    _logger.d('');

    emailController.text = _apiService.userId;

    prePostEpisodeOfCare = encounter.prePostEpisodeOfCare?.clone();
    episodeOfCare = encounter.episodeOfCare?.clone();
    amputations = currentPatient.amputations.map((e) => e.clone()).toList();
  }

  @override
  Future<List<OutcomeMeasure>> futureToRun() {
    return Future.value(encounter.outcomeMeasures);
  }

  @override
  Future<void> onData(data) async {
    setBusy(true);
    if (!isNewAdded) {
      // Sort by completion order
      List<OutcomeMeasure> outcomeMeasures = data;
      outcomeMeasures.sort((a, b) => a.index!.compareTo(b.index!));
      encounter.outcomeMeasures = outcomeMeasures;
    }

    setBusy(false);
    notifyListeners();

    _logger
        .d('onData: ${encounter.outcomeMeasures!.first.exportResponses('en')}');
  }

  void clearOutcomeMeasureSelection() {
    _outcomeMeasureSelectionService.clear();
  }

  Future onSubmit() async {
    _logger.d('');
    encounter.submitCode = Submit.finish;
    try {
      FutureGroup futureGroup = FutureGroup();

      futureGroup.add(_apiService.editEncounter(encounter));

      if (!listEquals(amputations, currentPatient.amputations)) {
        for (Amputation amputation in currentPatient.amputations) {
          futureGroup.add(_apiService.editAmputation(amputation));
        }
      }

      if (prePostEpisodeOfCare != encounter.prePostEpisodeOfCare) {
        futureGroup.add(_apiService.editPrePost(
            prePostEpisodeOfCare: encounter.prePostEpisodeOfCare!));
      }

      if (episodeOfCare != null && episodeOfCare != encounter.episodeOfCare) {
        futureGroup.add(_apiService.editEpisodeOfCare(
            episodeOfCare: encounter.episodeOfCare!));
      }

      futureGroup.close();

      await futureGroup.future;

      currentPatient.encounters!.insert(0, encounter);
    } catch (e) {
      rethrow;
    }
  }

  Future deleteAmputationFromCloud() async {
    _logger.d('');

    try {
      await _apiService.deleteAmputations(currentPatient.amputations);
      currentPatient.amputations = [];
    } catch (e) {
      rethrow;
    }
  }

  void onUpdatePrePost(PrePostEpisodeOfCare value) {
    _logger.d('');

    encounter.prePostEpisodeOfCare = value;

    notifyListeners();
  }

  void onUpdateEpisodeOfCare(EpisodeOfCare value) {
    _logger.d('');

    encounter.episodeOfCare = value;

    notifyListeners();
  }

  void showConfirmDialog() async {
    DialogResponse? response = await _dialogService.showCustomDialog(
        variant: DialogType.confirmAlert,
        title: 'Submit',
        description:
            'Please note that changes cannot be made after submission.\nProceed with submission?',
        mainButtonTitle: 'Cancel',
        secondaryButtonTitle: 'Submit');

    if (response != null && response.confirmed) {
      try {
        showBusyDialog();

        await onSubmit();

        closeBusyDialog();

        navigateToCompleteView();
      } catch (e) {
        closeBusyDialog();

        handleHTTPError(e);
      }
    }
  }

  void onCancelSubmit() async {
    DialogResponse? response = await _dialogService.showCustomDialog(
        variant: DialogType.confirmAlert,
        title: 'Exit',
        description:
            'Please note that the data collected so far will be marked for deletion when you proceed without submitting. Continue to exit?',
        mainButtonTitle: 'Cancel',
        secondaryButtonTitle: 'Exit');

    if (response != null && response.confirmed) {
      //We need to delete submitted amputation information when we are cancel submitting Pre Episode.
      //Otherwise active patient object will refer to amputation object that we created earlier in this
      //cancelled path.
      if (encounter.prefix == EpisodePrefix.pre) {
        try {
          showBusyDialog();

          await deleteAmputationFromCloud();

          closeBusyDialog();

          navigateToPatientDetailView();
        } catch (e) {
          closeBusyDialog();

          handleHTTPError(e);
        }
      } else {
        navigateToPatientDetailView();
      }
    }
  }

  void navigateToPatientDetailView() {
    _logger.d('');
    _navigationService
        .popUntil((route) => route.settings.name == Routes.patientDetailView);
  }

  Future<void> navigateToLogInView() async {
    await _navigationService.navigateWithTransition(
        LoginView(isAuthCheck: true),
        fullscreenDialog: true);
  }

  void navigateToHomeTab() {
    BottomNavigationBar bar = bottomNavKey.currentWidget as BottomNavigationBar;
    bar.onTap!(1);
  }

  Future<void> navigateToCompleteView() async {
    await _navigationService.replaceWithTransition(CompleteView(encounter));
  }

  Future<void> navigateToAmputationView() async {
    await _navigationService.navigateWithTransition(
        AmputationFormView(encounter: encounter, isEdit: true),
        fullscreenDialog: true);
  }

  Future<void> navigateToPrePostView() async {
    await _navigationService.navigateWithTransition(
        PrePostView(encounter,
            isEdit: true, onUpdate: (value) => onUpdatePrePost(value)),
        fullscreenDialog: true);
  }

  Future<void> navigateToEpisodeView() async {
    await _navigationService.navigateWithTransition(
        EpisodeView(encounter,
            isEdit: true, onUpdate: (value) => onUpdateEpisodeOfCare(value)),
        fullscreenDialog: true);
  }
}
