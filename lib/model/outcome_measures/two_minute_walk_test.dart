import 'dart:convert';

import 'package:biot/constants/app_strings.dart';
import 'package:biot/constants/enum.dart';
import 'package:biot/model/outcome_measures/outcome_measure.dart';
import 'package:biot/model/patient.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../generated/locale_keys.g.dart';
import '../question.dart';

class Tminwt extends OutcomeMeasure {
  double? _distance;
  double get distance => _distance ?? double.parse(totalScore['distance']);
  late String rawData;

  @override
  Map<String, dynamic> get totalScore {
    num? distance = questionCollection.getQuestionById('tminwt_1')?.value;
    if (distance != null) {
      return {
        'distance': distance.toStringAsFixed(2),
      };
    } else {
      return {
        'distance': CompletionStatus.incomplete.code.toString(),
      };
    }
  }

  Tminwt({required super.id, super.data});

  @override
  void populateWithJson(Map<String, dynamic> json) {
    _distance = json['${id}_distance'].toDouble();
    rawData = json['${id}_raw_data'];
    index = json['${id}_order'];
    creationTime = DateTime.parse(json['_creationTime']);
    sessionId = json['_referencers']?[id]['referrer']['id'];
    rawValue = _distance!;
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
      "_templateId": ksTminwtTemplateId,
      "_ownerOrganization": {"id": ownerOrganizationId},
      "${id}_distance": distance,
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
    Question q1 = questionCollection.getQuestionById('tminwt_1')!;
    Question q2 = questionCollection.getQuestionById('tminwt_2')!;
    if (q1.value != null) {
      responses.addAll(q1.exportResponse!);
    }
    responses.addAll({
      'tminwt_2':
          q2.value == null ? LocaleKeys.noneReported.tr() : '${q2.value}'
    });
    return responses;
  }

  @override
  double? normalizeSigDiffPositive() {
    return info.sigDiffPositive! * 100 / (info.maxYValue - info.minYValue);
  }

  @override
  double? normalizeSigDiffNegative() {
    return info.sigDiffNegative! * 100 / (info.maxYValue - info.minYValue);
  }
}
