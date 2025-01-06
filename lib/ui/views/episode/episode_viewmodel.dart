import 'dart:io';
import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/mixin/dialog_mixin.dart';
import 'package:biot/model/episode_of_care.dart';
import 'package:biot/model/socket_info.dart';
import 'package:biot/services/pdf_service.dart';
import 'package:pdf_merger/pdf_merger_response.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.dialogs.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../model/encounter.dart';
import '../../../model/patient.dart';
import '../../../services/analytics_service.dart';
import '../../../services/cloud_service.dart';
import '../../../services/database_service.dart';

import '../../../services/logger_service.dart';
import '../complete/complete_view.dart';

class EpisodeViewModel extends BaseViewModel with OIDialog {
  final _apiService = locator<BiotService>();
  final _dialogService = locator<DialogService>();
  final _localdbService = locator<DatabaseService>();
  final _navigationService = locator<NavigationService>();
  final _pdfService = locator<PdfService>();
  final _analyticsService = locator<AnalyticsService>();
  final _logger =
      locator<LoggerService>().getLogger((EpisodeViewModel).toString());

  Patient? get currentPatient => _localdbService.currentPatient?.value;

  final Encounter encounter;
  final bool isEdit;
  bool isModified = false;

  bool isLastPage = false;

  EpisodeOfCare get episodeOfCare => _episodeOfCare;

  late EpisodeOfCare _episodeOfCare;

  EpisodeViewModel({required this.encounter, required this.isEdit}) {
    _logger.d('');

    if (isEdit) {
      _episodeOfCare = encounter.episodeOfCare!.clone();

      _episodeOfCare.socketInfoList = encounter.episodeOfCare!.socketInfoList
          .map((e) => e.clone())
          .toList();
    } else {
      _episodeOfCare = EpisodeOfCare();

      _episodeOfCare.socketInfoList = currentPatient!.amputations
          .map((e) => SocketInfo(side: e.side, dateOfDelivery: DateTime.now()))
          .toList();
    }
  }

  void uploadEncounterToCloud() async {
    _logger.d('');
    showBusyDialog();
    encounter.submitCode = Submit.initial;
    try {
      await _apiService.addEncounterWithDetails(encounter, currentPatient!);

      if (encounter.preEncounter != null) {
        await _apiService.editEncounterWithPostEncounterId(encounter);
      }

      closeBusyDialog();
      navigateToSummary();
    } catch (e) {
      closeBusyDialog();
      _analyticsService.logEpisodeUploadFail();
      exportPDF();
    }
  }

  Future<void> exportPDF({String locale = 'en'}) async {
    _logger.d('');

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
        navigateToCompleteView(pdfPath);
      } else {
        throw Exception;
      }
    } catch (e) {
      closeBusyDialog();
    }
  }

  void onChange(EpisodeOfCare value) {
    isModified = !(value == encounter.episodeOfCare);

    notifyListeners();
  }

  Future<void> onNextButtonTapped() async {
    if (isLastPage) {
      _logger.d('next button tapped on last page');

      encounter.episodeOfCare = episodeOfCare;

      if (episodeOfCare.socketInfoList
          .any((element) => element.socket == null)) {
        showConfirmIncompleteDialog();
      } else {
        uploadEncounterToCloud();
      }
    } else {
      navigateToNextPage();
    }
  }

  Future<void> navigateBack() async {
    _navigationService.back();
  }

  void showConfirmIncompleteDialog() async {
    DialogResponse? response = await _dialogService.showCustomDialog(
        variant: DialogType.confirmAlert,
        title: 'Incomplete',
        description:
            'There seem to be some questions missing a response.\nDo you still want to continue?',
        mainButtonTitle: 'No',
        secondaryButtonTitle: 'Yes, continue',
        barrierDismissible: true);

    if (response != null && response.confirmed) {
      uploadEncounterToCloud();
    }
  }

  void navigateToCompleteView(String pdfPath){
    _navigationService.replaceWithTransition(CompleteView(
      encounter,
      pdfPath: pdfPath,
    ));
  }

  void navigateToNextPage() {
    isLastPage = true;
    notifyListeners();
  }

  void navigateToSummary() {
    _navigationService.replaceWithSummaryView(
        encounter: encounter, isNewAdded: true);
  }

  void onBackButtonTapped() {
    if (isLastPage) {
      isLastPage = false;
      notifyListeners();
    } else {
      onCancelDataCollection();
    }
  }

  void onCancelDataCollection() async {
    DialogResponse? response = await _dialogService.showCustomDialog(
        variant: DialogType.cancelLeadCompass);
    if (response != null && response.confirmed) {
      navigateBack();
    }
  }
}
