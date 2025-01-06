import 'package:biot/extensions/list_extension.dart';
import 'package:biot/model/outcome_measures/outcome_measure.dart';
import 'package:biot/model/encounter.dart';

import '../app/app.locator.dart';
import '../constants/compass_lead_enum.dart';
import '../constants/enum.dart';
import '../services/logger_service.dart';

class EncounterCollection {
  final _logger =
      locator<LoggerService>().getLogger((EncounterCollection).toString());

  // Encounters are sorted in descending order based on encounterCreatedTime.
  List<Encounter> _encounters = [];

  List<Encounter> get encounters => _encounters;

  EncounterCollection(List<Encounter> rawEncounters) {
    _encounters = rawEncounters
        .where((element) => element.submitCode! == Submit.finish)
        .toList();
    newerComparisonEncounter = lastEncounter;
    olderComparisonEncounter = secondToLastEncounter;
  }

  bool get isEmpty => encounters.isEmpty;
  bool get isNotEmpty => encounters.isNotEmpty;
  int get length => encounters.length;
  bool get canAddFirstNonEpisodeEncounter => (length == 2 && nonEpisodes.isEmpty) ||
         (length == 1 && episodes.first.prefix == EpisodePrefix.post);

  Encounter? get lastEncounter =>
      encounters.isNotEmpty ? encounters.first : null;

  Encounter? get secondToLastEncounter =>
      encounters.length > 1 ? encounters[1] : null;

  Encounter? newerComparisonEncounter;
  Encounter? olderComparisonEncounter;

  // Get all domain types from all encounters.
  List<DomainType> get allDomainTypes {
    List<DomainType> domainTypes = [];
    for (var encounter in encounters) {
      for (var domain in encounter.domains) {
        domainTypes.add(domain.type);
      }
    }

    return domainTypes.toSet().toList();
  }

  // Get all outcome measures for input domain type.
  List<OutcomeMeasure> allOutcomeMeasuresForDomain(DomainType domainType) {
    List<OutcomeMeasure> outcomeMeasures = [];
    for (Encounter encounter in encounters) {
      if (encounter.outcomeMeasuresByDomains[domainType] != null) {
        outcomeMeasures.addAll(encounter.outcomeMeasuresByDomains[domainType]!);
      }
    }

    return outcomeMeasures.toSet().toList();
  }

  // Get episodes. Encounters in episodes refer to the first two encounters
  // Sort by ascending order of completion date
  List<Encounter> get episodes {
    if (encounters.isEmpty) {
      return [];
    } else {
      List<Encounter> eps = [];
      eps.add(encounters.last);

      if (encounters.last.prefix == EpisodePrefix.pre &&
          encounters.length > 1) {
        eps.add(encounters[encounters.length - 2]);
      }
      return eps;
    }
  }

  // Get all encounters except the first two (by completion date).
  // Encounters are already sorted in descending order.
  List<Encounter> get nonEpisodes {
    if (encounters.length - episodes.length == 0) {
      return [];
    } else {
      return encounters.sublist(0, encounters.length - episodes.length);
    }
  }

  // Get pre encounter
  Encounter? get preEncounter {
    if (encounters.isEmpty) {
      return null;
    } else {
      return encounters
          .firstWhereOrNull((element) => element.prefix == EpisodePrefix.pre);
    }
  }
}
