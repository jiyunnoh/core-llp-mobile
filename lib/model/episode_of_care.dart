import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/model/socket_info.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_strings.dart';

class EpisodeOfCare {
  String? entityId;
  double? height;
  double? weight;
  TobaccoUsage? tobaccoUsage;
  MaxEducationLevel? maxEducationLevel;
  String icdCodesOfConditions;
  List<Profession> professionsInvolved;
  List<RehabilitationServices> rehabilitationServices;
  List<CompressionTherapy> compressionTherapies;
  String ctOther;
  ProstheticIntervention? prostheticIntervention;
  List<SocketInfo> socketInfoList;

  EpisodeOfCare(
      {this.height,
      this.weight,
      this.tobaccoUsage,
      this.maxEducationLevel,
      this.icdCodesOfConditions = '',
      this.professionsInvolved = const [],
      this.rehabilitationServices = const [],
      this.compressionTherapies = const [],
      this.ctOther = '',
      this.prostheticIntervention,
      this.socketInfoList = const []});

  EpisodeOfCare clone() {
    EpisodeOfCare clone = EpisodeOfCare();
    clone.entityId = entityId;
    clone.height = height;
    clone.weight = weight;
    clone.tobaccoUsage = tobaccoUsage;
    clone.maxEducationLevel = maxEducationLevel;
    clone.icdCodesOfConditions = icdCodesOfConditions;
    clone.professionsInvolved = professionsInvolved.toList();
    clone.rehabilitationServices = rehabilitationServices.toList();
    clone.compressionTherapies = compressionTherapies.toList();
    clone.ctOther = ctOther;
    clone.prostheticIntervention = prostheticIntervention;
    clone.socketInfoList = socketInfoList.toList();

    return clone;
  }

  @override
  bool operator ==(Object other) =>
      other is EpisodeOfCare &&
      other.height == height &&
      other.weight == weight &&
      other.tobaccoUsage == tobaccoUsage &&
      other.maxEducationLevel == maxEducationLevel &&
      other.icdCodesOfConditions == icdCodesOfConditions &&
      listEquals(other.professionsInvolved, professionsInvolved) &&
      listEquals(other.rehabilitationServices, rehabilitationServices) &&
      listEquals(other.compressionTherapies, compressionTherapies) &&
      other.ctOther == ctOther &&
      other.prostheticIntervention == prostheticIntervention &&
      listEquals(other.socketInfoList, socketInfoList);

  @override
  int get hashCode => Object.hash(
      height,
      weight,
      tobaccoUsage,
      maxEducationLevel,
      icdCodesOfConditions,
      professionsInvolved,
      rehabilitationServices,
      compressionTherapies,
      ctOther,
      prostheticIntervention,
      socketInfoList);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> body = {
      ksBodyMassIndexOfHeight: height ?? -1,
      ksBodyMassIndexOfWeight: weight ?? -1,
      ksTobaccoUse: tobaccoUsage?.index,
      ksMaximumEducationLevelObtained: maxEducationLevel?.index,
      ksIcdCodesOfConditions: icdCodesOfConditions,
      ksProfessionsInvolved:
          professionsInvolved.map((e) => e.index).toList().toString(),
      ksRehabilitationServices:
          rehabilitationServices.map((e) => e.index).toList().toString(),
      ksCompressionTherapy:
          compressionTherapies.map((e) => e.index).toList().toString(),
      kcCtOther: ctOther,
      ksProstheticIntervention: prostheticIntervention?.index
    };
    return body;
  }

// TODO: Jiyun - fromJson if needed later
// TODO: JIyun - looping getSocketInfo filtering with episode id, and create List<SocketInfo>

  Map<String, dynamic> toJsonForPDF() {
    Map<String, dynamic> jsonMap = {};

    if (height != null) {
      jsonMap.addAll({"height": height!.toStringAsFixed(1)});
    }
    if (weight != null) {
      jsonMap.addAll({"weight": weight!.toStringAsFixed(1)});
    }
    if (tobaccoUsage != null) {
      jsonMap.addAll({"tobacco_usage": tobaccoUsage!.displayName});
    }
    if (maxEducationLevel != null) {
      jsonMap.addAll({"education_level": maxEducationLevel!.displayName});
    }

    if (icdCodesOfConditions != '') {
      String idcCodesNoCommas = icdCodesOfConditions.replaceAll(',', ';');
      jsonMap.addAll({"icd_code": idcCodesNoCommas});
    }

    professionsInvolved
        .map((e) => jsonMap.addAll({"profession_${e.index}": "Yes"}))
        .toList();

    rehabilitationServices
        .map((e) => jsonMap.addAll({"rehab_service_${e.index}": "Yes"}))
        .toList();

    compressionTherapies
        .map((e) => jsonMap.addAll({"ct_${e.index}": "Yes"}))
        .toList();

    if (ctOther != '') {
      jsonMap.addAll({"ct_4_text": ctOther});
    }

    if (prostheticIntervention != null) {
      jsonMap
          .addAll({"pro_interventions": prostheticIntervention!.displayName});
    }

    return jsonMap;
  }
}
