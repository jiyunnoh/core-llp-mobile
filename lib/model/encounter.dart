import 'package:biot/constants/app_strings.dart';
import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/constants/enum.dart';
import 'package:biot/model/domain.dart';
import 'package:biot/model/episode_of_care.dart';
import 'package:biot/model/outcome_measures/outcome_measure.dart';
import 'package:biot/model/patient.dart';
import 'package:biot/model/pre_post_episode_of_care.dart';
import 'package:biot/services/outcome_measure_load_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../app/app.locator.dart';
import '../services/cloud_service.dart';
import '../services/logger_service.dart';
import 'amputation.dart';
import 'condition.dart';
import 'domain_weight_distribution.dart';
import 'kLevel.dart';

part 'encounter.g.dart';

@HiveType(typeId: 1)
class Encounter extends HiveObject {
  final _logger = locator<LoggerService>().getLogger((Encounter).toString());

  @HiveField(0)
  String? entityId;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? creationTimeString;

  @HiveField(3)
  List<OutcomeMeasure>? outcomeMeasures;

  @HiveField(4)
  String? domainWeightDistId;

  @HiveField(5)
  DomainWeightDistribution? domainWeightDist;

  // TODO: change num to double
  // TODO: is it nullable?
  @HiveField(6)
  num? unweightedTotalScore;

  @HiveField(7)
  double? get weightedTotalScore =>
      _weightedTotalScore ?? calculateWeightedTotalScore(domainWeightDist);

  double? _weightedTotalScore;

  set weightedTotalScore(double? value) {
    _weightedTotalScore = value;
  }

  @HiveField(8)
  String? conditionId;

  @HiveField(9)
  Condition? condition;

  @HiveField(10)
  String? kLevelId;

  @HiveField(11)
  KLevel? kLevel;

  String? domainScoresId;

  @HiveField(14)
  String? encounterCreatedTimeString;

  DateTime? get encounterCreatedTime => (encounterCreatedTimeString != null)
      ? DateTime.parse(encounterCreatedTimeString!).toLocal()
      : null;

  final EncounterType? type;

  List<Domain> _domains = [];

  List<Domain> get domains => domainsMap.entries.map((e) => e.value).toList();

  set domains(List<Domain> domainList) {
    _domains = domainList;
  }

  Map<DomainType, Domain> domainsMap = {};

  bool isPopulated = false;

  EpisodeOfCare? episodeOfCare;
  PrePostEpisodeOfCare? prePostEpisodeOfCare;
  EpisodePrefix? prefix;
  Encounter? preEncounter;

  Submit? submitCode;

  // Map all outcome measures in encounter by domain type
  Map<DomainType, List<OutcomeMeasure>> get outcomeMeasuresByDomains {
    Map<DomainType, List<OutcomeMeasure>> domains = {};
    if (outcomeMeasures == null) return domains;
    for (OutcomeMeasure outcomeMeasure in outcomeMeasures!) {
      if (domains[outcomeMeasure.domainType] == null) {
        domains[outcomeMeasure.domainType] = [outcomeMeasure];
      } else {
        domains[outcomeMeasure.domainType]!.add(outcomeMeasure);
      }
    }
    return domains;
  }

  final _outcomeMeasureLoadService = locator<OutcomeMeasureLoadService>();

  // Unique name is required
  String generateUniqueEntityInstanceNameWithPatient(
      Patient patient, String entity) {
    DateTime now = DateTime.now();
    String currentTime =
        '${DateFormat('yyyyMMdd').format(now)}_${DateFormat('HHmmss').format(now)}';
    String uniqueName =
        '${patient.lastName[0]}${patient.firstName[0]}_${entity}_$currentTime'
            .toLowerCase();
    return uniqueName;
  }

  Encounter(
      {this.entityId,
      this.name,
      this.creationTimeString,
      this.outcomeMeasures,
      this.domainWeightDistId,
      this.domainWeightDist,
      this.domainScoresId,
      this.kLevelId,
      this.kLevel,
      this.conditionId,
      this.condition,
      this.type,
      this.unweightedTotalScore,
      this.encounterCreatedTimeString,
      this.prefix,
      this.submitCode}) {
    outcomeMeasures ??= [];
  }

