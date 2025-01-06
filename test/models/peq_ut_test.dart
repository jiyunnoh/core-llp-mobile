import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biot/model/outcome_measures/prosthesis_evaluation_questionnaire.dart';
import 'package:biot/model/question_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biot/app/app.locator.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../helpers/test_helpers.dart';

void main() {
  late PeqUt om;
  late QuestionCollection collection;
  late PdfDocument pdf;
  group('PEQ Utility -', () {
    setUp(() async{
      registerServices();
      om = PeqUt(id: 'peq_ut', data: {
        'name': 'Outcome Measure',
        'shortName': 'OM',
        'domainType': 'comfort',
        'estimatedTime': '0',
        'isAssistantNeeded': 'false'
      });
      var rawQuestions = await File(
          '${Directory.current.path}/test/test_resources/peq_ut_questions.json').readAsString();
      collection = QuestionCollection.fromJson(jsonDecode(rawQuestions));
      om.questionCollection = collection;
      Uint8List data = await File(
          '${Directory.current.path}/test/test_resources/peq_ut_en.pdf').readAsBytes();
      pdf = PdfDocument(inputBytes: data);
    });
    tearDown(() => locator.reset());

    test('Some Code - Test vas for export to pdf', () {

      for(var q in om.questionCollection.questions){
        q.value = 67;
      }
      expect(om.exportResponses('en'), {
        "peq_ut_1": "67",
        "peq_ut_2": "67",
        "peq_ut_3": "67",
        "peq_ut_4": "67",
        "peq_ut_5": "67",
        "peq_ut_6": "67",
        "peq_ut_7": "67",
        "score": "67.0"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });

    test('Some Code - Test no input', () {

      expect(om.exportResponses('en'), {"score": "999"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });
  });
}
