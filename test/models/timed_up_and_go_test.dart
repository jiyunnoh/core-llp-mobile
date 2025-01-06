import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biot/model/outcome_measures/timed_up_and_go.dart';
import 'package:biot/model/question_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biot/app/app.locator.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../helpers/test_helpers.dart';

void main() {
  late Tug om;
  late QuestionCollection collection;
  late PdfDocument pdf;
  group('Timed up and Go Tests -', () {
    setUp(() async{
      registerServices();
      om = Tug(id: 'tug', data: {
        'name': 'Outcome Measure',
        'shortName': 'OM',
        'domainType': 'comfort',
        'estimatedTime': '0',
        'isAssistantNeeded': 'false'
      });
      var rawQuestions = await File(
          '${Directory.current.path}/test/test_resources/tug_questions.json').readAsString();
      collection = QuestionCollection.fromJson(jsonDecode(rawQuestions));
      om.questionCollection = collection;
      Uint8List data = await File(
          '${Directory.current.path}/test/test_resources/tug_en.pdf').readAsBytes();
      pdf = PdfDocument(inputBytes: data);
    });
    tearDown(() => locator.reset());

    test('Test exportResponses, totalScore and pdf', () {

      collection.questions[0].value = const Duration(seconds: 10, milliseconds: 220);
      collection.questions[1].value = "Cane";

      expect(om.exportResponses('en'), {"tug_1_min":"0", "tug_1_sec":"10.22","tug_2": "Cane"});

      expect(om.totalScore, {"elapsedTime":"10.22"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });

    test('Test no input', () {

      expect(om.exportResponses('en'), {"tug_2": "noneReported"});
      expect(om.totalScore, {"elapsedTime":"999"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });
  });
}
