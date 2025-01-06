import 'package:biot/constants/amputation_info.dart';
import 'package:biot/constants/compass_lead_enum.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_strings.dart';

class SocketInfo {
  String? entityId;
  DateTime? dateOfDelivery;
  AmputationSide? side;
  Socket? socket;
  PartialFootDesign? partialFootDesign;
  AnkleDisarticulationDesign? ankleDisarticulationDesign;
  TransTibialDesign? transTibialDesign;
  KneeDisarticulationDesign? kneeDisarticulationDesign;
  TransfemoralDesign? transfemoralDesign;
  List<SocketType> socketTypes;
  Liner? liner;
  Suspension? suspension;
  List<ProstheticFootType> prostheticFootTypes;
  List<ProstheticKneeType> prostheticKneeTypes;
  List<ProstheticHipType> prostheticHipTypes;

  //TODO: Jiyun - link episode id

  SocketInfo(
      {this.dateOfDelivery,
      this.side,
      this.socket,
      this.partialFootDesign,
      this.ankleDisarticulationDesign,
      this.transTibialDesign,
      this.kneeDisarticulationDesign,
      this.transfemoralDesign,
      this.socketTypes = const [],
      this.liner,
      this.suspension,
      this.prostheticFootTypes = const [],
      this.prostheticKneeTypes = const [],
      this.prostheticHipTypes = const []});

  SocketInfo clone() {
    SocketInfo clone = SocketInfo();
    clone.entityId = entityId;
    clone.dateOfDelivery = dateOfDelivery;
    clone.side = side;
    clone.socket = socket;
    clone.partialFootDesign = partialFootDesign;
    clone.ankleDisarticulationDesign = ankleDisarticulationDesign;
    clone.transTibialDesign = transTibialDesign;
    clone.kneeDisarticulationDesign = kneeDisarticulationDesign;
    clone.transfemoralDesign = transfemoralDesign;
    clone.socketTypes = socketTypes.toList();
    clone.liner = liner;
    clone.suspension = suspension;
    clone.prostheticFootTypes = prostheticFootTypes.toList();
    clone.prostheticKneeTypes = prostheticKneeTypes.toList();
    clone.prostheticHipTypes = prostheticHipTypes.toList();

    return clone;
  }

  @override
  bool operator ==(Object other) =>
      other is SocketInfo &&
      other.dateOfDelivery == dateOfDelivery &&
      other.side == side &&
      other.socket == socket &&
      other.partialFootDesign == partialFootDesign &&
      other.ankleDisarticulationDesign == ankleDisarticulationDesign &&
      other.transTibialDesign == transTibialDesign &&
      other.kneeDisarticulationDesign == kneeDisarticulationDesign &&
      other.transfemoralDesign == transfemoralDesign &&
      listEquals(other.socketTypes, socketTypes) &&
      other.liner == liner &&
      other.suspension == suspension &&
      listEquals(other.prostheticFootTypes, prostheticFootTypes) &&
      listEquals(other.prostheticKneeTypes, prostheticKneeTypes) &&
      listEquals(other.prostheticHipTypes, prostheticHipTypes);

  @override
  int get hashCode => Object.hash(
      dateOfDelivery,
      side,
      socket,
      partialFootDesign,
      ankleDisarticulationDesign,
      transTibialDesign,
      kneeDisarticulationDesign,
      transfemoralDesign,
      socketTypes,
      liner,
      suspension,
      prostheticFootTypes,
      prostheticKneeTypes,
      prostheticHipTypes);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> body = {
      ksDateOfDelivery: dateOfDelivery!.toUtc().toIso8601String(),
      "side": side?.index,
      ksSocket: socket?.index,
      ksPartialFoot: partialFootDesign?.index,
      ksAnkleDisarticulation: ankleDisarticulationDesign?.index,
      ksTransTibial: transTibialDesign?.index,
      ksKneeDisarticulation: kneeDisarticulationDesign?.index,
      ksTransfemoral: transfemoralDesign?.index,
      ksSocketType: socketTypes.map((e) => e.index).toList().toString(),
      ksLinerType: liner?.index,
      ksSuspension: suspension?.index,
      ksProstheticFootType:
          prostheticFootTypes.map((e) => e.index).toList().toString(),
      ksProstheticKneeType:
          prostheticKneeTypes.map((e) => e.index).toList().toString(),
      ksProstheticHipType:
          prostheticHipTypes.map((e) => e.index).toList().toString()
    };
    return body;
  }

  Map<String, dynamic> toJsonForPDF(int index) {
    Map<String, dynamic> jsonMap = {};

    if (side != null) {
      jsonMap.addAll({"side_$index": side!.displayName});
    }

    if (dateOfDelivery != null) {
      jsonMap.addAll(
          {"date_$index": DateFormat("yyyy-MM-dd").format(dateOfDelivery!)});
    }

    if (socket != null) {
      jsonMap.addAll({"socket_$index": socket!.displayName});
    }

    if (partialFootDesign != null) {
      jsonMap.addAll({"design_$index": partialFootDesign!.displayName});
    }

    if (ankleDisarticulationDesign != null) {
      jsonMap
          .addAll({"design_$index": ankleDisarticulationDesign!.displayName});
    }

    if (transTibialDesign != null) {
      jsonMap.addAll({"design_$index": transTibialDesign!.displayName});
    }

    if (kneeDisarticulationDesign != null) {
      jsonMap.addAll({"design_$index": kneeDisarticulationDesign!.displayName});
    }

    if (transfemoralDesign != null) {
      jsonMap.addAll({"design_$index": transfemoralDesign!.displayName});
    }

    socketTypes
        .map((e) => jsonMap.addAll({"type_${index}_${e.index}": "Yes"}))
        .toList();

    if (liner != null) {
      jsonMap.addAll({"liner_$index": liner!.displayName});
    }

    if (suspension != null) {
      jsonMap.addAll({"suspension_$index": suspension!.displayName});
    }

    prostheticFootTypes
        .map((e) => jsonMap.addAll({"foot_${index}_${e.index}": "Yes"}))
        .toList();

    prostheticKneeTypes
        .map((e) => jsonMap.addAll({"knee_${index}_${e.index}": "Yes"}))
        .toList();

    prostheticHipTypes
        .map((e) => jsonMap.addAll({"hip_${index}_${e.index}": "Yes"}))
        .toList();

    return jsonMap;
  }
}
