import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:biot/model/amputation.dart';
import 'package:biot/model/domain_weight_distribution.dart';
import 'package:biot/model/episode_of_care.dart';
import 'package:biot/model/outcome_measures/outcome_measure.dart';
import 'package:biot/model/pre_post_episode_of_care.dart';
import 'package:http/http.dart' as http;
import 'package:biot/app/app.locator.dart';
import 'package:biot/model/patient.dart';
import 'package:biot/model/encounter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../constants/app_strings.dart';

import '../constants/compass_lead_enum.dart';
import '../model/condition.dart';
import '../model/kLevel.dart';
import '../model/socket_info.dart';
import 'logger_service.dart';

const String _endpoint = 'https://api.dev.orthocare.biot-med.com';
const String _patientApi = '/organization/v1/users/patients';
const String _genericEntityApi = '/generic-entity/v1/generic-entities';
const String _paramName = 'searchRequest';

class BiotService {
  late String token;
  late String userId;
  String? caregiverId;
  String? caregiverName;
  late String ownerOrganizationId;
  late String ownerOrganizationCode;
  late String refreshToken;
  DateTime? updateTime;

  final LoggerService _loggerService;
  late final Logger _logger;

  Client client = http.Client();

  Map<String, String> get jsonRequestHeaders => {
        'content-type': 'application/json',
        'accept': 'application/json',
      };

  Map<String, String> get textRequestHeaders => {
        'accept': 'application/json',
      };

  Map<String, String> get requestHeadersAuthorization => {
        'Authorization': 'Bearer $token',
      };

  Map<String, String> get requestHeadersConfirmEmail => {
        'email-confirmation-landing-page':
            'https://organization.app.dev.orthocare.biot-med.com/auth/invitation',
      };

  BiotService({LoggerService? loggerService})
      : _loggerService = loggerService ?? locator<LoggerService>() {
    _logger = _loggerService.getLogger((BiotService).toString());
  }

  //login with credentials
  Future<void> loginWithCredentials(id, pwd) async {
    _logger.d('attempting to log in');

    const String loginWithCredentialsApi = '/ums/v2/users/login';
    String url = _endpoint + loginWithCredentialsApi;
    Map<String, dynamic> responseJson;

    try {
      final response = await client.post(Uri.parse(url),
          headers: jsonRequestHeaders,
          body: jsonEncode(<String, String>{"username": id, "password": pwd}));

      responseJson = _returnResponse(response);
      _logger.d('successfully logged in');
      _logger.d('current time: ${DateTime.now()}');

      userId = id;

      ownerOrganizationId = responseJson[ksOwnerOrganizationId];
      token = responseJson[ksAccessJwt][ksToken];
      refreshToken = responseJson[ksRefreshJwt][ksToken];

      _logger.d(
          'expiration time: ${DateTime.parse(responseJson[ksAccessJwt]['expiration']).toLocal()}');

      return;
    } catch (e) {
      rethrow;
    }
  }