  factory Encounter.fromJson(Map<String, dynamic> data) {
    DomainWeightDistribution? domainWeightDist;
    String? domainWeightDistId;
    String? domainScoresId;
    Condition? condition;
    String? conditionId;
    KLevel? kLevel;
    String? kLevelId;
    num? totalScore;
    String? encounterCreatedTimeString;

    if (data[ksDomainWeightDist] != null) {
      DomainWeightDistribution temp =
          DomainWeightDistribution(entityId: data[ksDomainWeightDist]['id']);
      domainWeightDist = temp;

      domainWeightDistId = data[ksDomainWeightDist]['id'];
    }

    if (data['condition'] != null) {
      Condition temp = Condition(entityId: data['condition']['id']);
      condition = temp;

      conditionId = data['condition']['id'];
    }

    if (data['domain_scores'] != null) {
      domainScoresId = data['domain_scores']['id'];
    }

    if (data['encounter_k_level'] != null) {
      KLevel temp = KLevel(entityId: data['encounter_k_level']['id']);
      kLevel = temp;

      kLevelId = data['encounter_k_level']['id'];
    }

    if (data['total_score'] != null) {
      totalScore = data['total_score'];
    }

    if (data['session_created_time'] != null) {
      encounterCreatedTimeString = data['session_created_time'];
    }

    Encounter encounter = Encounter(
        entityId: data['_id'],
        name: data['_name'],
        creationTimeString: data['_creationTime'],
        domainWeightDistId: domainWeightDistId,
        domainWeightDist: domainWeightDist,
        domainScoresId: domainScoresId,
        conditionId: conditionId,
        condition: condition,
        kLevelId: kLevelId,
        kLevel: kLevel,
        type: EncounterType.outcomeMeasure,
        unweightedTotalScore: totalScore,
        encounterCreatedTimeString: encounterCreatedTimeString);

    if (data['prefix'] != null) {
      encounter.prefix = EpisodePrefix.values[data['prefix']];
    }

    if (data['submit_code'] != null) {
      encounter.submitCode = Submit.values[data['submit_code']];
    }

    //TODO: can delete?
    //TODO JK: offload these to generic outcome measure class.

    if (data[ksPromispi] != null) {
      OutcomeMeasure outcomeMeasure = OutcomeMeasure.withId(ksPromispi);
      outcomeMeasure.entityId = data[ksPromispi]['id'];
      outcomeMeasure.templateId = ksPromispiTemplateId;
      outcomeMeasure.outcomeMeasureCreatedTimeString =
          encounterCreatedTimeString;
      encounter.addOutcomeMeasure(outcomeMeasure);
    }
    if (data[ksTmwt] != null) {
      OutcomeMeasure outcomeMeasure = OutcomeMeasure.withId('10mwt');
      outcomeMeasure.entityId = data[ksTmwt]['id'];
      outcomeMeasure.templateId = ksTmwtTemplateId;
      outcomeMeasure.outcomeMeasureCreatedTimeString =
          encounterCreatedTimeString;
      encounter.addOutcomeMeasure(outcomeMeasure);
    }
    if (data[ksPmq] != null) {
      OutcomeMeasure outcomeMeasure = OutcomeMeasure.withId(ksPmq);
      outcomeMeasure.entityId = data[ksPmq]['id'];
      outcomeMeasure.templateId = ksPmqTemplateId;
      outcomeMeasure.outcomeMeasureCreatedTimeString =
          encounterCreatedTimeString;
      encounter.addOutcomeMeasure(outcomeMeasure);
    }
    if (data[ksScs] != null) {
      OutcomeMeasure outcomeMeasure = OutcomeMeasure.withId(ksScs);
      outcomeMeasure.entityId = data[ksScs]['id'];
      outcomeMeasure.templateId = ksScsTemplateId;
      outcomeMeasure.outcomeMeasureCreatedTimeString =
          encounterCreatedTimeString;
      encounter.addOutcomeMeasure(outcomeMeasure);
    }
    if (data[ksPsfs] != null) {
      OutcomeMeasure outcomeMeasure = OutcomeMeasure.withId(ksPsfs);
      outcomeMeasure.entityId = data[ksPsfs]['id'];
      outcomeMeasure.templateId = ksPsfsTemplateId;
      outcomeMeasure.outcomeMeasureCreatedTimeString =
          encounterCreatedTimeString;
      encounter.addOutcomeMeasure(outcomeMeasure);
    }
    if (data[ksNprs] != null) {
      OutcomeMeasure outcomeMeasure = OutcomeMeasure.withId(ksNprs);
      outcomeMeasure.entityId = data[ksNprs]['id'];
      outcomeMeasure.templateId = ksNprsTemplateId;
      outcomeMeasure.outcomeMeasureCreatedTimeString =
          encounterCreatedTimeString;
      encounter.addOutcomeMeasure(outcomeMeasure);
    }
    if (data[ksTug] != null) {
      OutcomeMeasure outcomeMeasure = OutcomeMeasure.withId(ksTug);
      outcomeMeasure.entityId = data[ksTug]['id'];
      outcomeMeasure.templateId = ksTugTemplateId;
      outcomeMeasure.outcomeMeasureCreatedTimeString =
          encounterCreatedTimeString;
      encounter.addOutcomeMeasure(outcomeMeasure);
    }
    if (data[ksEq5d] != null) {
      OutcomeMeasure outcomeMeasure = OutcomeMeasure.withId(ksEq5d);
      outcomeMeasure.entityId = data[ksEq5d]['id'];
      outcomeMeasure.templateId = ksEq5dTemplateId;
      outcomeMeasure.outcomeMeasureCreatedTimeString =
          encounterCreatedTimeString;
      encounter.addOutcomeMeasure(outcomeMeasure);
    }
    if (data[ksPeqPain] != null) {
      OutcomeMeasure outcomeMeasure = OutcomeMeasure.withId(ksPeqPain);
      outcomeMeasure.entityId = data[ksPeqPain]['id'];
      outcomeMeasure.templateId = ksPeqPainTemplateId;
      outcomeMeasure.outcomeMeasureCreatedTimeString =
          encounterCreatedTimeString;
      encounter.addOutcomeMeasure(outcomeMeasure);
    }
    if (data[ksPeqSatisfaction] != null) {
      OutcomeMeasure outcomeMeasure = OutcomeMeasure.withId(ksPeqSatisfaction);
      outcomeMeasure.entityId = data[ksPeqSatisfaction]['id'];
      outcomeMeasure.templateId = ksPeqSatisfactionTemplateId;
      outcomeMeasure.outcomeMeasureCreatedTimeString =
          encounterCreatedTimeString;
      encounter.addOutcomeMeasure(outcomeMeasure);
    }
    if (data[ksPeqSocialBurden] != null) {
      OutcomeMeasure outcomeMeasure = OutcomeMeasure.withId(ksPeqSocialBurden);
      outcomeMeasure.entityId = data[ksPeqSocialBurden]['id'];
      outcomeMeasure.templateId = ksPeqSocialBurdenTemplateId;
      outcomeMeasure.outcomeMeasureCreatedTimeString =
          encounterCreatedTimeString;
      encounter.addOutcomeMeasure(outcomeMeasure);
    }
    if (data['fh'] != null) {
      OutcomeMeasure outcomeMeasure = OutcomeMeasure.withId('fh');
      outcomeMeasure.entityId = data['fh']['id'];
      outcomeMeasure.templateId = ksFhTemplateId;
      outcomeMeasure.outcomeMeasureCreatedTimeString =
          encounterCreatedTimeString;
      encounter.addOutcomeMeasure(outcomeMeasure);
    }

    return encounter;
  }

