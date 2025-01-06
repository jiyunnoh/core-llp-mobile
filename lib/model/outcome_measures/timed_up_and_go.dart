import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';

import '../../constants/app_strings.dart';
import '../../constants/enum.dart';
import '../../generated/locale_keys.g.dart';
import '../question.dart';
import 'outcome_measure.dart';

class Tug extends OutcomeMeasure {
  double? _elapsedTime;
  num get elapsedTime {
    if (_elapsedTime != null) {
      return _elapsedTime!;
    } else {
      Duration? elapsedTime =
          questionCollection.getQuestionById('tug_1')?.value;
      if (elapsedTime != null) {
        return elapsedTime.inMilliseconds.toDouble() / 1000;
      } else {
        return CompletionStatus.incomplete.code;
      }
    }
  }

  late String rawData;

  @override
  Map<String, dynamic> get totalScore {
    if(elapsedTime == CompletionStatus.incomplete.code){
      return {'elapsedTime': CompletionStatus.incomplete.code.toString()};
    }else{
      return {'elapsedTime': elapsedTime.toStringAsFixed(2)};
    }
  }


  Tug({required super.id, super.data});

  factory Tug.fromJson(Map<String, dynamic> data) {
    Tug tug = Tug(id: 'tug');
    tug.populateWithJson(data);
    return tug;
  }

  factory Tug.fromTemplateJson(Map<String, dynamic> data) {
    return Tug(id: data['id'], data: data);
  }

  @override
  void populateWithJson(Map<String, dynamic> json) {
    _elapsedTime = json['${id}_elapsed_time'].toDouble();
    rawData = json['${id}_raw_data'];
    index = json['${id}_order'];
    creationTime = DateTime.parse(json['_creationTime']);
    patientId = json['${id}_patient']['id'];
    sessionId = json['_referencers']?[id]['referrer']['id'];
    rawValue = _elapsedTime!;
    outcomeMeasureCreatedTimeString = json['${id}_created_time'];
    isPopulated = true;
  }

  @override
  Map<String, dynamic> toJson(ownerOrganizationId, patient, index) {
    List<Map<String, dynamic>> rawData = questionCollection.toJson();
    rawData.add(exportResponses('en'));
    Map<String, dynamic> body = {
      "_name": "${patient.initial}_${id}_$currentTime",
      "_templateId": ksTugTemplateId,
      "_ownerOrganization": {"id": ownerOrganizationId},
      "${id}_elapsed_time": elapsedTime,
      "${id}_order": index,
      "${id}_patient": {"id": patient.entityId},
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
    Question q1 = questionCollection.getQuestionById('tug_1')!;
    Question q2 = questionCollection.getQuestionById('tug_2')!;
    if (q1.value != null) {
      responses.addAll(q1.exportResponse!);
    }
    responses.addAll({
      'tug_2': q2.value == null ? LocaleKeys.noneReported.tr() : '${q2.value}'
    });
    return responses;
  }
}
