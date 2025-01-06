import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biot/app/app.locator.dart';
import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/model/episode_of_care.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../helpers/test_helpers.dart';

void main() {
  late EpisodeOfCare episodeOfCare;
  late PdfDocument pdf;

  setUp(() async {
    registerServices();

    episodeOfCare = EpisodeOfCare();
    Uint8List data = await File(
            '${Directory.current.path}/test/test_resources/episode_of_care_page.pdf')
        .readAsBytes();
    pdf = PdfDocument(inputBytes: data);
  });

  tearDown(() => locator.reset());

  // group(
  //     'Verify that all input can be imported into appropriate PDF form for export. - Episode',
  //     () {
  /// **Test ID**: TC-LERC-008A
  /// **Objective**: Verify that PDF form is correct when all questions are not answered.
  /// **Preconditions**: None.
  /// **Test Steps**:
  ///   1. Make sure all answered are not answered except the date which is prefilled.
  ///   2. Complete the process and tap 'Export Report' button.
  ///   3. Verify that PDF form is correctly filled in.
  /// **Automated**: Yes
  test(
      'TC-LERC-008A - Verify that PDF form is correct when all questions are not answered.',
      () {
    expect(episodeOfCare.toJsonForPDF(), {});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);
  });

  /// **Test ID**: TC-LERC-008B
  /// **Objective**: Verify that PDF form is correct for height and weight questions.
  /// **Preconditions**: None.
  /// **Test Steps**:
  ///   1. Fill out height and weight value.
  ///   2. Complete the process and tap 'Export Report' button.
  ///   3. Verify that PDF form is correctly filled in.
  /// **Automated**: Yes
  test(
      'TC-LERC-008B - Verify that PDF form is correct for height and weight questions.',
      () {
    // Fill out height value;
    episodeOfCare.height = 180;
    expect(episodeOfCare.toJsonForPDF(), {'height': '180.0'});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Fill out weight value;
    episodeOfCare.weight = 65;
    expect(episodeOfCare.toJsonForPDF(), {'height': '180.0', 'weight': '65.0'});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);
  });

  /// **Test ID**: TC-LERC-008C
  /// **Objective**: Verify that PDF form is correct for tobacco usage question.
  /// **Preconditions**: None.
  /// **Test Steps**:
  ///   1. Tap one of options for tobacco usage question.
  ///   2. Complete the process and tap 'Export Report' button.
  ///   3. Verify that PDF form is correctly filled in.
  ///   4. Repeat for all other options.
  /// **Automated**: Yes
  test(
      'TC-LERC-008C - Verify that PDF form is correct for tobacco usage question.',
      () {
    // Select 'Never'
    episodeOfCare.tobaccoUsage = TobaccoUsage.never;
    expect(episodeOfCare.toJsonForPDF(),
        {'tobacco_usage': TobaccoUsage.never.displayName});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'Once or twice'
    episodeOfCare.tobaccoUsage = TobaccoUsage.onceOrTwice;
    expect(episodeOfCare.toJsonForPDF(),
        {'tobacco_usage': TobaccoUsage.onceOrTwice.displayName});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'Monthly'
    episodeOfCare.tobaccoUsage = TobaccoUsage.monthly;
    expect(episodeOfCare.toJsonForPDF(),
        {'tobacco_usage': TobaccoUsage.monthly.displayName});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'Weekly'
    episodeOfCare.tobaccoUsage = TobaccoUsage.weekly;
    expect(episodeOfCare.toJsonForPDF(),
        {'tobacco_usage': TobaccoUsage.weekly.displayName});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'Daily or almost daily'
    episodeOfCare.tobaccoUsage = TobaccoUsage.dailyOrAlmostDaily;
    expect(episodeOfCare.toJsonForPDF(),
        {'tobacco_usage': TobaccoUsage.dailyOrAlmostDaily.displayName});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);
  });

  /// **Test ID**: TC-LERC-008D
  /// **Objective**: Verify that PDF form is correct for max education question.
  /// **Preconditions**: None.
  /// **Test Steps**:
  ///   1. Tap one of options for max education question.
  ///   2. Complete the process and tap 'Export Report' button.
  ///   3. Verify that PDF form is correctly filled in.
  ///   4. Repeat for all other options.
  /// **Automated**: Yes
  test(
      'TC-LERC-008D - Verify that PDF form is correct for max education question.',
      () {
    // Select 'No formal education attended'
    episodeOfCare.maxEducationLevel = MaxEducationLevel.noFormalEducation;
    expect(episodeOfCare.toJsonForPDF(),
        {'education_level': MaxEducationLevel.noFormalEducation.displayName});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'Early childhood'
    episodeOfCare.maxEducationLevel = MaxEducationLevel.earlyChildhoodEducation;
    expect(episodeOfCare.toJsonForPDF(), {
      'education_level': MaxEducationLevel.earlyChildhoodEducation.displayName
    });
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'Primary school'
    episodeOfCare.maxEducationLevel = MaxEducationLevel.primarySchool;
    expect(episodeOfCare.toJsonForPDF(),
        {'education_level': MaxEducationLevel.primarySchool.displayName});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'Lower secondary'
    episodeOfCare.maxEducationLevel = MaxEducationLevel.lowerSecondaryEducation;
    expect(episodeOfCare.toJsonForPDF(), {
      'education_level': MaxEducationLevel.lowerSecondaryEducation.displayName
    });
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'Secondary school'
    episodeOfCare.maxEducationLevel = MaxEducationLevel.secondarySchool;
    expect(episodeOfCare.toJsonForPDF(),
        {'education_level': MaxEducationLevel.secondarySchool.displayName});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'Post-secondary technical qualification'
    episodeOfCare.maxEducationLevel =
        MaxEducationLevel.postSecondaryTechnicalQualification;
    expect(episodeOfCare.toJsonForPDF(), {
      'education_level':
          MaxEducationLevel.postSecondaryTechnicalQualification.displayName
    });
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'University degree'
    episodeOfCare.maxEducationLevel = MaxEducationLevel.universityDegree;
    expect(episodeOfCare.toJsonForPDF(),
        {'education_level': MaxEducationLevel.universityDegree.displayName});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'Postgraduate degree'
    episodeOfCare.maxEducationLevel = MaxEducationLevel.postgraduateDegree;
    expect(episodeOfCare.toJsonForPDF(),
        {'education_level': MaxEducationLevel.postgraduateDegree.displayName});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);
  });

  /// **Test ID**: TC-LERC-008E
  /// **Objective**: Verify that PDF form is correct for ICD code question.
  /// **Preconditions**: None.
  /// **Test Steps**:
  ///   1. Fill in ICD code.
  ///   2. Complete the process and tap 'Export Report' button.
  ///   3. Verify that PDF form is correctly filled in.
  /// **Automated**: Yes
  test('TC-LERC-008E - Verify that PDF form is correct for ICD code question.',
      () {
    episodeOfCare.icdCodesOfConditions = 'A001';
    expect(episodeOfCare.toJsonForPDF(), {'icd_code': 'A001'});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);
  });

  /// **Test ID**: TC-LERC-008F
  /// **Objective**: Verify that PDF form is correct for profession question.
  /// **Preconditions**: None.
  /// **Test Steps**:
  ///   1. Select all professions to mark them as checked.
  ///   2. Complete the process and tap 'Export Report' button.
  ///   3. Verify that PDF form is correctly filled in.
  /// **Automated**: Yes
  test(
      'TC-LERC-008F - Verify that PDF form is correct for profession question.',
      () {
    episodeOfCare.professionsInvolved =
        Profession.values.map((e) => e).toList();

    Map<String, String> matcher = {};
    episodeOfCare.professionsInvolved
        .map((e) => matcher.addAll({'profession_${e.index}': 'Yes'}))
        .toList();

    expect(episodeOfCare.toJsonForPDF(), matcher);
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);
  });

  /// **Test ID**: TC-LERC-008G
  /// **Objective**: Verify that PDF form is correct for rehabilitation services question.
  /// **Preconditions**: None.
  /// **Test Steps**:
  ///   1. Select all rehabilitation services to mark them as checked.
  ///   2. Complete the process and tap 'Export Report' button.
  ///   3. Verify that PDF form is correctly filled in.
  /// **Automated**: Yes
  test(
      'TC-LERC-008G - Verify that PDF form is correct for rehabilitation services question.',
      () {
    episodeOfCare.rehabilitationServices =
        RehabilitationServices.values.map((e) => e).toList();

    Map<String, String> matcher = {};
    episodeOfCare.rehabilitationServices
        .map((e) => matcher.addAll({'rehab_service_${e.index}': 'Yes'}))
        .toList();

    expect(episodeOfCare.toJsonForPDF(), matcher);
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);
  });

  /// **Test ID**: TC-LERC-008H
  /// **Objective**: Verify that PDF form is correct for compression therapies question.
  /// **Preconditions**: None.
  /// **Test Steps**:
  ///   1. Select all compression therapies to mark them as checked.
  ///   2. Complete the process and tap 'Export Report' button.
  ///   3. Verify that PDF form is correctly filled in.
  /// **Automated**: Yes
  test(
      'TC-LERC-008H - Verify that PDF form is correct for compression therapies question.',
      () {
    episodeOfCare.compressionTherapies =
        CompressionTherapy.values.map((e) => e).toList();

    Map<String, String> matcher = {};
    episodeOfCare.compressionTherapies
        .map((e) => matcher.addAll({'ct_${e.index}': 'Yes'}))
        .toList();

    expect(episodeOfCare.toJsonForPDF(), matcher);
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    episodeOfCare.ctOther = 'ct other text response';
    matcher.addAll({'ct_4_text': 'ct other text response'});
    expect(episodeOfCare.toJsonForPDF(), matcher);
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);
  });

  /// **Test ID**: TC-LERC-008I
  /// **Objective**: Verify that PDF form is correct for prosthesis question.
  /// **Preconditions**: None.
  /// **Test Steps**:
  ///   1. Select one of options for prosthesis question.
  ///   2. Complete the process and tap 'Export Report' button.
  ///   3. Verify that PDF form is correctly filled in.
  ///   4. Repeat the process for all other options.
  /// **Automated**: Yes
  test(
      'TC-LERC-008I - Verify that PDF form is correct for prosthesis question.',
      () {
    // Select 'Prosthesis'
    episodeOfCare.prostheticIntervention = ProstheticIntervention.prosthesis;
    expect(episodeOfCare.toJsonForPDF(),
        {'pro_interventions': ProstheticIntervention.prosthesis.displayName});
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'Socket replacement'
    episodeOfCare.prostheticIntervention =
        ProstheticIntervention.socketReplacement;
    expect(episodeOfCare.toJsonForPDF(), {
      'pro_interventions': ProstheticIntervention.socketReplacement.displayName
    });
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);

    // Select 'Repair/adjustments'
    episodeOfCare.prostheticIntervention =
        ProstheticIntervention.repairAdjustments;
    expect(episodeOfCare.toJsonForPDF(), {
      'pro_interventions': ProstheticIntervention.repairAdjustments.displayName
    });
    pdf.form.importData(
        utf8.encode(jsonEncode(episodeOfCare.toJsonForPDF())), DataFormat.json);
  });
  // });
}