  Map<String, dynamic> toJson(Patient patient) {
    Map<String, dynamic> body = {
      "_templateId": ksEncounterTemplateId,
      "session_created_time": encounterCreatedTimeString,
      "patient": {"id": patient.entityId},
      ksDomainWeightDistribution: {"id": patient.domainWeightDist.entityId},
      "condition": {"id": patient.condition!.entityId},
      "encounter_k_level": {"id": patient.kLevel!.entityId},
      "total_score": unweightedTotalScore,
      "prefix": prefix?.index,
      "submit_code": submitCode!.index
    };

    if (episodeOfCare != null) {
      body.addAll({
        "episode_of_care": {"id": episodeOfCare!.entityId}
      });
    }

    if (prePostEpisodeOfCare != null) {
      body.addAll({
        "prepost_episode_of_care": {"id": prePostEpisodeOfCare!.entityId}
      });
    }

    for (var i = 0; i < outcomeMeasures!.length; i++) {
      OutcomeMeasure om = outcomeMeasures![i];
      //TODO:JK - need to change the id for 10mwt to tmwt. This will break COMET
      String omId = om.id;
      if (omId == '10mwt') {
        omId = 'tmwt';
      }
      body.addAll({
        omId: {"id": om.entityId}
      });
    }
    for (var i = 0; i < patient.amputations.length; i++){
      Amputation amputation = patient.amputations[i];
      if(amputation.entityId != null) {
        body.addAll({"amputation_$i": {"id": amputation.entityId!}});
      }
    }

    return body;
  }

