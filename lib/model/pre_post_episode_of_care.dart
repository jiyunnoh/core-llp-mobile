import 'package:biot/constants/compass_lead_enum.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_strings.dart';

class PrePostEpisodeOfCare {
  String? entityId;
  DateTime? dateOfCare;
  List<MobilityDevice> mobilityDevices;
  MobilityDeviceUsage? noWalkingAidsUsage;
  MobilityDeviceUsage? singlePointStickUsage;
  MobilityDeviceUsage? quadBaseWalkingStickUsage;
  MobilityDeviceUsage? singleCrutchUsage;
  MobilityDeviceUsage? pairOfCrutchesUsage;
  MobilityDeviceUsage? walkingFrameWalkerUsage;
  MobilityDeviceUsage? wheeledWalkerUsage;
  MobilityDeviceUsage? manualWheelchairUsage;
  MobilityDeviceUsage? poweredWheeledOrMobilityScooterUsage;
  IcfQualifiers? communityParticipation;
  IcfQualifiers? communityParticipationWithLimb;
  IcfQualifiers? abilityToWork;
  IcfQualifiers? abilityToWorkWithLimb;
  AmbulatoryActivityLevel? standingTimeInHour;
  AmbulatoryActivityLevel? walkingTimeInHour;
  YesOrNo? fall;
  FallFrequency? fallFrequency;
  YesOrNo? isInjuriousFall;
  YesOrNo? socialSupportAccess;
  YesOrNo? socialSupportUtil;
  YesOrNo? communityServiceAccess;
  CommunityService? communityService;

  List<MobilityDeviceUsage?> get mobilityDeviceUsages => [
        noWalkingAidsUsage,
        singlePointStickUsage,
        quadBaseWalkingStickUsage,
        singleCrutchUsage,
        pairOfCrutchesUsage,
        walkingFrameWalkerUsage,
        wheeledWalkerUsage,
        manualWheelchairUsage,
        poweredWheeledOrMobilityScooterUsage
      ];

  PrePostEpisodeOfCare(
      {this.dateOfCare,
      this.mobilityDevices = const [],
      this.noWalkingAidsUsage,
      this.quadBaseWalkingStickUsage,
      this.singleCrutchUsage,
      this.pairOfCrutchesUsage,
      this.walkingFrameWalkerUsage,
      this.wheeledWalkerUsage,
      this.manualWheelchairUsage,
      this.poweredWheeledOrMobilityScooterUsage,
      this.communityParticipation,
      this.communityParticipationWithLimb,
      this.abilityToWork,
      this.abilityToWorkWithLimb,
      this.standingTimeInHour,
      this.walkingTimeInHour,
      this.fall,
      this.fallFrequency,
      this.isInjuriousFall,
      this.socialSupportAccess,
      this.socialSupportUtil,
      this.communityServiceAccess,
      this.communityService});

  PrePostEpisodeOfCare clone() {
    PrePostEpisodeOfCare clone = PrePostEpisodeOfCare();
    clone.entityId = entityId;
    clone.dateOfCare = dateOfCare;
    clone.mobilityDevices = mobilityDevices.toList();
    clone.singlePointStickUsage = singlePointStickUsage;
    clone.quadBaseWalkingStickUsage = quadBaseWalkingStickUsage;
    clone.singleCrutchUsage = singleCrutchUsage;
    clone.pairOfCrutchesUsage = pairOfCrutchesUsage;
    clone.walkingFrameWalkerUsage = walkingFrameWalkerUsage;
    clone.wheeledWalkerUsage = wheeledWalkerUsage;
    clone.manualWheelchairUsage = manualWheelchairUsage;
    clone.poweredWheeledOrMobilityScooterUsage =
        poweredWheeledOrMobilityScooterUsage;
    clone.communityParticipation = communityParticipation;
    clone.communityParticipationWithLimb = communityParticipationWithLimb;
    clone.abilityToWork = abilityToWork;
    clone.abilityToWorkWithLimb = abilityToWorkWithLimb;
    clone.standingTimeInHour = standingTimeInHour;
    clone.walkingTimeInHour = walkingTimeInHour;
    clone.fall = fall;
    clone.fallFrequency = fallFrequency;
    clone.isInjuriousFall = isInjuriousFall;
    clone.socialSupportAccess = socialSupportAccess;
    clone.socialSupportUtil = socialSupportUtil;
    clone.communityServiceAccess = communityServiceAccess;
    clone.communityService = communityService;

    return clone;
  }

  @override
  bool operator ==(Object other) =>
      other is PrePostEpisodeOfCare &&
      other.dateOfCare == dateOfCare &&
      listEquals(other.mobilityDevices, mobilityDevices) &&
      other.singlePointStickUsage == singlePointStickUsage &&
      other.quadBaseWalkingStickUsage == quadBaseWalkingStickUsage &&
      other.singleCrutchUsage == singleCrutchUsage &&
      other.pairOfCrutchesUsage == pairOfCrutchesUsage &&
      other.walkingFrameWalkerUsage == walkingFrameWalkerUsage &&
      other.wheeledWalkerUsage == wheeledWalkerUsage &&
      other.manualWheelchairUsage == manualWheelchairUsage &&
      other.poweredWheeledOrMobilityScooterUsage ==
          poweredWheeledOrMobilityScooterUsage &&
      other.communityParticipation == communityParticipation &&
      other.communityParticipationWithLimb == communityParticipationWithLimb &&
      other.abilityToWork == abilityToWork &&
      other.abilityToWorkWithLimb == abilityToWorkWithLimb &&
      other.standingTimeInHour == standingTimeInHour &&
      other.walkingTimeInHour == walkingTimeInHour &&
      other.fall == fall &&
      other.fallFrequency == fallFrequency &&
      other.isInjuriousFall == isInjuriousFall &&
      other.socialSupportAccess == socialSupportAccess &&
      other.socialSupportUtil == socialSupportUtil &&
      other.communityServiceAccess == communityServiceAccess &&
      other.communityService == communityService;

