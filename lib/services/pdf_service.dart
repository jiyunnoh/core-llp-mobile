import 'dart:convert';
import 'dart:io';

import 'package:biot/constants/compass_lead_enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../app/app.locator.dart';
import '../model/encounter.dart';
import '../model/outcome_measures/outcome_measure.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pdf_merger/pdf_merger.dart';

import '../model/patient.dart';
import 'logger_service.dart';

class PdfService {
  final _logger = locator<LoggerService>().getLogger((PdfService).toString());

  late NumberFormat numberFormatter;
  late String dirPath;

  // TODO: Translate 'Patient ID', and 'Date' into selected language
  Future<MergeMultiplePDFResponse> exportPdf(
    Encounter encounter,
    Patient patient, {
    bool saveToDocDir = false,
    String locale = 'en',
  }) async {
    print('real export PDF');
    _logger.d('');

    DateTime sessionDate =
        DateTime.now(); //encounter.encounterCreatedTimeString!;
    numberFormatter = NumberFormat.decimalPattern(locale);
    Directory directory = await path_provider.getTemporaryDirectory();
    dirPath = directory.path;
    List<String> filesPath = [];

    filesPath.add(await _createClientPage(encounter, patient, sessionDate));

    if (encounter.prePostEpisodeOfCare != null) {
      filesPath.add(await _createPrePostPage(encounter, patient, sessionDate));
    }

    if (encounter.episodeOfCare != null) {
      filesPath
          .add(await _createEpisodeOfCarePage(encounter, patient, sessionDate));
    }

    filesPath.add(await _createCover(encounter, patient, sessionDate));
    filesPath
        .addAll(await _createOutcomeMeasures(encounter, patient, sessionDate));
    String lastEight =
        encounter.entityId!.substring(encounter.entityId!.length - 8);
    if (saveToDocDir) {
      directory = await path_provider.getApplicationDocumentsDirectory();
      dirPath = "${directory.path}/_upload_failed";
      await Directory(dirPath).create();
    }
    String outputPath = '$dirPath/CL_${patient.id}_$lastEight.pdf';
    return PdfMerger.mergeMultiplePDF(
        paths: filesPath, outputDirPath: outputPath);
  }

  Future<String> _createClientPage(
      Encounter encounter, Patient patient, DateTime sessionDate,
      {String locale = 'en'}) async {
    _logger.d('');

    ByteData data =
        await rootBundle.load('packages/comet_foundation/pdf/client_page.pdf');
    PdfDocument clientPageDoc =
        PdfDocument(inputBytes: data.buffer.asUint8List());

    print(patient.toJsonForPDF());

    Map<String, dynamic> pdfJson = patient.toJsonForPDF();

    for (var i = 0; i < patient.amputations.length; i++) {
      Map<String, dynamic> amputationJson =
          patient.amputations[i].toJsonForPDF(i);
      pdfJson.addAll(amputationJson);
    }

    print(pdfJson);

    //import data into pdf form
    clientPageDoc.form
        .importData(utf8.encode(jsonEncode(pdfJson)), DataFormat.json);
    clientPageDoc.form.flattenAllFields();

    await _addHeaderFooterForCOMPASS(
        clientPageDoc, patient.id, sessionDate, locale);
    File clientPageFile = await File('$dirPath/${patient.id}_client_page.pdf')
        .writeAsBytes(await clientPageDoc.save());
    clientPageDoc.dispose();
    return clientPageFile.path;
  }

  Future<String> _createPrePostPage(
      Encounter encounter, Patient patient, DateTime sessionDate,
      {String locale = 'en'}) async {
    _logger.d('');

    ByteData data = await rootBundle
        .load('packages/comet_foundation/pdf/pre_post_page.pdf');
    PdfDocument prePostPageDoc =
        PdfDocument(inputBytes: data.buffer.asUint8List());
    PdfPage firstPage = prePostPageDoc.pages[0];
    PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 14,
        multiStyle: [PdfFontStyle.bold]);
    Size pageSize = prePostPageDoc.pageSettings.size;
    // Jung - Example rectangle drawing in the center of the page
    // firstPage.graphics.drawRectangle(pen: PdfPens.black, bounds: Rect.fromLTWH(
    //     (pageSize.width-200)/2, 120, 200, 40));
    // TODO: Jung - change header according to the encounter prefix.
    firstPage.graphics.drawString(
        "${encounter.prefix!.displayName} Episode", headerFont,
        bounds: Rect.fromLTWH((pageSize.width - 200) / 2, 120, 200, 40),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    print(encounter.prePostEpisodeOfCare!.toJsonForPDF());

    //import data into pdf form
    prePostPageDoc.form.importData(
        utf8.encode(jsonEncode(encounter.prePostEpisodeOfCare!.toJsonForPDF())),
        DataFormat.json);
    prePostPageDoc.form.flattenAllFields();

    await _addHeaderFooterForCOMPASS(
        prePostPageDoc, patient.id, sessionDate, locale);
    File prePostPageFile =
        await File('$dirPath/${patient.id}_pre_post_page.pdf')
            .writeAsBytes(await prePostPageDoc.save());
    prePostPageDoc.dispose();
    return prePostPageFile.path;
  }

