import 'dart:io';

import 'package:biot/mixin/dialog_mixin.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf_merger/pdf_merger_response.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../model/encounter.dart';
import '../../../model/patient.dart';
import '../../../services/database_service.dart';
import '../../../services/logger_service.dart';
import '../../../services/pdf_service.dart';

class CompleteViewModel extends BaseViewModel with OIDialog{
  final _navigationService = locator<NavigationService>();
  final _localdbService = locator<DatabaseService>();
  final _pdfService = locator<PdfService>();
  final _logger =
      locator<LoggerService>().getLogger((CompleteViewModel).toString());

  bool get isAnonymous => _localdbService.currentPatient == null;

  String? patientID;

  Patient get currentPatient => _localdbService.currentPatient!.value;
  final Encounter encounter;
  String? pdfPath;

  CompleteViewModel({required this.encounter, required this.pdfPath}) {
    _logger.d('');
  }

  Future<void> exportPDF({String locale = 'en'}) async {
    _logger.d('export PDF');

    if (!isAnonymous) {
      patientID = _localdbService.currentPatient?.value.id;
    }

    if (pdfPath != null) {
      _navigationService.back();
      OpenResult result =
          await OpenFilex.open(pdfPath, type: 'application/pdf');
      if (result.type == ResultType.noAppToOpen) {
        //TODO: JK- display no reader alert
        _logger.d('no pdf reader is available');
      }
    } else {
      MergeMultiplePDFResponse response = await _pdfService
          .exportPdf(encounter, currentPatient, locale: locale);
      // TODO: workaround to navigate to back. WillPopScope
      _navigationService.back();
      if (response.status == "success") {
        final file = File(response.response!);
        OpenResult result =
            await OpenFilex.open(file.path, type: 'application/pdf');
        if (result.type == ResultType.noAppToOpen) {
          //TODO: JK- display no reader alert
          _logger.d('no pdf reader is available');
        }
      } else {
        _logger.d('failed to export pdf');
      }
    }
  }

  void onGenerateReportButtonTapped() async {
    showGeneratingPDFDialog();
    await Future.delayed(
        const Duration(milliseconds: 500));
    exportPDF();
  }

  void navigateToPatientList() {
    _logger.d('');
    _navigationService.popUntil((route) =>
        route.settings.name == '/${BottomNavViewRoutes.patientViewNavigator}');
  }

  void surveyForPatientTapped() {
    launchUrl(Uri.parse('https://www.surveymonkey.com/r/L57FHP8'),
        mode: LaunchMode.inAppWebView);
  }
}