  OutcomeMeasure getOutcomeMeasureTemplate(String id) {
    return _outcomeMeasureLoadService.allOutcomeMeasures
        .getOutcomeMeasureById(id);
  }

  // Calculate following scores:
  // each outcome measure score
  // unweighted total score
  // weighted total score
  void calculateScore() {
    // Calculate unweighted total score
    unweightedTotalScore = calculateUnweightedTotalScore();

    //  Calculate weighted total score
    weightedTotalScore = calculateWeightedTotalScore(domainWeightDist);
  }

  void addOutcomeMeasure(OutcomeMeasure om) {
    outcomeMeasures?.add(om);

    // Add outcome measure to its respective domain
    if (domainsMap[om.domainType] == null) {
      domainsMap[om.domainType] = Domain.withType(om.domainType);
    }
    domainsMap[om.domainType]!.outcomeMeasures.add(om);
  }

  void removeOutcomeMeasure(OutcomeMeasure om) {
    outcomeMeasures?.removeWhere((element) => element.name == om.name);

    // Remove domain if its outcome measure list is empty
    if (domainsMap[om.domainType]!.outcomeMeasures.isEmpty) {
      domainsMap.remove(om.domainType);
    }
  }

  List<Domain> _getDomainList() {
    _domains = [];

    domainsMap.forEach((key, value) {
      _domains.add(value);
    });

    return _domains;
  }

  // TODO: this is not applied for now, but should be done in the future.
  List<Domain> sortDomainListByPatientDomainWeightDistribution(
      List<DomainType> domainTypes) {
    List<Domain> domains = _getDomainList();
    for (int i = 0; i < domainTypes.length; i++) {
      int domainIndex =
          domains.indexWhere((element) => element.type == domainTypes[i]);
      domains.insert(i, domains[domainIndex]);
      domains.removeAt(domainIndex + 1);
    }

    return domains;
  }

  double calculateUnweightedTotalScore() {
    double total = -1;
    domainsMap.forEach((key, value) {
      total += value.score!;
    });
    total /= domainsMap.length;

    return total;
  }

  double calculateWeightedTotalScore(
      DomainWeightDistribution? domainWeightDist) {
    double total = -1;

    if (domainWeightDist != null) {
      domainsMap.forEach((key, value) {
        total +=
            value.score! * domainWeightDist.getDomainWeightValue(key) / 100;
      });
    }

    return total;
  }

  Color lighten(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
        c.alpha,
        c.red + ((255 - c.red) * p).round(),
        c.green + ((255 - c.green) * p).round(),
        c.blue + ((255 - c.blue) * p).round());
  }
}
