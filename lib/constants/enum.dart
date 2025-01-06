import 'package:biot/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_strings.dart';

enum CompletionStatus {complete, incomplete;

  String get displayName {
    switch(this){
      case complete:
        return 'Complete';
      case incomplete:
        return 'Incomplete';
    }
  }

  num get code {
    switch(this){
      case complete:
        return -1;
      case incomplete:
        return 999;
    }
  }
}

enum EncounterType { mg, prosat, outcomeMeasure, unknown }

enum FilterType {
  performance('performance'),
  patientReported('patientReported'),
  lowerExtremity('lowerExtremity'),
  upperExtremity('upperExtremity');

  final String type;

  const FilterType(this.type);

  factory FilterType.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case FilterType.performance:
        return 'Performance';
      case FilterType.lowerExtremity:
        return 'Lower Extremity';
      case FilterType.upperExtremity:
        return 'Upper Extremity';
      case FilterType.patientReported:
        return 'Patient Reported';
    }
  }
}

enum DomainType {
  comfort('comfort'),
  function('function'),
  satisfaction('satisfaction'),
  community('community'),
  goals('goals'),
  hrqol('hrqol');

  final String type;

  const DomainType(this.type);

  factory DomainType.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    if (this == DomainType.hrqol) {
      return 'HRQoL';
    }
    return name.capitalize();
  }

  Color get color {
    switch (this) {
      case DomainType.comfort:
        return const Color(0xff4040FF);
      case DomainType.function:
        return const Color(0xff785B57);
      case DomainType.satisfaction:
        return const Color(0xffFFE84D);
      case DomainType.community:
        return const Color(0xff77FFF7);
      case DomainType.hrqol:
        return const Color(0xff77FFF7);
      case DomainType.goals:
        return const Color(0xffDCBEFF);
      default:
        return Colors.black;
    }
  }

  String get header {
    switch (this) {
      case DomainType.comfort:
        return ksComfortAndFit;
      case DomainType.function:
        return ksFunctionalPerformance;
      case DomainType.satisfaction:
        return ksGeneralSatisfaction;
      case DomainType.community:
        return ksCommunityInteraction;
      case DomainType.goals:
        return ksGoalAchievement;
      case DomainType.hrqol:
        return ksQualityOfLife;
    }
  }

  String get improvementSummary {
    switch (this) {
      case DomainType.comfort:
        return ksComfortImprovement;
      case DomainType.function:
        return ksFunctionImprovement;
      case DomainType.satisfaction:
        return ksSatisfactionImprovement;
      case DomainType.community:
        return ksCommunityImprovement;
      case DomainType.goals:
        return ksGoalsImprovement;
      case DomainType.hrqol:
        return 'PLACEHOLDER FOR HRQOL IMPROVEMENT TEXT';
    }
  }

  String get declineSummary {
    switch (this) {
      case DomainType.comfort:
        return ksComfortDecline;
      case DomainType.function:
        return ksFunctionDecline;
      case DomainType.satisfaction:
        return ksSatisfactionDecline;
      case DomainType.community:
        return ksCommunityDecline;
      case DomainType.goals:
        return ksGoalsDecline;
      case DomainType.hrqol:
        return 'PLACEHOLDER FOR HRQOL DECLINE TEXT';
    }
  }
}

enum ConditionType { orthotic, prosthetic, other, upper, lower }

enum AmputeeSide { left, right, both }

enum ChangeDirection {
  stable,
  positive,
  negative,
  sigPositive,
  sigNegative;

  Color get color {
    switch (this) {
      case ChangeDirection.stable:
        return Colors.black;
      case ChangeDirection.positive:
        return Colors.green;
      case ChangeDirection.negative:
        return Colors.red;
      case ChangeDirection.sigPositive:
        return Colors.green;
      case ChangeDirection.sigNegative:
        return Colors.red;
    }
  }
}

EncounterType getType(String value) {
  if (value.toLowerCase().split('-').first == 'euro') {
    return EncounterType.prosat;
  }
  if (value.toLowerCase().split('-').first == 'mg') {
    return EncounterType.mg;
  }
  return EncounterType.unknown;
}

enum QuestionType {
  basic,
  radial,
  radial_checkbox,
  vas,
  discrete_scale,
  discrete_scale_checkbox,
  discrete_scale_text,
  checkbox,
  vas_checkbox_combo,
  text,
  text_checkbox,
  time,
  unknown
}

extension ParseToString on EncounterType {
  String toStringValue() {
    return toString().split('.').last;
  }
}

extension GetDomainDisplayName on DomainType {
  String get toDisplayName =>
      '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
}

extension DateTimeFormat on DateTime {
  String toFormattedString(DateFormat dateFormat) {
    return dateFormat.format(this);
  }
}

extension GetConditionTypeDisplayName on ConditionType {
  String get toDisplayName =>
      '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
}