  //refresh tokens
  Future<void> refreshTokens() async {
    _logger.d('');
    const String refreshTokenApi = '/ums/v2/users/token/refresh';
    String url = _endpoint + refreshTokenApi;
    Map<String, dynamic> responseJson;

    Map<String, dynamic> json = {"refreshToken": refreshToken};
    String body = jsonEncode(json);

    //requires authorization
    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    try {
      final response = await client
          .post(Uri.parse(url), headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      responseJson = _returnResponse(response);

      token = responseJson[ksAccessJwt][ksToken];
      refreshToken = responseJson[ksRefreshJwt][ksToken];

      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logOut() async {
    _logger.d('');

    const String logOutApi = '/ums/v2/users/logout';
    String url = _endpoint + logOutApi;

    try {
      final response = await client.post(Uri.parse(url),
          headers: jsonRequestHeaders,
          body: jsonEncode(<String, String>{"refreshToken": refreshToken}));

      _returnResponse(response);

      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Patient>> getPatients(
      {bool isRetry = false, String? caregiverId}) async {
    _logger.d('');

    String url = _endpoint + _patientApi;
    Map<String, dynamic> responseJson;

    //requires authorization
    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    try {
      final response = await client.get(Uri.parse(url), headers: headers);

      responseJson = _returnResponse(response);

      _logger.d('successfully retrieved patient list');

      List<Patient> patients = (responseJson['data'] as List).map((patient) {
        return Patient.fromJson(patient);
      }).toList();

      _logger.d('successfully converted json to List<Patient>');

      updateTime = DateTime.now();

      return patients;
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) {
          return getPatients(isRetry: true);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  //add a new patient
  Future<void> addPatient(
    Patient patient, {
    bool isRetry = false,
  }) async {
    _logger.d('');

    String url = _endpoint + _patientApi;
    Map<String, dynamic> responseJson;

    //TODO: How to handle when domain weight dist had been already created, but adding patient failed?

    Map<String, dynamic> bodyMap = {
      "_name": {"firstName": patient.firstName, "lastName": patient.lastName},
      "_templateId": ksPatientTemplateId,
      ksOwnerOrganization: {"id": ownerOrganizationId},
      ksDomainWeightDistribution: {"id": patient.domainWeightDist.entityId},
      "condition": {"id": patient.condition!.entityId},
      "k_level": {"id": patient.kLevel!.entityId},
    };

    bodyMap.addAll(patient.toJson());

    String body = jsonEncode(bodyMap);

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization,
      ...requestHeadersConfirmEmail
    };

    http.Request request = http.Request('post', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request));

      responseJson = _returnResponse(response);

      _logger.d('successfully added patient');

      String entityId = responseJson['_id'];

      FutureGroup futureGroup = FutureGroup();

      futureGroup.close();
      await futureGroup.future;
      patient.entityId = entityId;
      patient.creationTime = DateTime.parse(responseJson['_creationTime']);
      return;
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2))
            .then((value) => addPatient(patient, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editPatient(Patient patient, {bool isRetry = false}) async {
    _logger.d('');

    String url = '$_endpoint$_patientApi/${patient.entityId!}';

    String body = jsonEncode({
      "_dateOfBirth": patient.dob!.toIso8601String(),
      "sex_at_birth": patient.sexAtBirthIndex
    });

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('patch', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request));

      _returnResponse(response);

      _logger.d('successfully updated patient');

      return;
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2))
            .then((value) => editPatient(patient, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addDomainWeightDistribution(
      {required DomainWeightDistribution domainWeightDist,
      required String patientName,
      String? date,
      bool isRetry = false}) async {
    _logger.d('');

    String url = _endpoint + _genericEntityApi;
    Map<String, dynamic> responseJson;
    date = date ?? 'current';

    Map<String, dynamic> json = domainWeightDist.toJson();
    json.addAll({
      "_name": "${patientName}_dwd_$date",
      ksOwnerOrganization: {"id": ownerOrganizationId}
    });

    String body = jsonEncode(json);

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('post', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request));

      responseJson = _returnResponse(response);

      _logger.d('successfully added domain weight dist');

      return responseJson['_id'];
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            addDomainWeightDistribution(
                patientName: patientName,
                domainWeightDist: domainWeightDist,
                date: date,
                isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addKLevel(
      {required KLevel kLevel,
      required String patientName,
      String? date,
      bool isRetry = false}) async {
    _logger.d('');

    String url = _endpoint + _genericEntityApi;
    Map<String, dynamic> responseJson;
    date = date ?? 'current';

    Map<String, dynamic> kLevelJson = kLevel.toJson();
    kLevelJson.addAll({
      "_name": "${patientName}_kLevel_$date",
      ksOwnerOrganization: {"id": ownerOrganizationId},
    });

    String body = jsonEncode(kLevelJson);

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('post', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request));

      responseJson = _returnResponse(response);

      _logger.d('successfully added k-level');

      return responseJson['_id'];
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            addKLevel(
                patientName: patientName,
                kLevel: kLevel,
                date: date,
                isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addCondition(Condition condition, String patientName,
      {String? date, bool isRetry = false}) async {
    _logger.d('');

    String url = _endpoint + _genericEntityApi;
    Map<String, dynamic> responseJson;
    date = date ?? 'current';

    Map<String, dynamic> conditionJson = condition.toJson();

    conditionJson.addAll({
      "_name": "${patientName}_condition_$date",
      ksOwnerOrganization: {"id": ownerOrganizationId},
    });

    String body = jsonEncode(conditionJson);

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('post', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request));

      responseJson = _returnResponse(response);

      _logger.d('successfully added condition');

      return responseJson['_id'];
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            addCondition(condition, patientName, date: date, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get a list of outcome measure sessions filtered by patient
  Future<List<Encounter>> getEncounters(
      {bool isRetry = false, required String patientEntityId}) async {
    _logger.d('');

    String url = _endpoint + _genericEntityApi;
    Map<String, dynamic> responseJson;

    //requires authorization
    Map<String, String> headers = {
      ...textRequestHeaders,
      ...requestHeadersAuthorization
    };

    Map<String, dynamic> filterByPatient = {
      "filter": {
        "_templateId": {"eq": ksEncounterTemplateId},
        "patient.id": {"eq": patientEntityId}
      }
    };

    //encode filter map to json
    String urlWithParam =
        '$url?$_paramName=${Uri.encodeQueryComponent(json.encode(filterByPatient))}';

    try {
      final response =
          await client.get(Uri.parse(urlWithParam), headers: headers);

      responseJson = _returnResponse(response);
      _logger.d('successfully retrieved encounter list');

      List<Encounter> encounters = (responseJson['data'] as List)
          .map((encounter) => Encounter.fromJson(encounter))
          .toList();

      _logger.d('successfully converted json to List<Encounter>');

      return encounters;
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            getEncounters(patientEntityId: patientEntityId, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  // Add a new encounter
  Future<void> addEncounter(Encounter encounter, Patient patient,
      {bool isRetry = false}) async {
    _logger.d('');

    String url = _endpoint + _genericEntityApi;
    Map<String, dynamic> responseJson;

    String currentTime =
        '${DateFormat('yyyyMMdd').format(DateTime.now())}_${DateFormat.Hms().format(DateTime.now())}';

    Map<String, dynamic> encounterJson = encounter.toJson(patient);
    encounterJson.addAll({
      "_name": "${patient.initial}_session_$currentTime",
      ksOwnerOrganization: {"id": ownerOrganizationId},
    });

    String body = jsonEncode(encounterJson);

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('post', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request))
              .timeout(const Duration(seconds: 10));

      responseJson = _returnResponse(response);

      _logger.d('successfully added encounter');

      encounter.entityId = responseJson['_id'];
    } on TimeoutException {
      _logger.d('timed out');
      rethrow;
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2))
            .then((value) => addEncounter(encounter, patient, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editEncounter(Encounter encounter,
      {bool isRetry = false}) async {
    _logger.d('');

    String url = '$_endpoint$_genericEntityApi/${encounter.entityId}';

    String body = jsonEncode({"submit_code": encounter.submitCode!.index});

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('patch', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request));

      _returnResponse(response);

      _logger.d('successfully edited encounter');
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2))
            .then((value) => editEncounter(encounter, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editEncounterWithPostEncounterId(Encounter postEncounter,
      {bool isRetry = false}) async {
    _logger.d('');

    String url =
        '$_endpoint$_genericEntityApi/${postEncounter.preEncounter!.entityId}';

    String body = jsonEncode({
      "post_encounter": {"id": postEncounter.entityId}
    });

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('patch', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request));

      _returnResponse(response);

      _logger.d('successfully edited encounter with post encounter id');
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            editEncounterWithPostEncounterId(postEncounter, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  // Add a list of outcome measures
  Future<List<String>> _addOutcomeMeasures(
      List<OutcomeMeasure> outcomeMeasures, Patient patient) async {
    List<String> result = [];

    for (var i = 0; i < outcomeMeasures.length; i++) {
      String eachOutcomeMeasureId =
          await addOutcomeMeasure(i, outcomeMeasures[i], patient);
      result.add(eachOutcomeMeasureId);
    }

    return result;
  }

  // Add an outcome measure
  Future<String> addOutcomeMeasure(
      int index, OutcomeMeasure outcomeMeasure, Patient patient,
      {bool isRetry = false}) async {
    _logger.d('');

    String url = _endpoint + _genericEntityApi;
    Map<String, dynamic> responseJson;

    String body =
        jsonEncode(outcomeMeasure.toJson(ownerOrganizationId, patient, index));

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('post', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request))
              .timeout(const Duration(seconds: 10));

      responseJson = _returnResponse(response);

      _logger.d('successfully added ${outcomeMeasure.id}');

      outcomeMeasure.entityId = responseJson['_id'];
      return responseJson['_id'];
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            addOutcomeMeasure(index, outcomeMeasure, patient, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getOrganizationCodeById({bool isRetry = false}) async {
    _logger.d('');

    const String getCaregiverApi = '/organization/v1/organizations/';
    String url = _endpoint + getCaregiverApi + ownerOrganizationId;
    Map<String, dynamic> responseJson;

    //requires authorization
    Map<String, String> headers = {
      ...textRequestHeaders,
      ...requestHeadersAuthorization
    };

    try {
      final response = await client.get(Uri.parse(url), headers: headers);

      responseJson = _returnResponse(response);

      _logger.d('successfully get org code by id');

      ownerOrganizationCode = responseJson['code'];

      return;
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2))
            .then((value) => getOrganizationCodeById(isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  //TODO: Jiyun - why patientId is optional, not required?
  Future<List<Amputation>> getAmputations(
      {bool isRetry = false, String? patientId}) async {
    _logger.d('');

    String url = _endpoint + _genericEntityApi;
    Map<String, dynamic> responseJson;

    //requires authorization
    Map<String, String> headers = {
      ...textRequestHeaders,
      ...requestHeadersAuthorization
    };

    Map<String, dynamic> filterByPatient = {
      "filter": {
        "_templateId": {"eq": ksAmputationTemplateId},
        "patient_with_amputation.id": {"eq": patientId}
      }
    };

    //encode map to json
    String urlWithParam =
        '$url?$_paramName=${Uri.encodeQueryComponent(json.encode(filterByPatient))}';

    try {
      final response =
          await client.get(Uri.parse(urlWithParam), headers: headers);

      responseJson = _returnResponse(response);

      _logger.d('successfully retrieved amputation list');

      List<Amputation> amputations = (responseJson['data'] as List)
          .map((amputation) => Amputation.fromJson(amputation))
          .toList();

      _logger.d('successfully converted json to List<Amputation>');

      return amputations;
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then(
            (value) => getAmputations(patientId: patientId, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Amputation> getAmputation(
      {bool isRetry = false, required String amputationId}) async {
    _logger.d('');

    String url = _endpoint + _genericEntityApi;
    Map<String, dynamic> responseJson;

    //requires authorization
    Map<String, String> headers = {
      ...textRequestHeaders,
      ...requestHeadersAuthorization
    };

    Map<String, dynamic> filterById = {
      "filter": {
        "_id": {"eq": amputationId}
      }
    };

    //encode map to json
    String urlWithParam =
        '$url?$_paramName=${Uri.encodeQueryComponent(json.encode(filterById))}';

    try {
      final response =
          await client.get(Uri.parse(urlWithParam), headers: headers);
      responseJson = _returnResponse(response);

      _logger.d('successfully retrieved amputation');

      return Amputation.fromJson(responseJson['data'][0]);
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            getAmputation(amputationId: amputationId, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAmputation(Amputation amputation,
      {required Patient patient, bool isRetry = false}) async {
    _logger.d('');

    String url = _endpoint + _genericEntityApi;
    Map<String, dynamic> responseJson;

    Map<String, dynamic> bodyMap = {
      "_name": patient.id,
      "_templateId": ksAmputationTemplateId,
      "_ownerOrganization": {"id": ownerOrganizationId},
      "patient_with_amputation": {"id": patient.entityId}
    };

    bodyMap.addAll(amputation.toJson());
    String body = jsonEncode(bodyMap);

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('post', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request))
              .timeout(const Duration(seconds: 10));

      responseJson = _returnResponse(response);

      _logger.d('successfully added amputation');

      amputation.entityId = responseJson['_id'];
    } on TimeoutException {
      _logger.d('timed out');
      rethrow;
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            addAmputation(amputation, patient: patient, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editAmputation(Amputation amputation,
      {bool isRetry = false}) async {
    _logger.d('');

    String url = '$_endpoint$_genericEntityApi/${amputation.entityId}';

    String body = jsonEncode(amputation.toJson());

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('patch', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request));

      _returnResponse(response);

      _logger.d('successfully edited amputation');
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2))
            .then((value) => editAmputation(amputation, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAmputations(List<Amputation> amputationList,
      {bool isRetry = false}) async {
    FutureGroup futureGroup = FutureGroup();

    try {
      for (var i = 0; i < amputationList.length; i++) {
        futureGroup
            .add(_deleteAmputation(amputationId: amputationList[i].entityId!));
      }
    } catch (e) {
      rethrow;
    }

    futureGroup.close();
    await futureGroup.future;
  }

  Future<void> _deleteAmputation(
      {required String amputationId, bool isRetry = false}) async {
    _logger.d('');

    String url = '$_endpoint$_genericEntityApi/$amputationId';

    //requires authorization
    Map<String, String> headers = {...requestHeadersAuthorization};

    try {
      final response = await client.delete(Uri.parse(url), headers: headers);

      _returnResponse(response);

      _logger.d('successfully deleted amputation');
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            _deleteAmputation(amputationId: amputationId, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addEpisodeOfCare(EpisodeOfCare episodeOfCare,
      {bool isRetry = false}) async {
    _logger.d('');

    String url = _endpoint + _genericEntityApi;
    Map<String, dynamic> responseJson;

    Map<String, dynamic> bodyMap = {
      "_name": 'test',
      "_templateId": ksEpisodeOfCareTemplateId,
      "_ownerOrganization": {"id": ownerOrganizationId}
    };

    bodyMap.addAll(episodeOfCare.toJson());

    String body = jsonEncode(bodyMap);

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('post', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request))
              .timeout(const Duration(seconds: 10));

      responseJson = _returnResponse(response);

      _logger.d('successfully added episode of care');

      episodeOfCare.entityId = responseJson['_id'];

      FutureGroup futureGroup = FutureGroup();

      for (SocketInfo socketInfo in episodeOfCare.socketInfoList) {
        futureGroup.add(addSocketInfo(
            episodeOfCare: episodeOfCare, socketInfo: socketInfo));
      }

      futureGroup.close();

      await futureGroup.future;
    } on TimeoutException {
      _logger.d('timed out');
      rethrow;
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2))
            .then((value) => addEpisodeOfCare(episodeOfCare, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editEpisodeOfCare(
      {required EpisodeOfCare episodeOfCare, bool isRetry = false}) async {
    _logger.d('');

    String url = '$_endpoint$_genericEntityApi/${episodeOfCare.entityId}';

    String body = jsonEncode(episodeOfCare.toJson());

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('patch', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request));

      _returnResponse(response);

      _logger.d('successfully edited episode of care');

      FutureGroup futureGroup = FutureGroup();

      for (int i = 0; i < episodeOfCare.socketInfoList.length; i++) {
        futureGroup
            .add(editSocketInfo(socketInfo: episodeOfCare.socketInfoList[i]));
      }
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            editEpisodeOfCare(episodeOfCare: episodeOfCare, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPrePost(
      {required PrePostEpisodeOfCare prePostEpisodeOfCare,
      bool isRetry = false}) async {
    _logger.d('');

    String url = _endpoint + _genericEntityApi;
    Map<String, dynamic> responseJson;

    Map<String, dynamic> bodyMap = {
      "_name": "test",
      "_templateId": ksPrepostEpisodeOfCareTemplateId,
      "_ownerOrganization": {"id": ownerOrganizationId}
    };

    bodyMap.addAll(prePostEpisodeOfCare.toJson());

    String body = jsonEncode(bodyMap);

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('post', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request))
              .timeout(const Duration(seconds: 10));

      responseJson = _returnResponse(response);

      _logger.d('successfully added pre/post');

      prePostEpisodeOfCare.entityId = responseJson['_id'];
    } on TimeoutException {
      _logger.d('timed out');
      rethrow;
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            addPrePost(
                prePostEpisodeOfCare: prePostEpisodeOfCare, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editPrePost(
      {required PrePostEpisodeOfCare prePostEpisodeOfCare,
      bool isRetry = false}) async {
    _logger.d('');

    String url =
        '$_endpoint$_genericEntityApi/${prePostEpisodeOfCare.entityId}';

    String body = jsonEncode(prePostEpisodeOfCare.toJson());

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('patch', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request));

      _returnResponse(response);

      _logger.d('successfully edited pre/post');
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            editPrePost(
                prePostEpisodeOfCare: prePostEpisodeOfCare, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSocketInfo(
      {required EpisodeOfCare episodeOfCare,
      required SocketInfo socketInfo,
      bool isRetry = false}) async {
    _logger.d('');

    String url = _endpoint + _genericEntityApi;
    Map<String, dynamic> responseJson;

    Map<String, dynamic> bodyMap = {
      "_name": 'test',
      "_templateId": ksSocketInfoTemplateId,
      "_ownerOrganization": {"id": ownerOrganizationId}
    };

    bodyMap.addAll(socketInfo.toJson());

    bodyMap.addAll({
      "episode_of_care_reference": {"id": episodeOfCare.entityId}
    });

    String body = jsonEncode(bodyMap);

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('post', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request));

      responseJson = _returnResponse(response);

      _logger.d('successfully added socket info');

      socketInfo.entityId = responseJson['_id'];
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then((value) =>
            addSocketInfo(
                episodeOfCare: episodeOfCare,
                socketInfo: socketInfo,
                isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editSocketInfo(
      {required SocketInfo socketInfo, bool isRetry = false}) async {
    _logger.d('');

    String url = '$_endpoint$_genericEntityApi/${socketInfo.entityId}';

    String body = jsonEncode(socketInfo.toJson());

    Map<String, String> headers = {
      ...jsonRequestHeaders,
      ...requestHeadersAuthorization
    };

    http.Request request = http.Request('patch', Uri.parse(url));
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response =
          await http.Response.fromStream(await client.send(request));

      _returnResponse(response);

      _logger.d('successfully edited socket info');
    } on ExpiredTokenException {
      if (isRetry) {
        rethrow;
      } else {
        _logger.d('retry');

        await refreshTokens();
        return Future.delayed(const Duration(seconds: 2)).then(
            (value) => editSocketInfo(socketInfo: socketInfo, isRetry: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPatientWithDetails(Patient patient) async {
    _logger.d('');

    FutureGroup futureGroup = FutureGroup();

    // POST domain weight distribution.
    futureGroup.add(addDomainWeightDistribution(
            domainWeightDist: patient.domainWeightDist,
            patientName: patient.initial)
        .then((value) {
      patient.domainWeightDist.entityId = value;
      patient.domainWeightDistJson =
          jsonEncode(patient.domainWeightDist.toJson());
    }));

    // POST condition.
    futureGroup
        .add(addCondition(patient.condition!, patient.initial).then((value) {
      patient.condition!.entityId = value;
      patient.conditionJson = jsonEncode(patient.condition!.toJson());
    }));

    // POST k-level.
    futureGroup.add(
      addKLevel(kLevel: patient.kLevel!, patientName: patient.initial)
          .then((value) {
        patient.kLevel!.entityId = value;
        patient.kLevelJson = jsonEncode(patient.kLevel!.toJson());
      }),
    );

    futureGroup.close();

    try {
      await futureGroup.future;

      await addPatient(patient);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addEncounterWithDetails(
      Encounter encounter, Patient patient) async {
    _logger.d('');

    FutureGroup futureGroup = FutureGroup();

    // Add amputation if amputation.entityId is null
    for (int i = 0; i < patient.amputations.length; i++) {
      Amputation amputation = patient.amputations[i];
      if (amputation.entityId == null) {
        futureGroup.add(addAmputation(amputation, patient: patient));
      }
    }

    //Add pre/post episode
    if (encounter.prePostEpisodeOfCare != null) {
      futureGroup.add(
          addPrePost(prePostEpisodeOfCare: encounter.prePostEpisodeOfCare!));
    }

    //Add episode of care
    if (encounter.episodeOfCare != null) {
      futureGroup.add(addEpisodeOfCare(encounter.episodeOfCare!));
    }

    // Add outcome measures
    futureGroup.add(_addOutcomeMeasures(encounter.outcomeMeasures!, patient));

    futureGroup.close();

    try {
      await futureGroup.future;

      await addEncounter(encounter, patient);
    } on TimeoutException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _returnResponse(http.Response response) {
    //TODO: Jiyun - convert response.request into CRC-16 instead of httpRequestCode
    int httpRequestCode = -1;

    switch (response.statusCode) {
      case >= 200 && < 300:
        if (response.body.isNotEmpty) {
          var responseJson = json.decode(response.body.toString());
          return responseJson;
        } else {
          return {};
        }
      case 401:
        if (httpRequestCode != 89) {
          // any calls after logged in
          throw ExpiredTokenException(response);
        } else {
          // TODO: Jiyun - loginWithCredential (89)
          throw BadRequestException(response);
        }
      case 403:
        throw UnauthorisedException(response);
      case >= 400 && < 500:
        throw BadRequestException(response);
      case >= 500:
        throw ServerErrorException(response);
      default:
        throw BadRequestException(response);
    }
  }
}

class AppException implements Exception {
  final String? _message;
  final String? _prefix;

  String get message => _message == null ? '' : _message!;

  AppException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class BadRequestException extends AppException {
  http.Response response;

  BadRequestException(this.response)
      : super(response.body.toString(),
            "${response.statusCode}-Invalid Request: ");
}

class ExpiredTokenException extends AppException {
  http.Response response;

  ExpiredTokenException(this.response)
      : super(
            response.body.toString(), "${response.statusCode}-Expired Token: ");
}

class UnauthorisedException extends AppException {
  http.Response response;

  UnauthorisedException(this.response)
      : super(
            response.body.toString(), "${response.statusCode}-Unauthorised: ");
}

class ServerErrorException extends AppException {
  http.Response response;

  ServerErrorException(this.response)
      : super(
            response.body.toString(), "${response.statusCode}-Server Error: ");
}
