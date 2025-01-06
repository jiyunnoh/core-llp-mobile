import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biot/model/outcome_measures/amp.dart';
import 'package:biot/model/question.dart';
import 'package:biot/model/question_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biot/app/app.locator.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../helpers/test_helpers.dart';

void main() {
  late Amp om;
  late QuestionCollection collection;
  late PdfDocument pdf;
  group('AMP Tests -', () {
    setUp(() async {
      registerServices();
      om = Amp(id: 'amp', data: {
        'name': 'Outcome Measure',
        'shortName': 'OM',
        'domainType': 'comfort',
        'estimatedTime': '0',
        'isAssistantNeeded': 'false'
      });
      var rawQuestions = await File(
              '${Directory.current.path}/test/test_resources/amp_questions.json')
          .readAsString();

      collection = QuestionCollection.fromJson(jsonDecode(rawQuestions));
      om.questionCollection = collection;
      Uint8List data =
          await File('${Directory.current.path}/test/test_resources/amp_en.pdf')
              .readAsBytes();
      pdf = PdfDocument(inputBytes: data);
    });
    tearDown(() => locator.reset());

    test('Test no input', () async {
      expect(om.exportResponses('en'), {"score": "999"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
    });

    test('Test option 1 selection', () async {
      for (var question in collection.questions) {
        question.value = 0;
      }
      expect(om.exportResponses('en'), {
        "amp_1": "0",
        "amp_2": "0",
        "amp_3": "0",
        "amp_4": "0",
        "amp_5": "0",
        "amp_6": "0",
        "amp_7": "0",
        "amp_8a": "0",
        "amp_8b": "0",
        "amp_9": "0",
        "amp_10": "0",
        "amp_11": "0",
        "amp_12": "0",
        "amp_13": "0",
        "amp_14": "0",
        "amp_15a": "0",
        "amp_15b": "0",
        "amp_15c": "0",
        "amp_15d": "0",
        "amp_16": "0",
        "amp_17": "0",
        "amp_18": "0",
        "amp_19": "0",
        "amp_20a": "0",
        "amp_20b": "0",
        "amp_21": "0",
        "AMPPRO": "Yes",
        "score": "0"
      });

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
    });

    test('Test option 2 selection', () async {
      for (var question in collection.questions) {
        question.value = 1;
      }
      expect(om.exportResponses('en'), {
        "amp_1": "1",
        "amp_2": "1",
        "amp_3": "1",
        "amp_4": "1",
        "amp_5": "1",
        "amp_6": "1",
        "amp_7": "1",
        "amp_8a": "1",
        "amp_8b": "1",
        "amp_9": "1",
        "amp_10": "1",
        "amp_11": "1",
        "amp_12": "1",
        "amp_13": "1",
        "amp_14": "1",
        "amp_15a": "1",
        "amp_15b": "1",
        "amp_15c": "1",
        "amp_15d": "1",
        "amp_16": "1",
        "amp_17": "1",
        "amp_18": "1",
        "amp_19": "1",
        "amp_20a": "1",
        "amp_20b": "1",
        "amp_21": "1",
        "AMPPRO": "Yes",
        "score": "26"
      });

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
    });

    group('Test option 3 selection', () {
      test('Test option 3 selection for Question 2', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_2") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_2": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 3', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_3") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_3": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 4', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_4") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_4": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 5', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_5") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_5": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 6', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_6") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_6": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 7', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_7") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_7": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 8a', () async {
        QuestionWithRadialCheckBoxResponse question = om.questionCollection
            .getQuestionById("amp_8a") as QuestionWithRadialCheckBoxResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_8a": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 8b', () async {
        QuestionWithRadialCheckBoxResponse question = om.questionCollection
            .getQuestionById("amp_8b") as QuestionWithRadialCheckBoxResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_8b": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 9', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_9") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_9": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 10', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_10") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_10": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 12', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_12") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_12": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 13', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_13") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_13": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 17', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_17") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_17": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 18', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_18") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_18": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 19', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_19") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_19": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 20a', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_20a") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_20a": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 20b', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_20b") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_20b": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test option 3 selection for Question 21', () async {
        QuestionWithRadialResponse question = om.questionCollection
            .getQuestionById("amp_21") as QuestionWithRadialResponse;
        question.value = 2;
        expect(om.exportResponses('en'), {"amp_21": "2", "score": "999"});

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
    });

    test('Test option 4 selection for Question 21', () async {
      QuestionWithRadialResponse question = om.questionCollection
          .getQuestionById("amp_21") as QuestionWithRadialResponse;
      question.value = 3;
      expect(om.exportResponses('en'), {"amp_21": "3", "score": "999"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
    });

    test('Test option 5 selection for Question 21', () async {
      QuestionWithRadialResponse question = om.questionCollection
          .getQuestionById("amp_21") as QuestionWithRadialResponse;
      question.value = 4;
      expect(om.exportResponses('en'), {"amp_21": "4", "score": "999"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
    });

    test('Test option 6 selection for Question 21', () async {
      QuestionWithRadialResponse question = om.questionCollection
          .getQuestionById("amp_21") as QuestionWithRadialResponse;
      question.value = 5;
      expect(om.exportResponses('en'), {"amp_21": "5", "score": "999"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
    });

    test('Test checkbox selection for Question 8a', () async {
      QuestionWithRadialCheckBoxResponse question = om.questionCollection
          .getQuestionById("amp_8a") as QuestionWithRadialCheckBoxResponse;
      question.isChecked = true;
      expect(om.exportResponses('en'), {"amp_8a": "N/A", "score": "999"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
    });

    test('Test checkbox selection for Question 8b', () async {
      QuestionWithRadialCheckBoxResponse question = om.questionCollection
          .getQuestionById("amp_8b") as QuestionWithRadialCheckBoxResponse;
      question.isChecked = true;
      expect(om.exportResponses('en'), {"amp_8b": "N/A", "score": "999"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
    });

    test('Test AMPnoPRO is checked', () async {
      for (int i = 0; i < collection.questions.length; i++) {
        if (i == 7) {
          collection.questions[i].value = null;
        } else {
          collection.questions[i].value = 1;
        }
      }
      QuestionWithRadialCheckBoxResponse question8a = om.questionCollection
          .getQuestionById("amp_8a") as QuestionWithRadialCheckBoxResponse;
      question8a.isChecked = true;
      expect(om.exportResponses('en'), {
        "amp_1": "1",
        "amp_2": "1",
        "amp_3": "1",
        "amp_4": "1",
        "amp_5": "1",
        "amp_6": "1",
        "amp_7": "1",
        "amp_8a": "N/A",
        "amp_8b": "1",
        "amp_9": "1",
        "amp_10": "1",
        "amp_11": "1",
        "amp_12": "1",
        "amp_13": "1",
        "amp_14": "1",
        "amp_15a": "1",
        "amp_15b": "1",
        "amp_15c": "1",
        "amp_15d": "1",
        "amp_16": "1",
        "amp_17": "1",
        "amp_18": "1",
        "amp_19": "1",
        "amp_20a": "1",
        "amp_20b": "1",
        "amp_21": "1",
        "AMPnoPRO": "Yes",
        "score": "24"
      });

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
    });
  });
}
