import 'package:biot/constants/enum.dart';
import '../constants/app_strings.dart';

class DomainWeightDistribution {
  String? entityId;
   num? community;
  num? function;
  num? goals;
  num? comfort;
  num? satisfaction;

  DomainWeightDistribution(
      {this.entityId,
      this.community,
      this.function,
      this.goals,
      this.comfort,
      this.satisfaction});

  factory DomainWeightDistribution.equalDistribute() {
    return DomainWeightDistribution(
        community: 20, function: 20, goals: 20, comfort: 20, satisfaction: 20);
  }

  List<DomainType> get domainSortedByWeight {
    List<Map<String, dynamic>> numList = [
      {'type': DomainType.community, 'value': community},
      {'type': DomainType.function, 'value': function},
      {'type': DomainType.goals, 'value': goals},
      {'type': DomainType.comfort, 'value': comfort},
      {'type': DomainType.satisfaction, 'value': satisfaction},
      // {'type': DomainType.hrqol, 'value': community},
    ];
    numList.sort((a, b) => b['value'].compareTo(a['value']));
    return numList.map<DomainType>((e) => e['type']).toList();
  }

  num getDomainWeightValue(DomainType type) {
    switch (type) {
      case DomainType.community:
        return community!;
      case DomainType.function:
        return function!;
      case DomainType.goals:
        return goals!;
      case DomainType.comfort:
        return comfort!;
      case DomainType.satisfaction:
        return satisfaction!;
      case DomainType.hrqol:
        return community!;
    }
  }

  factory DomainWeightDistribution.fromJson(Map<String, dynamic> data) {
    DomainWeightDistribution domainWeightDist = DomainWeightDistribution(
        entityId: data['_id'] ?? data['id'],
        community: data[ksCommunityWeightVal],
        function: data[ksFunctionWeightVal],
        goals: data[ksGoalsWeightVal],
        comfort: data[ksComfortWeightVal],
        satisfaction: data[ksSatisfactionWeightVal]);
    return domainWeightDist;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> body = {
      "_templateId": ksDomainWeightDistTemplateId,
      ksCommunityWeightVal: community,
      ksFunctionWeightVal: function,
      ksGoalsWeightVal: goals,
      ksComfortWeightVal: comfort,
      ksSatisfactionWeightVal: satisfaction,
      // //TODO: JK- assign proper qol value
      // ksHrQoLWeightVal: community
    };
    
    if (entityId != null) {
      body.addAll({"id" : entityId});
    }

    return body;
  }
}
