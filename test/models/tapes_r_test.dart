import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biot/model/outcome_measures/tapes_r.dart';
import 'package:biot/model/question.dart';
import 'package:biot/model/question_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biot/app/app.locator.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../helpers/test_helpers.dart';

void main() {
  late TapesR om;
  late QuestionCollection collection;
  late PdfDocument pdf;
  group('Tapes-R Tests -', () {
    setUp(() async {
      registerServices();
      om = TapesR(id: 'tapes_r', data: {
        'name': 'Outcome Measure',
        'shortName': 'OM',
        'domainType': 'comfort',
        'estimatedTime': '0',
        'isAssistantNeeded': 'false'
      });
      var rawQuestions = await File(
              '${Directory.current.path}/test/test_resources/tapes_r_questions.json')
          .readAsString();

      collection =
          QuestionCollection.fromJson(jsonDecode(rawQuestions));
      om.questionCollection = collection;
      Uint8List data = await File(
              '${Directory.current.path}/test/test_resources/tapes_r_en.pdf')
          .readAsBytes();
      pdf = PdfDocument(inputBytes: data);
    });
    tearDown(() => locator.reset());

    test('Test no input', () async {
      expect(om.exportResponses('en'), {
        "score1": "999",
        "score2": "999",
        "score3": "999",
        "tapes_r_34": "999"
      });

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
    });

    group('User input for Psychosocial Adjustment(group 0)', () {
      test('Test input for option 1', () {
        List<Question> questions =
            om.questionCollection.getQuestionsForGroup(0);
        for (var q in questions) {
          q.value = 0;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_1_0": "Yes",
          "tapes_r_2_0": "Yes",
          "tapes_r_3_0": "Yes",
          "tapes_r_4_0": "Yes",
          "tapes_r_5_0": "Yes",
          "tapes_r_6_0": "Yes",
          "tapes_r_7_0": "Yes",
          "tapes_r_8_0": "Yes",
          "tapes_r_9_0": "Yes",
          "tapes_r_10_0": "Yes",
          "tapes_r_11_0": "Yes",
          "tapes_r_12_0": "Yes",
          "tapes_r_13_0": "Yes",
          "tapes_r_14_0": "Yes",
          "tapes_r_15_0": "Yes",
          "score1": "2.0",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 2', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForGroup(0);
        for (var q in questions) {
          q.value = 1;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_1_1": "Yes",
          "tapes_r_2_1": "Yes",
          "tapes_r_3_1": "Yes",
          "tapes_r_4_1": "Yes",
          "tapes_r_5_1": "Yes",
          "tapes_r_6_1": "Yes",
          "tapes_r_7_1": "Yes",
          "tapes_r_8_1": "Yes",
          "tapes_r_9_1": "Yes",
          "tapes_r_10_1": "Yes",
          "tapes_r_11_1": "Yes",
          "tapes_r_12_1": "Yes",
          "tapes_r_13_1": "Yes",
          "tapes_r_14_1": "Yes",
          "tapes_r_15_1": "Yes",
          "score1": "2.3",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 3', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForGroup(0);
        for (var q in questions) {
          q.value = 2;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_1_2": "Yes",
          "tapes_r_2_2": "Yes",
          "tapes_r_3_2": "Yes",
          "tapes_r_4_2": "Yes",
          "tapes_r_5_2": "Yes",
          "tapes_r_6_2": "Yes",
          "tapes_r_7_2": "Yes",
          "tapes_r_8_2": "Yes",
          "tapes_r_9_2": "Yes",
          "tapes_r_10_2": "Yes",
          "tapes_r_11_2": "Yes",
          "tapes_r_12_2": "Yes",
          "tapes_r_13_2": "Yes",
          "tapes_r_14_2": "Yes",
          "tapes_r_15_2": "Yes",
          "score1": "2.7",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 4', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForGroup(0);
        for (var q in questions) {
          q.value = 3;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_1_3": "Yes",
          "tapes_r_2_3": "Yes",
          "tapes_r_3_3": "Yes",
          "tapes_r_4_3": "Yes",
          "tapes_r_5_3": "Yes",
          "tapes_r_6_3": "Yes",
          "tapes_r_7_3": "Yes",
          "tapes_r_8_3": "Yes",
          "tapes_r_9_3": "Yes",
          "tapes_r_10_3": "Yes",
          "tapes_r_11_3": "Yes",
          "tapes_r_12_3": "Yes",
          "tapes_r_13_3": "Yes",
          "tapes_r_14_3": "Yes",
          "tapes_r_15_3": "Yes",
          "score1": "3.0",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 5(Not applicable)', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForGroup(0);
        for (var q in questions) {
          q.value = 4;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_1_4": "Yes",
          "tapes_r_2_4": "Yes",
          "tapes_r_3_4": "Yes",
          "tapes_r_4_4": "Yes",
          "tapes_r_5_4": "Yes",
          "tapes_r_6_4": "Yes",
          "tapes_r_7_4": "Yes",
          "tapes_r_8_4": "Yes",
          "tapes_r_9_4": "Yes",
          "tapes_r_10_4": "Yes",
          "tapes_r_11_4": "Yes",
          "tapes_r_12_4": "Yes",
          "tapes_r_13_4": "Yes",
          "tapes_r_14_4": "Yes",
          "tapes_r_15_4": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
    });

    group('User input for Activity Restriction(group 1)', () {
      test('Test input for option 1', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForGroup(1);
        for (var q in questions) {
          q.value = 0;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_16_0": "Yes",
          "tapes_r_17_0": "Yes",
          "tapes_r_18_0": "Yes",
          "tapes_r_19_0": "Yes",
          "tapes_r_20_0": "Yes",
          "tapes_r_21_0": "Yes",
          "tapes_r_22_0": "Yes",
          "tapes_r_23_0": "Yes",
          "tapes_r_24_0": "Yes",
          "tapes_r_25_0": "Yes",
          "score1": "999",
          "score2": "2.0",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 2', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForGroup(1);
        for (var q in questions) {
          q.value = 1;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_16_1": "Yes",
          "tapes_r_17_1": "Yes",
          "tapes_r_18_1": "Yes",
          "tapes_r_19_1": "Yes",
          "tapes_r_20_1": "Yes",
          "tapes_r_21_1": "Yes",
          "tapes_r_22_1": "Yes",
          "tapes_r_23_1": "Yes",
          "tapes_r_24_1": "Yes",
          "tapes_r_25_1": "Yes",
          "score1": "999",
          "score2": "1.0",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 3', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForGroup(1);
        for (var q in questions) {
          q.value = 2;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_16_2": "Yes",
          "tapes_r_17_2": "Yes",
          "tapes_r_18_2": "Yes",
          "tapes_r_19_2": "Yes",
          "tapes_r_20_2": "Yes",
          "tapes_r_21_2": "Yes",
          "tapes_r_22_2": "Yes",
          "tapes_r_23_2": "Yes",
          "tapes_r_24_2": "Yes",
          "tapes_r_25_2": "Yes",
          "score1": "999",
          "score2": "0.0",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 4 for Question 25', () {
        QuestionWithRadialResponse question25 =
        om.questionCollection.getQuestionById('tapes_r_25')! as QuestionWithRadialResponse;
        question25.value = 3;
        expect(om.exportResponses('en'), {
          "tapes_r_25_3": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
    });

    group('User input for Satisfaction(group 2)', () {
      test('Test input for option 1', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForScoreGroup(3);
        for (var q in questions) {
          q.value = 0;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_26_0": "Yes",
          "tapes_r_27_0": "Yes",
          "tapes_r_28_0": "Yes",
          "tapes_r_29_0": "Yes",
          "tapes_r_30_0": "Yes",
          "tapes_r_31_0": "Yes",
          "tapes_r_32_0": "Yes",
          "tapes_r_33_0": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "1.0",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 2', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForScoreGroup(3);
        for (var q in questions) {
          q.value = 1;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_26_1": "Yes",
          "tapes_r_27_1": "Yes",
          "tapes_r_28_1": "Yes",
          "tapes_r_29_1": "Yes",
          "tapes_r_30_1": "Yes",
          "tapes_r_31_1": "Yes",
          "tapes_r_32_1": "Yes",
          "tapes_r_33_1": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "2.0",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 3', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForScoreGroup(3);
        for (var q in questions) {
          q.value = 2;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_26_2": "Yes",
          "tapes_r_27_2": "Yes",
          "tapes_r_28_2": "Yes",
          "tapes_r_29_2": "Yes",
          "tapes_r_30_2": "Yes",
          "tapes_r_31_2": "Yes",
          "tapes_r_32_2": "Yes",
          "tapes_r_33_2": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "3.0",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input Satisfaction discrete scale', () {
        QuestionWithDiscreteScaleResponse question =
        om.questionCollection.getQuestionById('tapes_r_34') as QuestionWithDiscreteScaleResponse;
        question.value = 59;
        expect(om.exportResponses('en'), {
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "59"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
    });

    group('User input for General Questions(group 3)', () {
      test('Test input for option 1', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForGroup(3);
        for (var q in questions) {
          q.value = 0;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_35": "0",
          "tapes_r_36_0": "Yes",
          "tapes_r_37_0": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 2', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForGroup(3);
        for (var q in questions) {
          q.value = 1;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_35": "1",
          "tapes_r_36_1": "Yes",
          "tapes_r_37_1": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 3', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForGroup(3);
        for (var q in questions) {
          q.value = 2;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_35": "2",
          "tapes_r_36_2": "Yes",
          "tapes_r_37_2": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 4', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForGroup(3);
        for (var q in questions) {
          q.value = 3;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_35": "3",
          "tapes_r_36_3": "Yes",
          "tapes_r_37_3": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for option 5', () {
        List<Question> questions =
        om.questionCollection.getQuestionsForGroup(3);
        for (var q in questions) {
          q.value = 4;
        }
        expect(om.exportResponses('en'), {
          "tapes_r_35": "4",
          "tapes_r_36_4": "Yes",
          "tapes_r_37_4": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
    });

    group('User input for Stump Pain(group 4)', () {
      test('Test input for Question 38', () {
        QuestionWithRadialResponse question =
        om.questionCollection.getQuestionById("tapes_r_38") as QuestionWithRadialResponse;
        question.value = 0;
        expect(om.exportResponses('en'), {
          "tapes_r_38_0": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });
        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);

        question.value = 1;

        expect(om.exportResponses('en'), {
          "tapes_r_38_1": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });
        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for Question 39', () {
        QuestionWithDiscreteScaleCheckBoxResponse question =
        om.questionCollection.getQuestionById("tapes_r_39") as QuestionWithDiscreteScaleCheckBoxResponse;
        question.value = 12;
        expect(om.exportResponses('en'), {
          "tapes_r_39": "12",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);

        question.value = null;
        question.isChecked = true;
        expect(om.exportResponses('en'), {
          "tapes_r_39_tap": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for Question 40', () {
        Question question =
        om.questionCollection.getQuestionById("tapes_r_40")!;
        question.value = "45 seconds";
        expect(om.exportResponses('en'), {
          "tapes_r_40": "45 seconds",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for Question 41', () {
        QuestionWithRadialResponse question =
        om.questionCollection.getQuestionById("tapes_r_41") as QuestionWithRadialResponse;
        for(var i = 0; i < question.options.length; i++){
          question.value = i;
          expect(om.exportResponses('en'), {
            "tapes_r_41_$i": "Yes",
            "score1": "999",
            "score2": "999",
            "score3": "999",
            "tapes_r_34": "999"
          });
          pdf.form.importData(
              utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
        }

      });
      test('Test input for Question 42', () {
        QuestionWithRadialResponse question =
        om.questionCollection.getQuestionById("tapes_r_42") as QuestionWithRadialResponse;
        for(var i = 0; i < question.options.length; i++){
          question.value = i;
          expect(om.exportResponses('en'), {
            "tapes_r_42_$i": "Yes",
            "score1": "999",
            "score2": "999",
            "score3": "999",
            "tapes_r_34": "999"
          });
          pdf.form.importData(
              utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
        }

      });
    });

    group('User input for Phantom Pain(group 5)', () {
      test('Test input for Question 43', () {
        QuestionWithRadialResponse question =
        om.questionCollection.getQuestionById("tapes_r_43") as QuestionWithRadialResponse;
        question.value = 0;
        expect(om.exportResponses('en'), {
          "tapes_r_43_0": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });
        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);

        question.value = 1;

        expect(om.exportResponses('en'), {
          "tapes_r_43_1": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });
        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for Question 44', () {
        QuestionWithDiscreteScaleCheckBoxResponse question =
        om.questionCollection.getQuestionById("tapes_r_44") as QuestionWithDiscreteScaleCheckBoxResponse;
        question.value = 12;
        expect(om.exportResponses('en'), {
          "tapes_r_44": "12",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);

        question.value = null;
        question.isChecked = true;
        expect(om.exportResponses('en'), {
          "tapes_r_44_tap": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for Question 45', () {
        Question question =
        om.questionCollection.getQuestionById("tapes_r_45")!;
        question.value = "45 seconds";
        expect(om.exportResponses('en'), {
          "tapes_r_45": "45 seconds",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for Question 46', () {
        QuestionWithRadialResponse question =
        om.questionCollection.getQuestionById("tapes_r_46") as QuestionWithRadialResponse;
        for(var i = 0; i < question.options.length; i++){
          question.value = i;
          expect(om.exportResponses('en'), {
            "tapes_r_46_$i": "Yes",
            "score1": "999",
            "score2": "999",
            "score3": "999",
            "tapes_r_34": "999"
          });
          pdf.form.importData(
              utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
        }

      });
      test('Test input for Question 47', () {
        QuestionWithRadialResponse question =
        om.questionCollection.getQuestionById("tapes_r_47") as QuestionWithRadialResponse;
        for(var i = 0; i < question.options.length; i++){
          question.value = i;
          expect(om.exportResponses('en'), {
            "tapes_r_47_$i": "Yes",
            "score1": "999",
            "score2": "999",
            "score3": "999",
            "tapes_r_34": "999"
          });
          pdf.form.importData(
              utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
        }

      });
    });

    group('User input for Pain from Other Problem(group 6)', () {
      test('Test input for Question 48', () {
        QuestionWithRadialResponse question =
        om.questionCollection.getQuestionById("tapes_r_48") as QuestionWithRadialResponse;
        question.value = 0;
        expect(om.exportResponses('en'), {
          "tapes_r_48_0": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });
        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);

        question.value = 1;

        expect(om.exportResponses('en'), {
          "tapes_r_48_1": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });
        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for Question 49', () {
        Question question =
        om.questionCollection.getQuestionById("tapes_r_49")!;
        question.value = "Other Problem";
        expect(om.exportResponses('en'), {
          "tapes_r_49": "Other Problem",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for Question 50', () {
        QuestionWithDiscreteScaleCheckBoxResponse question =
        om.questionCollection.getQuestionById("tapes_r_50") as QuestionWithDiscreteScaleCheckBoxResponse;
        question.value = 12;
        expect(om.exportResponses('en'), {
          "tapes_r_50": "12",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);

        question.value = null;
        question.isChecked = true;
        expect(om.exportResponses('en'), {
          "tapes_r_50_tap": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });

      test('Test input for Question 51', () {
        Question question =
        om.questionCollection.getQuestionById("tapes_r_51")!;
        question.value = "45 seconds";
        expect(om.exportResponses('en'), {
          "tapes_r_51": "45 seconds",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
      test('Test input for Question 52', () {
        QuestionWithRadialResponse question =
        om.questionCollection.getQuestionById("tapes_r_52") as QuestionWithRadialResponse;
        for(var i = 0; i < question.options.length; i++){
          question.value = i;
          expect(om.exportResponses('en'), {
            "tapes_r_52_$i": "Yes",
            "score1": "999",
            "score2": "999",
            "score3": "999",
            "tapes_r_34": "999"
          });
          pdf.form.importData(
              utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
        }

      });
      test('Test input for Question 53', () {
        QuestionWithRadialResponse question =
        om.questionCollection.getQuestionById("tapes_r_53") as QuestionWithRadialResponse;
        for(var i = 0; i < question.options.length; i++){
          question.value = i;
          expect(om.exportResponses('en'), {
            "tapes_r_53_$i": "Yes",
            "score1": "999",
            "score2": "999",
            "score3": "999",
            "tapes_r_34": "999"
          });
          pdf.form.importData(
              utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
        }

      });
      test('Test input for Question 54', () {
        QuestionWithTextCheckBoxResponse question =
        om.questionCollection.getQuestionById("tapes_r_54") as QuestionWithTextCheckBoxResponse;
        question.value = "Other pain problem";
        expect(om.exportResponses('en'), {
          "tapes_r_54": "Other pain problem",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);

        question.value = null;
        question.isChecked = true;
        expect(om.exportResponses('en'), {
          "tapes_r_54_tap": "Yes",
          "score1": "999",
          "score2": "999",
          "score3": "999",
          "tapes_r_34": "999"
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(om.exportResponses('en'))), DataFormat.json);
      });
    });
  });
}
