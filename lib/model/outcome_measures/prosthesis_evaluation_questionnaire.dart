import 'dart:convert';

import 'package:biot/constants/app_strings.dart';

import 'package:biot/model/patient.dart';
import 'package:biot/model/question.dart';

import '../../constants/enum.dart';
import 'outcome_measure.dart';

class PeqUt extends OutcomeMeasure {
  double? _score;
  double get score => _score ?? double.parse(totalScore['score']);
  late String rawData;

  @override
  Map<String, dynamic> get totalScore {
    String score;
    if (questionCollection.skippedQuestionsForScoreGroup(0) <
        (questionCollection.totalQuestions / 2).round()) {
      num sum = (questionCollection.questions.fold(0, (p, e) {
        return p + e.value;
      }));
      score = (sum / questionCollection.totalQuestions).toStringAsFixed(1);
    } else {
      return {'score': CompletionStatus.incomplete.code.toString()};
    }
    return {'score': score};
  }

  PeqUt({required super.id, super.data});

  @override
  void populateWithJson(Map<String, dynamic> json) {
    _score = json['${id}_score'].toDouble();
    rawData = json['${id}_raw_data'];
    index = json['${id}_order'];
    creationTime = DateTime.parse(json['_creationTime']);
    sessionId = json['_referencers']?[id]['referrer']['id'];
    rawValue = _score!;
    outcomeMeasureCreatedTimeString = json['${id}_created_time'];
    isPopulated = true;
  }

  @override
  Map<String, dynamic> toJson(
      String ownerOrganizationId, Patient patient, int index) {
    List<Map<String, dynamic>> rawData = questionCollection.toJson();
    rawData.add(exportResponses('en'));
    Map<String, dynamic> body = {
      "_name": "${patient.initial}_${id}_$currentTime",
      "_templateId": ksPeqUtTemplateId,
      "_ownerOrganization": {"id": ownerOrganizationId},
      "${id}_score": score,
      "${id}_patient": {"id": patient.entityId},
      "${id}_order": index,
      "${id}_created_time": outcomeMeasureCreatedTimeString,
      "${id}_raw_data": json.encode(rawData),
      "${id}_time_to_complete": timeToComplete
    };
    return body;
  }
}

class PeqRl extends OutcomeMeasure {
  double? _score;
  double get score => _score ?? double.parse(totalScore['score']);
  late String rawData;

  PeqRl({required super.id, super.data});

  @override
  Map<String, dynamic> get totalScore {
    String score;
    if (questionCollection.skippedQuestionsForScoreGroup(0) <
        (questionCollection.totalQuestions / 2).round()) {
      num sum = 0;
      for (var question in questionCollection.questions) {
        if (question.type == QuestionType.vas) {
          sum += question.value;
        } else {
          QuestionWithVasCheckboxResponse q =
              question as QuestionWithVasCheckboxResponse;
          sum += (q.isChecked ? 100 : q.value);
        }
      }
      score = (sum / questionCollection.totalQuestions).toStringAsFixed(1);
    } else {
      score = CompletionStatus.incomplete.code.toString();
    }
    return {'score': score};
  }

  @override
  void populateWithJson(Map<String, dynamic> json) {
    _score = json['${id}_score'].toDouble();
    rawData = json['${id}_raw_data'];
    index = json['${id}_order'];
    creationTime = DateTime.parse(json['_creationTime']);
    sessionId = json['_referencers']?[id]['referrer']['id'];
    rawValue = _score!;
    outcomeMeasureCreatedTimeString = json['${id}_created_time'];
    isPopulated = true;
  }

  @override
  Map<String, dynamic> toJson(
      String ownerOrganizationId, Patient patient, int index) {
    List<Map<String, dynamic>> rawData = questionCollection.toJson();
    rawData.add(exportResponses('en'));
    Map<String, dynamic> body = {
      "_name": "${patient.initial}_${id}_$currentTime",
      "_templateId": ksPeqRlTemplateId,
      "_ownerOrganization": {"id": ownerOrganizationId},
      "${id}_score": score,
      "${id}_patient": {"id": patient.entityId},
      "${id}_order": index,
      "${id}_created_time": outcomeMeasureCreatedTimeString,
      "${id}_raw_data": json.encode(rawData),
      "${id}_time_to_complete": timeToComplete
    };
    return body;
  }
}
