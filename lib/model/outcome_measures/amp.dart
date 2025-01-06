import 'dart:convert';

import 'package:biot/constants/enum.dart';
import 'package:biot/model/question.dart';

import '../../constants/app_strings.dart';
import 'outcome_measure.dart';

class Amp extends OutcomeMeasure {
  double? _score;

  double get score => _score ?? double.parse(totalScore['score']);
  late String rawData;

  @override
  Map<String, dynamic> get totalScore {
    String score;
    if (isComplete) {
      num sum = (questionCollection.questions.fold(0, (p, e) {
        if (e.value != null) {
          return p + e.value;
        } else {
          return p;
        }
      }));
      score = sum.toString();
    } else {
      return {'score': CompletionStatus.incomplete.code.toString()};
    }
    return {'score': score};
  }

  @override
  bool get isComplete {
    for (var i = 0; i < questionCollection.totalQuestions; i++) {
      if (questionCollection.questions[i].hasResponded) {
        if (i == 7 || i == 8) {
          if ((questionCollection.questions[i]
                  as QuestionWithRadialCheckBoxResponse)
              .isChecked) {
            questionCollection.questions[7].value = null;
            (questionCollection.questions[7]
                    as QuestionWithRadialCheckBoxResponse)
                .isChecked = true;

            questionCollection.questions[8].value = null;
            (questionCollection.questions[8]
                    as QuestionWithRadialCheckBoxResponse)
                .isChecked = true;
          }
        } else {
          continue;
        }
      } else {
        return false;
      }
    }
    return true;
  }

  Amp({required super.id, super.data});

  factory Amp.fromJson(Map<String, dynamic> data) {
    Amp amp = Amp(id: 'amp');
    amp.populateWithJson(data);
    return amp;
  }

  factory Amp.fromTemplateJson(Map<String, dynamic> data) {
    return Amp(id: data['id'], data: data);
  }

  @override
  void populateWithJson(Map<String, dynamic> json) {
    _score = json['${id}_score'].double();
    rawData = json['${id}_raw_data'];
    index = json['${id}_order'];
    creationTime = DateTime.parse(json['_creationTime']);
    sessionId = json['_referencers']?[id]['referrer']['id'];
    rawValue = _score!.toDouble();
    outcomeMeasureCreatedTimeString = json['${id}_created_time'];
    isPopulated = true;
  }

  @override
  Map<String, dynamic> toJson(ownerOrganizationId, patient, index) {
    List<Map<String, dynamic>> rawData = questionCollection.toJson();
    rawData.add(exportResponses('en'));
    Map<String, dynamic> body = {
      "_name": "${patient.initial}_${id}_$currentTime",
      "_templateId": ksAmpTemplateId,
      "_ownerOrganization": {"id": ownerOrganizationId},
      "${id}_score": score.toInt(),
      "${id}_patient": {"id": patient.entityId},
      "${id}_order": index,
      "${id}_created_time": outcomeMeasureCreatedTimeString,
      "${id}_raw_data": json.encode(rawData),
      "${id}_time_to_complete": timeToComplete
    };
    return body;
  }

  @override
  Map<String, dynamic> exportResponses(String locale) {
    Map<String, dynamic> responses = {};

    for (var element in questionCollection.questions) {
      if (element.exportResponse != null) {
        if (element.value == null) {
          responses.addAll({element.id: "N/A"});
        } else {
          responses.addAll({element.id: "${element.value}"});
        }
      }
    }

    if (totalScore['score'] != '999') {
      if ((questionCollection.questions[7]
                  as QuestionWithRadialCheckBoxResponse)
              .isChecked ||
          (questionCollection.questions[8]
                  as QuestionWithRadialCheckBoxResponse)
              .isChecked) {
        responses.addAll({"AMPnoPRO": "Yes"});
      } else {
        responses.addAll({"AMPPRO": "Yes"});
      }
    }

    responses.addAll(totalScore);
    return responses;
  }
}
