import 'dart:convert';

import 'package:biot/constants/enum.dart';
import '../../constants/app_strings.dart';
import 'outcome_measure.dart';

class Eq5d extends OutcomeMeasure {
  double? _healthScore;

  double get healthScore => _healthScore ?? double.parse(totalScore['score2']);
  late String rawData;

  @override
  Map<String, dynamic> get totalScore {
    num? healthScore = questionCollection.getQuestionById('eq5d_5l_6')?.value;
    var result = _assembleHealthState();
    if (healthScore != null) {
      result.addAll({'score2': healthScore.toStringAsFixed(0)});
    } else {
      result.addAll({'score2': CompletionStatus.incomplete.code.toString()});
    }
    return result;
  }

  Eq5d({required super.id, super.data});

  factory Eq5d.fromJson(Map<String, dynamic> data) {
    Eq5d eq5d = Eq5d(id: 'eq5d_5l');
    eq5d.populateWithJson(data);
    return eq5d;
  }

  factory Eq5d.fromTemplateJson(Map<String, dynamic> data) {
    return Eq5d(id: data['id'], data: data);
  }

  @override
  void populateWithJson(Map<String, dynamic> json) {
    _healthScore = json['${id}_health_score'].toDouble();
    rawData = json['${id}_raw_data'];
    index = json['${id}_order'];
    creationTime = DateTime.parse(json['_creationTime']);
    sessionId = json['_referencers']?[id]['referrer']['id'];
    rawValue = _healthScore!;
    outcomeMeasureCreatedTimeString = json['${id}_created_time'];
    isPopulated = true;
  }

  @override
  Map<String, dynamic> toJson(ownerOrganizationId, patient, index) {
    List<Map<String, dynamic>> rawData = questionCollection.toJson();
    rawData.add(exportResponses('en'));
    Map<String, dynamic> body = {
      "_name": "${patient.initial}_${id}_$currentTime",
      "_templateId": ksEq5dTemplateId,
      "_ownerOrganization": {"id": ownerOrganizationId},
      "${id}_health_score": healthScore,
      "${id}_patient": {"id": patient.entityId},
      "${id}_order": index,
      "${id}_created_time": outcomeMeasureCreatedTimeString,
      "${id}_raw_data": json.encode(rawData),
      "${id}_time_to_complete": timeToComplete
    };
    print('id: $body');
    return body;
  }

  @override
  Map<String, dynamic> exportResponses(String locale) {
    Map<String, dynamic> responses = {};
    for (var element in questionCollection.questions) {
      if (element.exportResponse != null) {
        responses.addAll(element.exportResponse!);
      }
    }
    responses.addAll(_assembleHealthState());
    return responses;
  }

  Map<String, String> _assembleHealthState() {
    String healthState =
        questionCollection.getQuestionsForScoreGroup(0).fold('', (p, e) {
      return e.value == null || p == CompletionStatus.incomplete.code.toString()
          ? p = CompletionStatus.incomplete.code.toString()
          : p + (e.value + 1).toString();
    });
    return {'score1': healthState};
  }
}