  Future<String> _createEpisodeOfCarePage(
      Encounter encounter, Patient patient, DateTime sessionDate,
      {String locale = 'en'}) async {
    _logger.d('');

    ByteData data = await rootBundle
        .load('packages/comet_foundation/pdf/episode_of_care_page.pdf');
    PdfDocument epCarePageDoc =
        PdfDocument(inputBytes: data.buffer.asUint8List());

    print(encounter.episodeOfCare!.toJsonForPDF());

    Map<String, dynamic> pdfJson = encounter.episodeOfCare!.toJsonForPDF();

    for (var i = 0; i < encounter.episodeOfCare!.socketInfoList.length; i++) {
      Map<String, dynamic> socketInfoJson =
          encounter.episodeOfCare!.socketInfoList[i].toJsonForPDF(i);
      pdfJson.addAll(socketInfoJson);
    }

    print(pdfJson);

    //import data into pdf form
    epCarePageDoc.form
        .importData(utf8.encode(jsonEncode(pdfJson)), DataFormat.json);
    epCarePageDoc.form.flattenAllFields();

    await _addHeaderFooterForCOMPASS(
        epCarePageDoc, patient.id, sessionDate, locale);
    File epCarePageFile =
        await File('$dirPath/${patient.id}_episode_of_care_page.pdf')
            .writeAsBytes(await epCarePageDoc.save());
    epCarePageDoc.dispose();
    return epCarePageFile.path;
  }

  Future<List<String>> _createOutcomeMeasures(
      Encounter encounter, Patient patient, DateTime sessionDate,
      {String locale = 'en'}) async {
    _logger.d('');

    List<String> filePaths = [];
    for (var i = 0; i < encounter.outcomeMeasures!.length; i++) {
      OutcomeMeasure outcome = encounter.outcomeMeasures![i];
      ByteData data;
      try {
        data = await rootBundle.load(
            'packages/comet_foundation/pdf/${outcome.id}_${locale.toString()}.pdf');
      } catch (e) {
        data = await rootBundle
            .load('packages/comet_foundation/pdf/${outcome.id}_en.pdf');
      }

      PdfDocument document = PdfDocument(inputBytes: data.buffer.asUint8List());
      await _addHeaderFooterForCOMPASS(document, patient.id, sessionDate, 'en',
          outcome: outcome);

      print(outcome.exportResponses(locale));

      document.form.importData(
          utf8.encode(jsonEncode(outcome.exportResponses(locale))),
          DataFormat.json);
      document.form.flattenAllFields();

      File file = await File('$dirPath/${outcome.id}.pdf')
          .writeAsBytes(await document.save());
      document.dispose();
      filePaths.add(file.path);
    }
    return filePaths;
  }

