import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biot/constants/enum.dart';
import 'package:biot/model/outcome_measures/eq_5d_5l.dart';
import 'package:biot/model/question_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biot/app/app.locator.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../helpers/test_helpers.dart';

void main() {
  late Eq5d om;
  late QuestionCollection collection;
  late PdfDocument pdf;
  group('EQ-5D-5L Tests -', () {
    setUp(() async{
      registerServices();
      om = Eq5d(id: 'eq5d_5l', data: {
        'name': 'Outcome Measure',
        'shortName': 'OM',
        'domainType': 'comfort',
        'estimatedTime': '0',
        'isAssistantNeeded': 'false'
      });
      var rawQuestions = await File(
          '${Directory.current.path}/test/test_resources/eq5d_5l_questions.json').readAsString();
      collection = QuestionCollection.fromJson(jsonDecode(rawQuestions));
      om.questionCollection = collection;
      Uint8List data = await File(
          '${Directory.current.path}/test/test_resources/eq5d_5l_en.pdf').readAsBytes();
      pdf = PdfDocument(inputBytes: data);
    });
    tearDown(() => locator.reset());


    test('Test option 1 selection', () async{
      for(var question in collection.questions){
        if(question.type == QuestionType.radial){
          question.value = 0;
        }else{
          question.value = 55;
        }
      }
      expect(om.exportResponses('en'), {"eq5d_5l_1_0":"Yes","eq5d_5l_2_0":"Yes", "eq5d_5l_3_0":"Yes", "eq5d_5l_4_0":"Yes", "eq5d_5l_5_0":"Yes", "eq5d_5l_6":"55", "score1":"11111"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });

    test('Test option 2 selection', () async{
      for(var question in collection.questions){
        if(question.type == QuestionType.radial){
          question.value = 1;
        }else{
          question.value = 65;
        }
      }
      expect(om.exportResponses('en'), {"eq5d_5l_1_1":"Yes","eq5d_5l_2_1":"Yes", "eq5d_5l_3_1":"Yes", "eq5d_5l_4_1":"Yes", "eq5d_5l_5_1":"Yes", "eq5d_5l_6":"65", "score1":"22222"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });

    test('Test option 3 selection', () async{
      for(var question in collection.questions){
        if(question.type == QuestionType.radial){
          question.value = 2;
        }else{
          question.value = 65;
        }
      }
      expect(om.exportResponses('en'), {"eq5d_5l_1_2":"Yes","eq5d_5l_2_2":"Yes", "eq5d_5l_3_2":"Yes", "eq5d_5l_4_2":"Yes", "eq5d_5l_5_2":"Yes", "eq5d_5l_6":"65", "score1":"33333"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });

    test('Test option 4 selection', () async{
      for(var question in collection.questions){
        if(question.type == QuestionType.radial){
          question.value = 3;
        }else{
          question.value = 65;
        }
      }
      expect(om.exportResponses('en'), {"eq5d_5l_1_3":"Yes","eq5d_5l_2_3":"Yes", "eq5d_5l_3_3":"Yes", "eq5d_5l_4_3":"Yes", "eq5d_5l_5_3":"Yes", "eq5d_5l_6":"65", "score1":"44444"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });

    test('Test option 5 selection', () async{
      for(var question in collection.questions){
        if(question.type == QuestionType.radial){
          question.value = 4;
        }else{
          question.value = 65;
        }
      }
      expect(om.exportResponses('en'), {"eq5d_5l_1_4":"Yes","eq5d_5l_2_4":"Yes", "eq5d_5l_3_4":"Yes", "eq5d_5l_4_4":"Yes", "eq5d_5l_5_4":"Yes", "eq5d_5l_6":"65", "score1":"55555"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });

    test('Test no input', () async{
      expect(om.exportResponses('en'), {"score1":"999"});

      pdf.form.importData(
          utf8.encode(jsonEncode(om.exportResponses('en'))),
          DataFormat.json);
    });
  });
}
