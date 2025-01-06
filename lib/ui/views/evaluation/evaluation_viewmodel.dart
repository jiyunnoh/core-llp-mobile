import 'dart:async';
import 'dart:io';

import 'package:biot/mixin/dialog_mixin.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf_merger/pdf_merger_response.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.dialogs.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../constants/compass_lead_enum.dart';
import '../../../generated/locale_keys.g.dart';
import '../../../model/encounter.dart';
import '../../../model/outcome_measures/outcome_measure.dart';
import '../../../model/patient.dart';
import '../../../services/analytics_service.dart';
import '../../../services/cloud_service.dart';
import '../../../services/database_service.dart';
import '../../../services/logger_service.dart';
import '../../../services/outcome_measure_selection_service.dart';
import '../../../services/pdf_service.dart';
import '../complete/complete_view.dart';

class EvaluationViewModel extends BaseViewModel with OIDialog {
  final _navigationService = locator<NavigationService>();
  final _localdbService = locator<DatabaseService>();
  final _outcomeMeasureSelectionService =
      locator<OutcomeMeasureSelectionService>();
  final _apiService = locator<BiotService>();
  final _dialogService = locator<DialogService>();
  final _pdfService = locator<PdfService>();
  final _analyticsService = locator<AnalyticsService>();
  final _logger =
      locator<LoggerService>().getLogger((EvaluationViewModel).toString());

  int currentOutcomeIdx = 0;

  List<OutcomeMeasure> get outcomeMeasures =>
      _outcomeMeasureSelectionService.selectedOutcomeMeasures;

  OutcomeMeasure get currentOutcomeMeasure =>
      outcomeMeasures[currentOutcomeIdx];
  late Encounter encounter;

  Patient? get currentPatient => _localdbService.currentPatient?.value;
  DateTime outcomeMeasureStartTime = DateTime.now();

  EvaluationViewModel({required this.encounter}) {
    _logger.d('');
  }

  void initState() async {
    setBusy(true);

    for (var outcomeMeasure in outcomeMeasures) {
      await outcomeMeasure.build();
    }
    currentOutcomeMeasure.started();
    setBusy(false);
  }

  // void stopTts() {}

  String getCurrentOutcomeName() {
    if (Device.get().isTablet) {
      switch (currentOutcomeMeasure.id) {
        case 'psfs':
          return LocaleKeys.psfs.tr();
        case 'dash':
          return LocaleKeys.dash.tr();
        case 'scs':
          return LocaleKeys.scs.tr();
        case '10mwt':
          return LocaleKeys.tenMWT.tr();
        case 'faam':
          return LocaleKeys.faam.tr();
        case 'tug':
          return LocaleKeys.tug.tr();
        case 'promispi':
          return LocaleKeys.promispi.tr();
        case 'pmq':
          return LocaleKeys.pmq.tr();
        default:
          return currentOutcomeMeasure.name;
      }
    } else {
      return currentOutcomeMeasure.shortName;
    }
  }

  void onBackButtonTapped() {
    _logger.d('');
    currentOutcomeMeasure.completed();
    if (currentOutcomeIdx > 0) {
      previousOutcome();
    } else {
      onCancelDataCollection();
    }
  }

  void previousOutcome() {
    _logger.d('');
    currentOutcomeIdx--;
    currentOutcomeMeasure.started();
    notifyListeners();
  }

  void nextOutcome() async {
    currentOutcomeMeasure.completed();
    if (currentOutcomeIdx < outcomeMeasures.length - 1) {
      _logger.d('next');
      currentOutcomeIdx++;
      currentOutcomeMeasure.started();
      notifyListeners();
    } else {
      onFinishedDataCollection();
    }
  }

  void wrapUpCompass() async {
    _logger.d('finished evaluation');
    for (var outcomeMeasure in outcomeMeasures) {
      encounter.addOutcomeMeasure(outcomeMeasure);
    }

    encounter.encounterCreatedTimeString = DateTime.now().toUtc().toIso8601String();

    if (encounter.prefix == EpisodePrefix.post &&
        encounter.prePostEpisodeOfCare != null) {
      navigateToEpisodeView();
    } else {
      try {
        showBusyDialog();
        encounter.submitCode = Submit.initial;
        await _apiService.addEncounterWithDetails(encounter, currentPatient!);
        closeBusyDialog();
        navigateToSummary();
      } catch (e) {
        closeBusyDialog();
        _analyticsService.logEpisodeUploadFail();
        exportPDF();
        // handleHTTPError(e);
      }
    }
  }

  Future<void> exportPDF({String locale = 'en'}) async {
    _logger.d('export PDF');

    showGeneratingPDFDialog();
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      encounter.entityId = DateTime.now().millisecondsSinceEpoch.toString();
      MergeMultiplePDFResponse response = await _pdfService.exportPdf(
          encounter, currentPatient!,
          saveToDocDir: true, locale: locale);
      if (response.status == "success") {
        closeBusyDialog();
        await Future.delayed(const Duration(milliseconds: 300));
        String pdfPath = File(response.response!).path;
        //navigate to Complete view
        _navigationService.replaceWithTransition(CompleteView(
          encounter,
          pdfPath: pdfPath,
        ));
      } else {
        throw Exception;
      }
    } catch (e) {
      closeBusyDialog();
    }
  }

  void navigateToSummary() {
    _navigationService.replaceWithSummaryView(
        encounter: encounter, isNewAdded: true);
  }

  void navigateToEpisodeView() {
    _navigationService.replaceWithEpisodeView(
        encounter: encounter, isEdit: false);
  }

  void navigateToInfo() {
    _navigationService.navigateTo(Routes.outcomeMeasureInfoView,
        arguments: currentOutcomeMeasure);
  }

  void navigateBackToBottomNav() {
    _localdbService.currentPatient = null;
    _navigationService.popUntil((route) => route.isFirst);
  }

  void onFinishedDataCollection() async {
    DialogResponse? response = await _dialogService.showCustomDialog(
        variant: DialogType.confirmAlert,
        title: 'Complete',
        description:
            'Are you sure you want to continue?\nYou will not be able to edit outcome measure responses beyond this point.',
        mainButtonTitle: 'Cancel',
        secondaryButtonTitle: 'Continue');

    if (response != null && response.confirmed) {
      wrapUpCompass();
    }
  }

  void onCancelDataCollection() async {
    DialogResponse? response = await _dialogService.showCustomDialog(
        variant: DialogType.cancelLeadCompass);
    if (response != null && response.confirmed) {
      if(encounter.prefix == EpisodePrefix.pre){
        _localdbService.currentPatient!.value.amputations.clear();
      }
      navigateBackToPatientDetailView();
    }
  }

  void navigateBackToPatientDetailView() {
    _navigationService.back();
  }
}
