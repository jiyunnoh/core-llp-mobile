import 'dart:convert';

import 'package:async/async.dart';
import 'package:biot/model/amputation.dart';
import 'package:biot/model/encounter.dart';
import 'package:hive/hive.dart';

import '../app/app.locator.dart';
import '../constants/amputation_info.dart';
import '../constants/app_strings.dart';
import '../constants/sex_at_birth.dart';
import '../services/cloud_service.dart';
import '../services/logger_service.dart';
import 'condition.dart';
import 'domain_weight_distribution.dart';
import 'encounter_collection.dart';
import 'kLevel.dart';

part 'patient.g.dart';

@HiveType(typeId: 0)
class Patient extends HiveObject {
  final _apiService = locator<BiotService>();
  final _logger = locator<LoggerService>().getLogger((Patient).toString());

  @HiveField(0)
  String id;

  @HiveField(1)
  String firstName;

  @HiveField(2)
  String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  int? sexAtBirthIndex;

  SexAtBirth get sexAtBirth => SexAtBirth.values[sexAtBirthIndex!];

  @HiveField(5)
  String? caregiverName;

  @HiveField(6)
  bool? isSetToDelete = false;

  @HiveField(7)
  List<Encounter>? encounters;

  @HiveField(8)
  String? domainWeightDistJson;

  String get initial => firstName[0].toUpperCase() + lastName[0].toUpperCase();

  DomainWeightDistribution? _domainWeightDist;

  DomainWeightDistribution get domainWeightDist {
    if (_domainWeightDist == null) {
      domainWeightDist =
          DomainWeightDistribution.fromJson(jsonDecode(domainWeightDistJson!));
      return _domainWeightDist!;
    } else {
      return _domainWeightDist!;
    }
  }

  set domainWeightDist(DomainWeightDistribution domainWeightDistribution) {
    _domainWeightDist = domainWeightDistribution;
  }

  @HiveField(10)
  String? entityId;

  @HiveField(11)
  DateTime? dob;

  @HiveField(12)
  int? currentSex;

  @HiveField(13)
  int? race;

  @HiveField(14)
  int? ethnicity;

  @HiveField(15)
  String? conditionJson;

  Condition? _condition;

  Condition? get condition {
    if (_condition == null) {
      condition = Condition.fromJson(jsonDecode(conditionJson!));
      return _condition;
    } else {
      return _condition;
    }
  }

  set condition(Condition? condition) {
    _condition = condition;
  }

  @HiveField(16)
  String? kLevelJson;

  KLevel? _kLevel;

  KLevel? get kLevel {
    if (_kLevel == null) {
      kLevel = KLevel.fromJson(jsonDecode(kLevelJson!));
      return _kLevel;
    } else {
      return _kLevel;
    }
  }

  set kLevel(KLevel? kLevel) {
    _kLevel = kLevel;
  }

  @HiveField(17)
  List<String?>? outcomeMeasures;

  @HiveField(18)
  DateTime? creationTime;

  late EncounterCollection encounterCollection;

  String? countryCode;

  List<Amputation> amputations = [];

  bool isPopulated = false;
  bool isLead;

  Patient(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      this.entityId,
      this.dob,
      this.sexAtBirthIndex,
      this.currentSex,
      this.race,
      this.ethnicity,
      this.caregiverName,
      this.domainWeightDistJson,
      this.conditionJson,
      this.kLevelJson,
      this.outcomeMeasures,
      this.countryCode,
      this.isLead = false,
      this.creationTime}) {
    amputations = [];
  }

  factory Patient.fromJson(Map<String, dynamic> data) {
    return Patient(
      id: data['patient_id'],
      entityId: data['_id'],
      firstName: data['_name']['firstName'],
      lastName: data['_name']['lastName'],
      email: data['_email'],
      dob: DateTime.parse(data['_dateOfBirth']),
      sexAtBirthIndex: data['sex_at_birth'],
      currentSex: data['current_sex'],
      race: data['race'],
      ethnicity: data['ethnicity'],
      countryCode: data['_address']?['countryCode'],
      caregiverName: (data['_caregiver'] != null)
          ? data['_caregiver']['name'].toString().split('(')[0]
          : null,
      domainWeightDistJson: jsonEncode(data[ksDomainWeightDist]),
      conditionJson: jsonEncode(data['condition']),
      kLevelJson: jsonEncode(data['k_level']),
      outcomeMeasures: (data['outcome_measures'] != null)
          ? data['outcome_measures'].toString().replaceAll(' ', '').split(',')
          : null,
        creationTime: DateTime.parse(data['_creationTime'])
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> body = {
      "patient_id": id,
      "sex_at_birth": sexAtBirthIndex,
      "_email": email,
      "_dateOfBirth": dob!.toIso8601String(),
    };
    return body;
  }

  Future populate() async {
    _logger.d('populating the client. entity id: $entityId');

    if (isPopulated) {
      _logger.d('already populated');
      return;
    }

    try {
      List<Amputation> tempAmputations =
          await _apiService.getAmputations(patientId: entityId);

      FutureGroup futureGroup = FutureGroup();

      if (tempAmputations.isNotEmpty) {
        for (Amputation amputation in tempAmputations) {
          futureGroup.add(amputation.populate());
        }
      }

      futureGroup.close();
      await futureGroup.future;

      //TODO: Jung - need to refactor this section
      List<Amputation> leftAmputations = tempAmputations
          .where((element) => element.side == AmputationSide.left)
          .toList();
      List<Amputation> rightAmputations = tempAmputations
          .where((element) => element.side == AmputationSide.right)
          .toList();
      List<Amputation> bilateralAmputations = tempAmputations
          .where((element) => element.side == AmputationSide.hemicorporectomy)
          .toList();
      List<Amputation> tempAmp = [];
      if (leftAmputations.isNotEmpty) {
        tempAmp.add(leftAmputations.first);
      }
      if (rightAmputations.isNotEmpty) {
        tempAmp.add(rightAmputations.first);
      }
      if (bilateralAmputations.isNotEmpty) {
        tempAmp.clear();
        tempAmp.add(bilateralAmputations.first);
      }
      amputations = tempAmp;

      isPopulated = true;
      _logger.d('successfully populated the client');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJsonForPDF() {
    return {"birth_year": dob!.year.toString(), "sex": sexAtBirth.displayName};
  }

  @override
  String toString() {
    return id;
  }
}
