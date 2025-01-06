import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biot/model/outcome_measures/two_minute_walk_test.dart';
import 'package:biot/model/question_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biot/app/app.locator.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../helpers/test_helpers.dart';

void main() {
  late Tminwt om;
  late QuestionCollection collection;
  late PdfDocument pdf;
  group('Two Minute Walk Test -', () {
    setUp(() async{
      registerServices();
      om = Tminwt(id: 'tminwt', data: {
        'name': 'Outcome Measure',
        'shortName': 'OM',
        'domainType': 'comfort',
        'estimatedTime': '0',
        'isAssistantNeeded': 'false'
      });
      var rawQuestions = await File(
          '${Directory.current.path}/test/test_resources/tminwt_questions.json').readAsString();
      collection = QuestionCollection.fromJson(jsonDecode(rawQuestions));
      om.questionCollection = collection;
      Uint8List data = await File(
          '${Directory.current.path}/test/test_resources/tminwt_en.pdf').readAsBytes();
      pdf = PdfDocument(inputBytes: data);
    });
    tearDown(() => locator.reset());

    test('Test exportResponses, totalScore and pdf', () {

      collection.questions[0].value = 32.400;
      collection.questions[1].value = "Cane";

      expect(om.exportResponses('en'), {"tminwt_1":"32.4","tminwt_2": "Cane"});

      expect(om.totalScore, {"distance":"32.40"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });

    test('Test no input', () {

      expect(om.exportResponses('en'), {"tminwt_2": "noneReported"});
      expect(om.totalScore, {"distance":"999"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });
  });
}