  Future<String> _createCover(
      Encounter encounter, Patient patient, DateTime sessionDate,
      {String locale = 'en'}) async {
    _logger.d('');

    ByteData data =
        await rootBundle.load('packages/comet_foundation/pdf/cover.pdf');
    PdfDocument coverDoc = PdfDocument(inputBytes: data.buffer.asUint8List());
    await _addHeaderFooterForCOMPASS(coverDoc, patient.id, sessionDate, locale);
    PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 14,
        multiStyle: [PdfFontStyle.bold, PdfFontStyle.underline]);
    PdfFont outcomeFont = PdfStandardFont(PdfFontFamily.helvetica, 14);
    PdfFont scoreFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      12,
    );
    double titleHeaderLeft = 210;
    double headerLeft = 75;
    double scoreTitleLeft = 105;
    double headerHeight = 40;
    double scoreHeight = 24;
    double currentTop = 120;
    Size pageSize = coverDoc.pageSettings.size;
    PdfPage coverPage = coverDoc.pages[0];
    coverPage.graphics.drawString("Outcome Measures Completed", headerFont,
        bounds: Rect.fromLTWH(
            titleHeaderLeft, currentTop, pageSize.width, headerHeight));
    currentTop += headerHeight;
    for (var i = 0; i < encounter.outcomeMeasures!.length; i++) {
      OutcomeMeasure outcome = encounter.outcomeMeasures![i];
      List<String> scores = [];
      if (outcome.totalScore.isNotEmpty) {
        scores.clear();
        outcome.totalScore.forEach((key, value) => scores.add(value));
      }
      coverPage.graphics.drawString(outcome.name, outcomeFont,
          bounds: Rect.fromLTWH(
              headerLeft, currentTop, pageSize.width, headerHeight));
      currentTop += headerHeight;
      // if (scores.isNotEmpty) {
      //   for (var j = 0; j < scores.length; j++) {
      //     print(scoreHeight);
      //     scoreHeight += scoreHeight *
      //         '\n'.allMatches(outcome.getSummaryScoreTitle(j)).length;
      //     print(scoreHeight);
      //     coverPage.graphics.drawString(
      //         "${outcome.getSummaryScoreTitle(j)}", scoreFont,
      //         bounds: Rect.fromLTWH(
      //             scoreTitleLeft, currentTop, pageSize.width / 3, scoreHeight));
      //     coverPage.graphics.drawString("${scores[j]}", scoreFont,
      //         bounds: Rect.fromLTWH(scoreTitleLeft + pageSize.width / 3 + 200,
      //             currentTop, pageSize.width, scoreHeight));
      //     currentTop += scoreHeight;
      //   }
      // } else {
      //   coverPage.graphics.drawString(
      //       AppLocalizations.of(context).seeDetailedReport, scoreFont,
      //       bounds: Rect.fromLTWH(
      //           scoreTitleLeft, currentTop, pageSize.width / 3, scoreHeight));
      //   currentTop += scoreHeight;
      // }
    }
    File coverFile = await File('$dirPath/${patient.id}_cover.pdf')
        .writeAsBytes(await coverDoc.save());
    coverDoc.dispose();
    return coverFile.path;
  }

  Future<void> _addHeaderFooterForCOMPASS(PdfDocument document,
      String patientID, DateTime sessionDate, String locale,
      {OutcomeMeasure? outcome}) async {
    numberFormatter = NumberFormat.decimalPattern(locale);
    PdfBitmap compassLogo = PdfBitmap(await _readImageData("compass.png"));
    PdfBitmap oiLogo = PdfBitmap(await _readImageData("oi-logo.png"));
    PdfBitmap ispoLogo = PdfBitmap(await _readImageData("ispo.png"));
    PdfBitmap atscaleLogo = PdfBitmap(await _readImageData("atscale.png"));
    DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('E, MM/dd/yyyy');
    final String value = formatter.format(now);
    PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 12,
        multiStyle: [PdfFontStyle.bold]);
    for (int i = 0; i < document.pages.count; i++) {
      PdfPage page = document.pages[i];
      page.graphics
          .drawImage(compassLogo, const Rect.fromLTWH(420, 40, 128, 45));
      page.graphics.drawString("Date: $value", headerFont,
          bounds: const Rect.fromLTWH(75, 45, 200, 60));
      page.graphics.drawString("Client ID: $patientID", headerFont,
          bounds: const Rect.fromLTWH(75, 70, 300, 60));
      page.graphics.drawImage(
          atscaleLogo,
          Rect.fromLTWH(
              60, document.pages[0].getClientSize().height - 90, 96, 32));
      page.graphics.drawImage(
          ispoLogo,
          Rect.fromLTWH(document.pages[0].getClientSize().width / 2 - 48,
              document.pages[0].getClientSize().height - 90, 96, 32));
      page.graphics.drawImage(
          oiLogo,
          Rect.fromLTWH(document.pages[0].getClientSize().width - 165,
              document.pages[0].getClientSize().height - 90, 96, 32));
      // if (outcome != null) {
      //   double textWidth = 100;
      //   page.graphics.drawString(outcome.shortName, headerFont,
      //       bounds: Rect.fromLTWH(
      //           document.pages[0].getClientSize().width / 2 - textWidth / 2,
      //           document.pages[0].getClientSize().height - 90,
      //           textWidth,
      //           60),
      //       format: PdfStringFormat(alignment: PdfTextAlignment.center));
      // }
    }
  }

  Future<void> _addHeaderFooterForCOMET(PdfDocument document, String patientID,
      DateTime sessionDate, String locale,
      {OutcomeMeasure? outcome}) async {
    numberFormatter = NumberFormat.decimalPattern(locale);
    PdfBitmap cometLogo = PdfBitmap(await _readImageData("COMET_logo.png"));
    PdfBitmap oiLogo = PdfBitmap(await _readImageData("oi-logo.png"));
    DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('E, MM/dd/yyyy');
    final String value = formatter.format(now);
    PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 12,
        multiStyle: [PdfFontStyle.bold]);
    for (int i = 0; i < document.pages.count; i++) {
      PdfPage page = document.pages[i];
      page.graphics.drawImage(cometLogo, const Rect.fromLTWH(420, 40, 128, 45));
      page.graphics.drawString("Date: $value", headerFont,
          bounds: const Rect.fromLTWH(75, 45, 200, 60));
      page.graphics.drawString("Patient ID: $patientID", headerFont,
          bounds: const Rect.fromLTWH(75, 70, 200, 60));
      page.graphics.drawImage(
          oiLogo,
          Rect.fromLTWH(
              75, document.pages[0].getClientSize().height - 90, 96, 32));
      if (outcome != null) {
        double textWidth = 100;
        page.graphics.drawString(outcome.shortName, headerFont,
            bounds: Rect.fromLTWH(
                document.pages[0].getClientSize().width / 2 - textWidth / 2,
                document.pages[0].getClientSize().height - 90,
                textWidth,
                60),
            format: PdfStringFormat(alignment: PdfTextAlignment.center));
      }
    }
  }

  Future<List<int>> _readImageData(String name) async {
    final ByteData data =
        await rootBundle.load('packages/comet_foundation/images/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
