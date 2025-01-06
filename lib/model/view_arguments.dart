import 'package:biot/constants/enum.dart';
import 'package:biot/model/patient.dart';
import 'package:biot/model/encounter.dart';
import 'package:flutter/material.dart';

import 'outcome_measures/outcome_measure.dart';

class EncounterViewArguments {
  final Patient patient;
  final ValueNotifier<List<Encounter>> encounters;

  EncounterViewArguments({required this.patient, required this.encounters});
}

class SummaryViewArguments {
  final Encounter encounter;
  final bool isNewAdded;

  SummaryViewArguments({required this.encounter, required this.isNewAdded});
}

class OmDetailViewArguments {
  final DomainType domainType;
  final List<OutcomeMeasure> outcomeMeasures;

  OmDetailViewArguments(
      {required this.domainType, required this.outcomeMeasures});
}
