import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biot/model/outcome_measures/patient_specific_functional_scale.dart';
import 'package:biot/model/question.dart';
import 'package:biot/model/question_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biot/app/app.locator.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../helpers/test_helpers.dart';

void main() {
  late Psfs om;
  late QuestionCollection collection;
  late PdfDocument pdf;
  group('Patient Specific Functional Scale Test', () {
    setUp(() async {
      registerServices();
      om = Psfs(id: 'psfs', data: {
        'name': 'Outcome Measure',
        'shortName': 'OM',
        'domainType': 'comfort',
        'estimatedTime': '0',
        'isAssistantNeeded': 'false'
      });
      var rawQuestions = await File(
              '${Directory.current.path}/test/test_resources/psfs_questions.json')
          .readAsString();
      collection = QuestionCollection.fromJson(jsonDecode(rawQuestions));
      om.questionCollection = collection;
      Uint8List data = await File(
              '${Directory.current.path}/test/test_resources/psfs_en.pdf')
          .readAsBytes();
      pdf = PdfDocument(inputBytes: data);
    });
    tearDown(() => locator.reset());

    group('Invalid activity entry test', () {
      test('Test export for no activity and no score', () {
        expect(om.exportResponses('en'), {"score": "999"});
        expect(om.totalScore, {"score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });

      test('Test export for no activity, only score', () {
        (collection.questions[0] as QuestionWithDiscreteScaleTextResponse)
            .value = 3;

        expect(om.exportResponses('en'), {"score": "999"});

        expect(om.totalScore, {"score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });

      test('Test export for valid activity but no score', () {
        (collection.questions[0] as QuestionWithDiscreteScaleTextResponse)
            .textResponse = "Walking";

        expect(om.exportResponses('en'), {"score": "999"});

        expect(om.totalScore, {"score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
    });

    group('Valid activity entry test', () {
      test('Test export for one valid entry', () {
        (collection.questions[0] as QuestionWithDiscreteScaleTextResponse)
            .textResponse = "Walking";
        (collection.questions[0] as QuestionWithDiscreteScaleTextResponse)
            .value = 4;

        expect(om.exportResponses('en'), {"psfs_1_text": "Walking", "psfs_1": "4", "score": "4.0"});

        expect(om.totalScore, {"score": "4.0"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });

      test('Test export for all entries', () {
        (collection.questions[0] as QuestionWithDiscreteScaleTextResponse)
            .textResponse = "Walking";
        (collection.questions[0] as QuestionWithDiscreteScaleTextResponse)
            .value = 4;
        (collection.questions[1] as QuestionWithDiscreteScaleTextResponse)
            .textResponse = "Running";
        (collection.questions[1] as QuestionWithDiscreteScaleTextResponse)
            .value = 10;
        (collection.questions[2] as QuestionWithDiscreteScaleTextResponse)
            .textResponse = "Jumping";
        (collection.questions[2] as QuestionWithDiscreteScaleTextResponse)
            .value = 6;

        expect(om.exportResponses('en'), {"psfs_1_text": "Walking", "psfs_1": "4", "psfs_2_text": "Running", "psfs_2": "10", "psfs_3_text": "Jumping", "psfs_3": "6", "score": "6.7"});

        expect(om.totalScore, {"score": "6.7"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
    });
  });
}
