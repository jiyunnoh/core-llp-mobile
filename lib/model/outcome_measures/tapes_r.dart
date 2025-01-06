import 'dart:convert';

import 'package:biot/constants/enum.dart';

import '../../constants/app_strings.dart';
import 'outcome_measure.dart';

class TapesR extends OutcomeMeasure {
  double? _score;
  double get score => _score ?? double.parse(totalScore['tapes_r_34']);
  late String rawData;

  @override
  Map<String, dynamic> get totalScore {
    num psychosocial = CompletionStatus.incomplete.code;
    num activity = CompletionStatus.incomplete.code;
    num satisfaction = CompletionStatus.incomplete.code;
    num generalSatisfaction = CompletionStatus.incomplete.code;

    //Score for Psychosocial Adjustment (score group 0 and 1)
    num generalAdjSum =
        questionCollection.getQuestionsForScoreGroup(0).fold(0, (p, e) {
      return e.value == null || e.value == 4 ? p : p + e.value + 1;
    });

    num adjToLimitSum =
        questionCollection.getQuestionsForScoreGroup(1).fold(0, (p, e) {
      return e.value == null || e.value == 4 ? p : p + (4 - e.value);
    });

    // number of valid responses in first 15 questions.
    int numValidResponsesForScoreGroup0 = questionCollection
        .getQuestionsForScoreGroup(0)
        .where((e) => e.value != null && e.value != 4)
        .toList()
        .length;
    int numValidResponsesForScoreGroup1 = questionCollection
        .getQuestionsForScoreGroup(1)
        .where((e) => e.value != null && e.value != 4)
        .toList()
        .length;
    if (numValidResponsesForScoreGroup0 + numValidResponsesForScoreGroup1 !=
        0) {
      psychosocial = (generalAdjSum + adjToLimitSum) /
          (numValidResponsesForScoreGroup0 + numValidResponsesForScoreGroup1);
    }

    //Score for Activity Restriction (score group 2)
    num activitySum =
        questionCollection.getQuestionsForScoreGroup(2).fold(0, (p, e) {
      return e.value == null || e.value == 3 ? p : p + (2 - e.value);
    });
    int numValidResponses = questionCollection
        .getQuestionsForScoreGroup(2)
        .where((e) => e.value != null && e.value != 3)
        .toList()
        .length;
    if (numValidResponses != 0) {
      activity = activitySum / numValidResponses;
    }

    //Score for Aesthetic Satisfaction (score group 3)
    num satisfactionSum =
        questionCollection.getQuestionsForScoreGroup(3).fold(0, (p, e) {
      return e.value == null ? p : p + e.value + 1;
    });
    numValidResponses = questionCollection
        .getQuestionsForScoreGroup(3)
        .where((e) => e.value != null)
        .toList()
        .length;
    if (numValidResponses != 0) {
      satisfaction = satisfactionSum / numValidResponses;
    }

    generalSatisfaction =
        questionCollection.getQuestionById('tapes_r_34')!.value ?? CompletionStatus.incomplete.code;
    return {
      'score1': psychosocial == CompletionStatus.incomplete.code
          ? CompletionStatus.incomplete.code.toString()
          : psychosocial.toStringAsFixed(1),
      'score2':
          activity == CompletionStatus.incomplete.code ? CompletionStatus.incomplete.code.toString() : activity.toStringAsFixed(1),
      'score3': satisfaction == CompletionStatus.incomplete.code
          ? CompletionStatus.incomplete.code.toString()
          : satisfaction.toStringAsFixed(1),
      'tapes_r_34': generalSatisfaction == CompletionStatus.incomplete.code
          ? CompletionStatus.incomplete.code.toString()
          : generalSatisfaction.toStringAsFixed(0)
    };
  }

  @override
  bool get isComplete {
    for(var i = 0; i < questionCollection.numGroups; i++){
      if(i < 4){
        bool didCompleteGroup = questionCollection.isGroupComplete(i);
        if(didCompleteGroup){
          continue;
        }else{
          return false;
        }
      }else if(i == 4){
        bool didCompleteGroup = questionCollection.isGroupComplete(i, conditionalQuestionId: "tapes_r_38", conditionalValue: 0);
          if(didCompleteGroup){
            continue;
          }else{
            return false;
          }
      }else if(i == 5){
        bool didCompleteGroup = questionCollection.isGroupComplete(i, conditionalQuestionId: "tapes_r_43", conditionalValue: 0);
        if(didCompleteGroup){
          continue;
        }else{
          return false;
        }
      }else{
        bool didCompleteGroup = questionCollection.isGroupComplete(i, conditionalQuestionId: "tapes_r_48", conditionalValue: 0);
        if(didCompleteGroup){
          continue;
        }else{
          return false;
        }
      }
    }
    return true;
}

  TapesR({required super.id, super.data});

  factory TapesR.fromJson(Map<String, dynamic> data) {
    TapesR tapesR = TapesR(id: 'tapes_r');
    tapesR.populateWithJson(data);
    return tapesR;
  }

  factory TapesR.fromTemplateJson(Map<String, dynamic> data) {
    return TapesR(id: data['id'], data: data);
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
      "_templateId": ksTapesRTemplateId,
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
        responses.addAll(element.exportResponse!);
      }
    }
    responses.addAll(totalScore);
    return responses;
  }
}