  @override
  int get hashCode =>
      Object.hash(
          dateOfCare,
          mobilityDevices,
          singlePointStickUsage,
          quadBaseWalkingStickUsage,
          singleCrutchUsage,
          pairOfCrutchesUsage,
          walkingFrameWalkerUsage,
          wheeledWalkerUsage,
          manualWheelchairUsage,
          poweredWheeledOrMobilityScooterUsage,
          communityParticipation,
          communityParticipationWithLimb,
          abilityToWork,
          abilityToWorkWithLimb,
          standingTimeInHour,
          walkingTimeInHour,
          fall,
          fallFrequency,
          isInjuriousFall,
          socialSupportAccess) *
      Object.hash(socialSupportUtil, communityServiceAccess, communityService);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> body = {
      ksDateOfCare: dateOfCare!.toUtc().toIso8601String(),
      ksUseOfMobilityDevices:
          mobilityDevices.map((e) => e.index).toList().toString(),
      ksSinglePointStickUsage: singlePointStickUsage?.index,
      ksQuadBaseWalkingStickUsage: quadBaseWalkingStickUsage?.index,
      ksSingleCrutchUsage: singleCrutchUsage?.index,
      ksPairOfCrutchesUsage: pairOfCrutchesUsage?.index,
      ksWalkingFrameWalkerUsage: walkingFrameWalkerUsage?.index,
      ksWheeledWalkerUsage: wheeledWalkerUsage?.index,
      ksManualWheelchairUsage: manualWheelchairUsage?.index,
      ksPoweredWheelchairUsage: poweredWheeledOrMobilityScooterUsage?.index,
      ksCommunityParticipation: communityParticipation?.index,
      ksCommunityParticipationWithLimb: communityParticipationWithLimb?.index,
      ksAbilityToWork: abilityToWork?.index,
      ksAbilityToWorkWithLimb: abilityToWorkWithLimb?.index,
      ksStandingTimeInHour: standingTimeInHour?.index,
      ksWalkingTimeInHour: walkingTimeInHour?.index,
      ksOccasionFall: fall?.index,
      ksFallFrequency: fallFrequency?.index,
      ksIsInjuriousFall: isInjuriousFall?.index,
      ksAccessToSocialSupportAtHome: socialSupportAccess?.index,
      ksUtilizeAssistanceOfSocialSupport: socialSupportUtil?.index,
      ksAccessToCommunityServices: communityServiceAccess?.index,
      ksCommunityServicesOptions: communityService?.index,
    };
    return body;
  }

//  TODO: Jiyun - fromJson() might be needed later

  Map<String, dynamic> toJsonForPDF() {
    Map<String, dynamic> jsonMap = {
      "date": DateFormat('yyyy-MM-dd').format(dateOfCare!)
    };

    mobilityDevices.map((e) {
      jsonMap.addAll({"mobility_device_${e.index}": "Yes"});
      if (mobilityDeviceUsages[e.index] != null) {
        jsonMap.addAll({
          "mobility_usage_${e.index}":
              mobilityDeviceUsages[e.index]!.displayName
        });
      }
    }).toList();

    if (communityParticipation != null) {
      jsonMap.addAll({"participation": communityParticipation?.displayName});
    }
    if (communityParticipationWithLimb != null) {
      jsonMap.addAll({
        "participation_with_limb": communityParticipationWithLimb!.displayName
      });
    }
    if (abilityToWork != null) {
      jsonMap.addAll({"ability_to_work": abilityToWork!.displayName});
    }
    if (abilityToWorkWithLimb != null) {
      jsonMap.addAll(
          {"ability_to_work_with_limb": abilityToWorkWithLimb!.displayName});
    }
    if (standingTimeInHour != null) {
      jsonMap.addAll({"standing_time": standingTimeInHour!.displayName});
    }
    if (walkingTimeInHour != null) {
      jsonMap.addAll({"walking_time": walkingTimeInHour!.displayName});
    }
    if (fall != null) {
      jsonMap.addAll({"fall": fall!.displayName});
    }
    if (fallFrequency != null) {
      jsonMap.addAll({"fall_frequency": fallFrequency!.displayName});
    }
    if (isInjuriousFall != null) {
      jsonMap.addAll({"injurious_fall": isInjuriousFall!.displayName});
    }
    if (socialSupportAccess != null) {
      jsonMap
          .addAll({"social_support_access": socialSupportAccess!.displayName});
    }
    if (socialSupportUtil != null) {
      jsonMap.addAll({"social_support_util": socialSupportUtil!.displayName});
    }
    if (communityServiceAccess != null) {
      jsonMap.addAll(
          {"community_service_access": communityServiceAccess!.displayName});
    }
    if (communityService != null) {
      jsonMap.addAll({"community_service": communityService!.displayName});
    }

    return jsonMap;
  }
}
