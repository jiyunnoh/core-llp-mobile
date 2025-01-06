import 'dart:convert';

import 'package:biot/model/outcome_measures/outcome_measure.dart';

import '../../constants/app_strings.dart';
import '../../constants/enum.dart';
import '../question.dart';

class Psfs extends OutcomeMeasure {
  double? _score;
  double get score => _score ?? double.parse(totalScore['score']);
  late String rawData;

  @override
  Map<String, dynamic> get totalScore {
    String score;
    var totalValidAnswers = 0; //Both activity and its value must be provided.
    if (questionCollection.numOfAnsweredQuestions != 0) {
      double sum = questionCollection.questions.fold(0, (p, e) {
        QuestionWithDiscreteScaleTextResponse q =
            e as QuestionWithDiscreteScaleTextResponse;
        if (q.value != null && q.textResponse != '') {
          totalValidAnswers += 1;
          return p + q.value;
        } else {
          return p;
        }
      });
      if (totalValidAnswers == 0) {
        score = CompletionStatus.incomplete.code.toString();
      } else {
        score = (sum / totalValidAnswers).toStringAsFixed(1);
      }
    } else {
      score = CompletionStatus.incomplete.code.toString();
    }
    return {'score': score};
  }

  Psfs({required super.id, super.data});

  factory Psfs.fromJson(Map<String, dynamic> data) {
    Psfs psfs = Psfs(id: 'psfs');
    psfs.populateWithJson(data);
    return psfs;
  }

  factory Psfs.fromTemplateJson(Map<String, dynamic> data) {
    return Psfs(id: data['id'], data: data);
  }

  @override
  void populateWithJson(Map<String, dynamic> json) {
    _score = json['${id}_score'].toDouble();
    index = json['${id}_order'];
    creationTime = DateTime.parse(json['_creationTime']);
    patientId = json['${id}_patient']['id'];
    sessionId = json['_referencers']?[id]['referrer']['id'];
    rawData = json['${id}_raw_data'];
    rawValue = _score!;
    outcomeMeasureCreatedTimeString = json['${id}_created_time'];
    isPopulated = true;
  }

  @override
  Map<String, dynamic> toJson(ownerOrganizationId, patient, index) {
    List<Map<String, dynamic>> rawData = questionCollection.toJson();
    rawData.add(exportResponses('en'));
    Map<String, dynamic> body = {
      "_name": "${patient.initial}_${id}_$currentTime",
      "_templateId": ksPsfsTemplateId,
      "_ownerOrganization": {"id": ownerOrganizationId},
      "${id}_score": score,
      "${id}_raw_data": json.encode(rawData),
      "${id}_order": index,
      "${id}_patient": {"id": patient.entityId},
      "${id}_created_time": outcomeMeasureCreatedTimeString,
      "${id}_time_to_complete": timeToComplete
    };
    return body;
  }
}
