import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biot/model/outcome_measures/prosthesis_evaluation_questionnaire.dart';
import 'package:biot/model/question.dart';
import 'package:biot/model/question_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biot/app/app.locator.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../helpers/test_helpers.dart';

void main() {
  late PeqRl om;
  late QuestionCollection collection;
  late PdfDocument pdf;
  group('PEQ Residual Limb Health -', () {
    setUp(() async{
      registerServices();
      om = PeqRl(id: 'peq_rl', data: {
        'name': 'Outcome Measure',
        'shortName': 'OM',
        'domainType': 'comfort',
        'estimatedTime': '0',
        'isAssistantNeeded': 'false'
      });
      var rawQuestions = await File(
          '${Directory.current.path}/test/test_resources/peq_rl_questions.json').readAsString();
      collection = QuestionCollection.fromJson(jsonDecode(rawQuestions));
      om.questionCollection = collection;
      Uint8List data = await File(
          '${Directory.current.path}/test/test_resources/peq_rl_en.pdf').readAsBytes();
      pdf = PdfDocument(inputBytes: data);
    });
    tearDown(() => locator.reset());

    test('Test vas for export to pdf', () {

      for(var q in om.questionCollection.questions){
        q.value = 48;
      }
      expect(om.exportResponses('en'), {
        "peq_rl_1": "48",
        "peq_rl_2": "48",
        "peq_rl_3": "48",
        "peq_rl_4": "48",
        "peq_rl_5": "48",
        "peq_rl_6": "48",
        "score": "48.0"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });

    test('Test vas and checkbox for export to pdf', () {

      for(var q in om.questionCollection.questions){
        if(q is QuestionWithVasResponse){
          q.value = 48;
        }else if(q is QuestionWithVasCheckboxResponse){
          q.isChecked = true;
        }

      }
      expect(om.exportResponses('en'), {
        "peq_rl_1": "48",
        "peq_rl_2": "48",
        "peq_rl_3": "48",
        "peq_rl_4_tap": "Yes",
        "peq_rl_4": "100",
        "peq_rl_5_tap": "Yes",
        "peq_rl_5": "100",
        "peq_rl_6_tap": "Yes",
        "peq_rl_6": "100",
        "score": "74.0"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });

    test('Test no input', () {

      expect(om.exportResponses('en'), {"score": "999"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });
  });
}
