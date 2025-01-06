import 'dart:async';
import 'dart:convert';

import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/model/amputation.dart';
import 'package:biot/model/condition.dart';
import 'package:biot/model/domain_weight_distribution.dart';
import 'package:biot/model/encounter.dart';
import 'package:biot/model/episode_of_care.dart';
import 'package:biot/model/kLevel.dart';
import 'package:biot/model/outcome_measures/outcome_measure.dart';
import 'package:biot/model/patient.dart';
import 'package:biot/model/pre_post_episode_of_care.dart';
import 'package:biot/model/socket_info.dart';
import 'package:biot/services/cloud_service.dart';
import 'package:biot/services/logger_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biot/app/app.locator.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

Future<void> main() async {
  late var mockLoggerService;
  late BiotService service;
  String anyDate = '2024-04-10';
  String anyString = 'any';
  DateTime anyDateTime = DateTime.now();
  int anyNum = 0;

  group('BiotServiceTest -', () {
    setUp(() async {
      registerServices();

      mockLoggerService = locator<LoggerService>();
      when(mockLoggerService.getLogger(any)).thenReturn(
          Logger(printer: SimplePrinter(), output: ConsoleOutput()));
      service = BiotService(loggerService: mockLoggerService);
      service.client = MockClient();

      // POST refresh token is always successful
      when(service.client.post(
              Uri.parse(
                  'https://api.dev.orthocare.biot-med.com/ums/v2/users/token/refresh'),
              headers: anyNamed('headers'),
              body: anyNamed('body')))
          .thenAnswer((_) async {
        return http.Response(
            json.encode({
              'accessJwt': {'token': anyString},
              'refreshJwt': {'token': anyString}
            }),
            200);
      });
    });
    tearDown(() => locator.reset());

    group('loginWithCredentials -', () {
      test('Returns normally if the http POST call completes successfully',
          () async {
        when((service.client as MockClient).post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(
                json.encode({
                  'ownerOrganizationId': anyString,
                  'accessJwt': {
                    'token': anyString,
                    'expiration': DateTime.now().toIso8601String()
                  },
                  'refreshJwt': {'token': anyString}
                }),
                200));

        expect(
            () => service.loginWithCredentials('id', 'pwd'), returnsNormally);
      });

      test('Throws Exceptions', () async {
        when((service.client as MockClient).post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(
                json.encode({
                  'ownerOrganizationId': anyString,
                  'accessJwt': {
                    'token': anyString,
                    'expiration': DateTime.now().toIso8601String()
                  },
                  'refreshJwt': {'token': anyString}
                }),
                403));

        expect(() => service.loginWithCredentials('id', 'pwd'),
            throwsA(isA<UnauthorisedException>()));

        when((service.client as MockClient).post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(
                json.encode({
                  'ownerOrganizationId': anyString,
                  'accessJwt': {
                    'token': anyString,
                    'expiration': DateTime.now().toIso8601String()
                  },
                  'refreshJwt': {'token': anyString}
                }),
                400));

        expect(() => service.loginWithCredentials('id', 'pwd'),
            throwsA(isA<BadRequestException>()));

        when((service.client as MockClient).post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(
                json.encode({
                  'ownerOrganizationId': anyString,
                  'accessJwt': {
                    'token': anyString,
                    'expiration': DateTime.now().toIso8601String()
                  },
                  'refreshJwt': {'token': anyString}
                }),
                500));

        expect(() => service.loginWithCredentials('id', 'pwd'),
            throwsA(isA<ServerErrorException>()));
      });
    });

    group('logOut -', () {
      setUp(() => service.refreshToken = anyString);

      test('Returns normally if the http call completes successfully',
          () async {
        when((service.client as MockClient).post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(json.encode({}), 200));

        expect(() => service.logOut(), returnsNormally);
      });

      test('Throws BadRequestException', () async {
        when((service.client as MockClient).post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(json.encode({}), 400));

        expect(() => service.logOut(), throwsA(isA<BadRequestException>()));
      });
    });

    group('Requires token', () {
      setUp(() {
        service.token = anyString;
        service.refreshToken = anyString;
        service.ownerOrganizationId = anyString;
      });

      group('refreshTokens -', () {
        setUp(() => service.refreshToken = anyString);

        test('Returns normally if the http call completes successfully',
            () async {
          when((service.client as MockClient).post(any,
                  headers: anyNamed('headers'), body: anyNamed('body')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'accessJwt': {
                      'token': anyString,
                    },
                    'refreshJwt': {'token': anyString}
                  }),
                  200));

          expect(() => service.refreshTokens(), returnsNormally);
        });

        test('Throws Exceptions', () async {
          when((service.client as MockClient).post(any,
                  headers: anyNamed('headers'), body: anyNamed('body')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'accessJwt': {
                      'token': anyString,
                    },
                    'refreshJwt': {'token': anyString}
                  }),
                  403));

          expect(() => service.refreshTokens(),
              throwsA(isA<UnauthorisedException>()));

          when((service.client as MockClient).post(any,
                  headers: anyNamed('headers'), body: anyNamed('body')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'accessJwt': {
                      'token': anyString,
                    },
                    'refreshJwt': {'token': anyString}
                  }),
                  400));

          expect(() => service.refreshTokens(),
              throwsA(isA<BadRequestException>()));

          when((service.client as MockClient).post(any,
                  headers: anyNamed('headers'), body: anyNamed('body')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'accessJwt': {
                      'token': anyString,
                    },
                    'refreshJwt': {'token': anyString}
                  }),
                  500));

          expect(() => service.refreshTokens(),
              throwsA(isA<ServerErrorException>()));
        });
      });

      group('Requires Patient', () {
        late Patient patient;

        setUp(() {
          patient = MockPatient();
          DomainWeightDistribution domainWeightDist =
              MockDomainWeightDistribution();
          Condition condition = MockCondition();
          KLevel kLevel = MockKLevel();
          when(patient.firstName).thenReturn(anyString);
          when(patient.lastName).thenReturn(anyString);
          when(patient.id).thenReturn(anyString);
          when(patient.entityId).thenReturn(anyString);
          when(patient.domainWeightDist).thenReturn(domainWeightDist);
          when(domainWeightDist.entityId).thenReturn(anyString);
          when(patient.condition).thenReturn(condition);
          when(condition.entityId).thenReturn(anyString);
          when(patient.kLevel).thenReturn(kLevel);
          when(kLevel.entityId).thenReturn(anyString);
          when(patient.toJson()).thenReturn({});
          when(patient.dob).thenReturn(anyDateTime);
          when(patient.sexAtBirthIndex).thenReturn(anyNum);
          when(patient.initial).thenReturn(anyString);
          when(patient.amputations).thenReturn([]);
        });

        group('addPatient', () {
          setUp(() {
            // Return 200 from all other linked POST api calls for generic entity.
            when((service.client as MockClient).send(http.Request(
                    'post',
                    Uri.parse(
                        'https://api.dev.orthocare.biot-med.com/generic-entity/v1/generic-entities'))))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([utf8.encode(json.encode({}))]), 201);
            });
          });

          test('Returns normally if the http call completes successfully',
              () async {
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json
                        .encode({'_id': anyString, '_creationTime': anyDate}))
                  ]),
                  201);
            });

            expect(() => service.addPatient(patient), returnsNormally);
          });

          test('Throws Exceptions', () async {
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json
                        .encode({'_id': anyString, '_creationTime': anyDate}))
                  ]),
                  400);
            });

            expect(() => service.addPatient(patient),
                throwsA(isA<BadRequestException>()));

            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json
                        .encode({'_id': anyString, '_creationTime': anyDate}))
                  ]),
                  401);
            });

            expect(() => service.addPatient(patient, isRetry: true),
                throwsA(isA<ExpiredTokenException>()));

            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json
                        .encode({'_id': anyString, '_creationTime': anyDate}))
                  ]),
                  500);
            });

            expect(() => service.addPatient(patient),
                throwsA(isA<ServerErrorException>()));

            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json
                        .encode({'_id': anyString, '_creationTime': anyDate}))
                  ]),
                  401);
            });

            expect(() => service.addPatient(patient),
                throwsA(isA<ExpiredTokenException>()));
          });
        });

        group('editPatient', () {
          test('Returns normally if the http call completes successfully',
              () async {
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([utf8.encode(json.encode({}))]), 201);
            });

            expect(() => service.editPatient(patient), returnsNormally);
          });

          test('Throws Exceptions', () async {
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([utf8.encode(json.encode({}))]), 400);
            });

            expect(() => service.editPatient(patient),
                throwsA(isA<BadRequestException>()));

            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([utf8.encode(json.encode({}))]), 401);
            });

            expect(() => service.editPatient(patient, isRetry: true),
                throwsA(isA<ExpiredTokenException>()));

            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([utf8.encode(json.encode({}))]), 500);
            });

            expect(() => service.editPatient(patient),
                throwsA(isA<ServerErrorException>()));

            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([utf8.encode(json.encode({}))]), 401);
            });

            expect(() => service.editPatient(patient),
                throwsA(isA<ExpiredTokenException>()));
          });
        });

        group('Requires outcomeMeasure', () {
          late OutcomeMeasure outcomeMeasure;

          setUp(() {
            outcomeMeasure = MockOutcomeMeasure();
            when(outcomeMeasure.toJson(
                    service.ownerOrganizationId, patient, anyNum))
                .thenReturn({});
            when(outcomeMeasure.id).thenReturn(anyString);
            when(outcomeMeasure.entityId).thenReturn(anyString);
          });

          group('addOutcomeMeasure', () {
            test('Returns normally if the http call completes successfully',
                () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    201);
              });

              expect(
                  () => service.addOutcomeMeasure(
                      anyNum, outcomeMeasure, patient),
                  returnsNormally);
            });

            test('Throws Exceptions', () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    400);
              });

              expect(
                  () => service.addOutcomeMeasure(
                      anyNum, outcomeMeasure, patient),
                  throwsA(isA<BadRequestException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    401);
              });

              expect(
                  () => service.addOutcomeMeasure(
                      anyNum, outcomeMeasure, patient,
                      isRetry: true),
                  throwsA(isA<ExpiredTokenException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    500);
              });

              expect(
                  () => service.addOutcomeMeasure(
                      anyNum, outcomeMeasure, patient),
                  throwsA(isA<ServerErrorException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    401);
              });

              expect(
                  () => service.addOutcomeMeasure(
                      anyNum, outcomeMeasure, patient),
                  throwsA(isA<ExpiredTokenException>()));
            });
          });
        });

        group('Required amputation', () {
          late Amputation amputation;

          setUp(() {
            amputation = MockAmputation();
            when(amputation.toJson()).thenReturn({});
            when(amputation.entityId).thenReturn(anyString);
          });

          group('addAmputation', () {
            test('Returns normally if the http call completes successfully',
                () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    201);
              });

              expect(() => service.addAmputation(amputation, patient: patient),
                  returnsNormally);
            });

            test('Throws Exceptions - addAmputation', () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    400);
              });

              expect(() => service.addAmputation(amputation, patient: patient),
                  throwsA(isA<BadRequestException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    401);
              });

              expect(
                  () => service.addAmputation(amputation,
                      patient: patient, isRetry: true),
                  throwsA(isA<ExpiredTokenException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    500);
              });

              expect(() => service.addAmputation(amputation, patient: patient),
                  throwsA(isA<ServerErrorException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                // Create a completer to handle the delayed response
                Completer<http.StreamedResponse> completer = Completer();

                // Simulate API response after 10 seconds
                Future.delayed(const Duration(seconds: 10), () {
                  // Complete with a timeout error
                  completer.completeError(
                      TimeoutException('API call timed out after 10 seconds'));
                });

                return completer.future;
              });

              expect(() => service.addAmputation(amputation, patient: patient),
                  throwsA(isA<TimeoutException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    401);
              });

              expect(() => service.addAmputation(amputation, patient: patient),
                  throwsA(isA<ExpiredTokenException>()));
            });
          });

          group('editAmputation', () {
            test('Returns normally if the http call completes successfully',
                () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    201);
              });

              expect(() => service.editAmputation(amputation), returnsNormally);
            });

            test('Throws Exceptions', () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    400);
              });

              expect(() => service.editAmputation(amputation),
                  throwsA(isA<BadRequestException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    401);
              });

              expect(() => service.editAmputation(amputation, isRetry: true),
                  throwsA(isA<ExpiredTokenException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    500);
              });

              expect(() => service.editAmputation(amputation),
                  throwsA(isA<ServerErrorException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    401);
              });

              expect(() => service.editAmputation(amputation),
                  throwsA(isA<ExpiredTokenException>()));
            });
          });
        });

        group('Requires encounter', () {
          late Encounter encounter;
          late PrePostEpisodeOfCare prePostEpisodeOfCare;
          late EpisodeOfCare episodeOfCare;

          setUp(() {
            encounter = MockEncounter();
            prePostEpisodeOfCare = MockPrePostEpisodeOfCare();
            episodeOfCare = MockEpisodeOfCare();
            when(encounter.toJson(patient)).thenReturn({});
            when(encounter.entityId).thenReturn(anyString);
            when(encounter.submitCode).thenReturn(Submit.initial);
            // when(encounter.submitCode).thenReturn(Submit.finish);
            when(encounter.prefix).thenReturn(EpisodePrefix.pre);
            when(encounter.prePostEpisodeOfCare)
                .thenReturn(prePostEpisodeOfCare);
            when(encounter.episodeOfCare).thenReturn(episodeOfCare);
            when(encounter.outcomeMeasures).thenReturn([]);
            when(prePostEpisodeOfCare.entityId).thenReturn(anyString);
            when(prePostEpisodeOfCare.toJson()).thenReturn({});
            when(episodeOfCare.entityId).thenReturn(anyString);
            when(episodeOfCare.toJson()).thenReturn({});
            when(episodeOfCare.socketInfoList).thenReturn([]);
          });

          group('addEncounterWithDetails', () {
            test('Returns normally without throwing any exceptions', () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 201);
              });

              expect(() => service.addEncounterWithDetails(encounter, patient),
                  returnsNormally);
            });

            test('Throws Exceptions', () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    400);
              });

              expect(() => service.addEncounterWithDetails(encounter, patient),
                  throwsA(isA<BadRequestException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    500);
              });

              expect(() => service.addEncounterWithDetails(encounter, patient),
                  throwsA(isA<ServerErrorException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    401);
              });

              expect(() => service.addEncounterWithDetails(encounter, patient),
                  throwsA(isA<ExpiredTokenException>()));
            });
          });

          group('addEncounter', () {
            setUp(() {
              // Return 201 from all other linked GET api calls for generic entity.
              when((service.client as MockClient)
                      .get(any, headers: anyNamed('headers')))
                  .thenAnswer((_) async {
                return http.Response(json.encode({'data': []}), 201);
              });
            });

            test('Returns normally if the http call completes successfully',
                () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    201);
              });

              expect(() => service.addEncounter(encounter, patient),
                  returnsNormally);
            });

            test('Throws Exceptions - addEncounter', () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    400);
              });

              expect(() => service.addEncounter(encounter, patient),
                  throwsA(isA<BadRequestException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    401);
              });

              expect(
                  () => service.addEncounter(encounter, patient, isRetry: true),
                  throwsA(isA<ExpiredTokenException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    500);
              });

              expect(() => service.addEncounter(encounter, patient),
                  throwsA(isA<ServerErrorException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                // Create a completer to handle the delayed response
                Completer<http.StreamedResponse> completer = Completer();

                // Simulate API response after 10 seconds
                Future.delayed(const Duration(seconds: 10), () {
                  // Complete with a timeout error
                  completer.completeError(
                      TimeoutException('API call timed out after 10 seconds'));
                });

                return completer.future;
              });

              expect(() => service.addEncounter(encounter, patient),
                  throwsA(isA<TimeoutException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    401);
              });

              expect(() => service.addEncounter(encounter, patient),
                  throwsA(isA<ExpiredTokenException>()));
            });
          });

          group('editEncounter', () {
            test('Returns normally if the http call completes successfully',
                () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 201);
              });

              expect(() => service.editEncounter(encounter), returnsNormally);
            });

            test('Throws Exceptions', () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 400);
              });

              expect(() => service.editEncounter(encounter),
                  throwsA(isA<BadRequestException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 401);
              });

              expect(() => service.editEncounter(encounter, isRetry: true),
                  throwsA(isA<ExpiredTokenException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 500);
              });

              expect(() => service.editEncounter(encounter),
                  throwsA(isA<ServerErrorException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 401);
              });

              expect(() => service.editEncounter(encounter),
                  throwsA(isA<ExpiredTokenException>()));
            });
          });

          group('editEncounterWithPostEncounterId', () {
            setUp(() {
              final preEncounterMock = MockEncounter();
              when(preEncounterMock.entityId).thenReturn(anyString);
              when(encounter.preEncounter).thenReturn(preEncounterMock);
            });

            test('Returns normally if the http call completes successfully',
                () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 201);
              });

              expect(() => service.editEncounterWithPostEncounterId(encounter),
                  returnsNormally);
            });

            test('Throws Exceptions', () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 400);
              });

              expect(() => service.editEncounterWithPostEncounterId(encounter),
                  throwsA(isA<BadRequestException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 401);
              });

              expect(
                  () => service.editEncounterWithPostEncounterId(encounter,
                      isRetry: true),
                  throwsA(isA<ExpiredTokenException>()));
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 500);
              });

              expect(() => service.editEncounterWithPostEncounterId(encounter),
                  throwsA(isA<ServerErrorException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 401);
              });

              expect(() => service.editEncounterWithPostEncounterId(encounter),
                  throwsA(isA<ExpiredTokenException>()));
            });
          });

          group('Requires EpisodeOfCare', () {
            group('Requires socketInfo', () {
              late SocketInfo socketInfo;

              setUp(() {
                socketInfo = MockSocketInfo();
                when(socketInfo.toJson()).thenReturn({});
                when(socketInfo.entityId).thenReturn(anyString);
              });

              group('addSocketInfo', () {
                test('Returns normally if the http call completes successfully',
                    () async {
                  when((service.client as MockClient).send(any))
                      .thenAnswer((_) async {
                    return http.StreamedResponse(
                        Stream.fromIterable([
                          utf8.encode(json.encode({'_id': anyString}))
                        ]),
                        201);
                  });

                  expect(
                      () => service.addSocketInfo(
                          episodeOfCare: episodeOfCare, socketInfo: socketInfo),
                      returnsNormally);
                });

                test('Throws Exceptions', () async {
                  when((service.client as MockClient).send(any))
                      .thenAnswer((_) async {
                    return http.StreamedResponse(
                        Stream.fromIterable([
                          utf8.encode(json.encode({'_id': anyString}))
                        ]),
                        400);
                  });

                  expect(
                      () => service.addSocketInfo(
                          episodeOfCare: episodeOfCare, socketInfo: socketInfo),
                      throwsA(isA<BadRequestException>()));

                  when((service.client as MockClient).send(any))
                      .thenAnswer((_) async {
                    return http.StreamedResponse(
                        Stream.fromIterable([
                          utf8.encode(json.encode({'_id': anyString}))
                        ]),
                        401);
                  });

                  expect(
                      () => service.addSocketInfo(
                          episodeOfCare: episodeOfCare,
                          socketInfo: socketInfo,
                          isRetry: true),
                      throwsA(isA<ExpiredTokenException>()));
                  when((service.client as MockClient).send(any))
                      .thenAnswer((_) async {
                    return http.StreamedResponse(
                        Stream.fromIterable([
                          utf8.encode(json.encode({'_id': anyString}))
                        ]),
                        500);
                  });

                  expect(
                      () => service.addSocketInfo(
                          episodeOfCare: episodeOfCare, socketInfo: socketInfo),
                      throwsA(isA<ServerErrorException>()));

                  when((service.client as MockClient).send(any))
                      .thenAnswer((_) async {
                    return http.StreamedResponse(
                        Stream.fromIterable([
                          utf8.encode(json.encode({'_id': anyString}))
                        ]),
                        401);
                  });

                  expect(
                      () => service.addSocketInfo(
                          episodeOfCare: episodeOfCare, socketInfo: socketInfo),
                      throwsA(isA<ExpiredTokenException>()));
                });
              });

              group('editSocketInfo', () {
                test('Returns normally if the http call completes successfully',
                    () async {
                  when((service.client as MockClient).send(any))
                      .thenAnswer((_) async {
                    return http.StreamedResponse(
                        Stream.fromIterable([utf8.encode(json.encode({}))]),
                        201);
                  });

                  expect(() => service.editSocketInfo(socketInfo: socketInfo),
                      returnsNormally);
                });

                test('Throws Exceptions', () async {
                  when((service.client as MockClient).send(any))
                      .thenAnswer((_) async {
                    return http.StreamedResponse(
                        Stream.fromIterable([utf8.encode(json.encode({}))]),
                        400);
                  });

                  expect(() => service.editSocketInfo(socketInfo: socketInfo),
                      throwsA(isA<BadRequestException>()));

                  when((service.client as MockClient).send(any))
                      .thenAnswer((_) async {
                    return http.StreamedResponse(
                        Stream.fromIterable([utf8.encode(json.encode({}))]),
                        401);
                  });

                  expect(
                      () => service.editSocketInfo(
                          socketInfo: socketInfo, isRetry: true),
                      throwsA(isA<ExpiredTokenException>()));
                  when((service.client as MockClient).send(any))
                      .thenAnswer((_) async {
                    return http.StreamedResponse(
                        Stream.fromIterable([
                          utf8.encode(json.encode({'_id': anyString}))
                        ]),
                        500);
                  });

                  expect(() => service.editSocketInfo(socketInfo: socketInfo),
                      throwsA(isA<ServerErrorException>()));

                  when((service.client as MockClient).send(any))
                      .thenAnswer((_) async {
                    return http.StreamedResponse(
                        Stream.fromIterable([
                          utf8.encode(json.encode({'_id': anyString}))
                        ]),
                        401);
                  });

                  expect(() => service.editSocketInfo(socketInfo: socketInfo),
                      throwsA(isA<ExpiredTokenException>()));
                });
              });
            });

            group('addEpisodeOfCare', () {
              test('Returns normally if the http call completes successfully',
                  () async {
                when((service.client as MockClient).send(any))
                    .thenAnswer((_) async {
                  return http.StreamedResponse(
                      Stream.fromIterable([
                        utf8.encode(json.encode({'_id': anyString}))
                      ]),
                      201);
                });

                expect(() => service.addEpisodeOfCare(episodeOfCare),
                    returnsNormally);
              });

              test('Throws Exceptions - addEpisodeOfCare', () async {
                when((service.client as MockClient).send(any))
                    .thenAnswer((_) async {
                  return http.StreamedResponse(
                      Stream.fromIterable([
                        utf8.encode(json.encode({'_id': anyString}))
                      ]),
                      400);
                });

                expect(() => service.addEpisodeOfCare(episodeOfCare),
                    throwsA(isA<BadRequestException>()));

                when((service.client as MockClient).send(any))
                    .thenAnswer((_) async {
                  return http.StreamedResponse(
                      Stream.fromIterable([
                        utf8.encode(json.encode({'_id': anyString}))
                      ]),
                      401);
                });

                expect(
                    () =>
                        service.addEpisodeOfCare(episodeOfCare, isRetry: true),
                    throwsA(isA<ExpiredTokenException>()));
                when((service.client as MockClient).send(any))
                    .thenAnswer((_) async {
                  return http.StreamedResponse(
                      Stream.fromIterable([
                        utf8.encode(json.encode({'_id': anyString}))
                      ]),
                      500);
                });

                expect(() => service.addEpisodeOfCare(episodeOfCare),
                    throwsA(isA<ServerErrorException>()));

                when((service.client as MockClient).send(any))
                    .thenAnswer((_) async {
                  // Create a completer to handle the delayed response
                  Completer<http.StreamedResponse> completer = Completer();

                  // Simulate API response after 10 seconds
                  Future.delayed(const Duration(seconds: 10), () {
                    // Complete with a timeout error
                    completer.completeError(TimeoutException(
                        'API call timed out after 10 seconds'));
                  });

                  return completer.future;
                });

                expect(() => service.addEpisodeOfCare(episodeOfCare),
                    throwsA(isA<TimeoutException>()));

                when((service.client as MockClient).send(any))
                    .thenAnswer((_) async {
                  return http.StreamedResponse(
                      Stream.fromIterable([
                        utf8.encode(json.encode({'_id': anyString}))
                      ]),
                      401);
                });

                expect(() => service.addEpisodeOfCare(episodeOfCare),
                    throwsA(isA<ExpiredTokenException>()));
              });
            });

            group('editEpisodeOfCare', () {
              test('Returns normally if the http call completes successfully',
                  () async {
                when((service.client as MockClient).send(any))
                    .thenAnswer((_) async {
                  return http.StreamedResponse(
                      Stream.fromIterable([utf8.encode(json.encode({}))]), 201);
                });

                expect(
                    () =>
                        service.editEpisodeOfCare(episodeOfCare: episodeOfCare),
                    returnsNormally);
              });

              test('Throws Exceptions', () async {
                when((service.client as MockClient).send(any))
                    .thenAnswer((_) async {
                  return http.StreamedResponse(
                      Stream.fromIterable([utf8.encode(json.encode({}))]), 400);
                });

                expect(
                    () =>
                        service.editEpisodeOfCare(episodeOfCare: episodeOfCare),
                    throwsA(isA<BadRequestException>()));

                when((service.client as MockClient).send(any))
                    .thenAnswer((_) async {
                  return http.StreamedResponse(
                      Stream.fromIterable([utf8.encode(json.encode({}))]), 401);
                });

                expect(
                    () => service.editEpisodeOfCare(
                        episodeOfCare: episodeOfCare, isRetry: true),
                    throwsA(isA<ExpiredTokenException>()));
                when((service.client as MockClient).send(any))
                    .thenAnswer((_) async {
                  return http.StreamedResponse(
                      Stream.fromIterable([utf8.encode(json.encode({}))]), 500);
                });

                expect(
                    () =>
                        service.editEpisodeOfCare(episodeOfCare: episodeOfCare),
                    throwsA(isA<ServerErrorException>()));

                when((service.client as MockClient).send(any))
                    .thenAnswer((_) async {
                  return http.StreamedResponse(
                      Stream.fromIterable([utf8.encode(json.encode({}))]), 401);
                });

                expect(
                    () =>
                        service.editEpisodeOfCare(episodeOfCare: episodeOfCare),
                    throwsA(isA<ExpiredTokenException>()));
              });
            });
          });

          group('addPrePost', () {
            test('Returns normally if the http call completes successfully',
                () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    201);
              });

              expect(
                  () => service.addPrePost(
                      prePostEpisodeOfCare: prePostEpisodeOfCare),
                  returnsNormally);
            });

            test('Throws Exceptions - addPrePost', () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    400);
              });

              expect(
                  () => service.addPrePost(
                      prePostEpisodeOfCare: prePostEpisodeOfCare),
                  throwsA(isA<BadRequestException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    401);
              });

              expect(
                  () => service.addPrePost(
                      prePostEpisodeOfCare: prePostEpisodeOfCare,
                      isRetry: true),
                  throwsA(isA<ExpiredTokenException>()));
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    500);
              });

              expect(
                  () => service.addPrePost(
                      prePostEpisodeOfCare: prePostEpisodeOfCare),
                  throwsA(isA<ServerErrorException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                // Create a completer to handle the delayed response
                Completer<http.StreamedResponse> completer = Completer();

                // Simulate API response after 10 seconds
                Future.delayed(const Duration(seconds: 10), () {
                  // Complete with a timeout error
                  completer.completeError(
                      TimeoutException('API call timed out after 10 seconds'));
                });

                return completer.future;
              });

              expect(
                  () => service.addPrePost(
                      prePostEpisodeOfCare: prePostEpisodeOfCare),
                  throwsA(isA<TimeoutException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([
                      utf8.encode(json.encode({'_id': anyString}))
                    ]),
                    401);
              });

              expect(
                  () => service.addPrePost(
                      prePostEpisodeOfCare: prePostEpisodeOfCare),
                  throwsA(isA<ExpiredTokenException>()));
            });
          });

          group('editPrePost', () {
            test('Returns normally if the http call completes successfully',
                () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 201);
              });

              expect(
                  () => service.editPrePost(
                      prePostEpisodeOfCare: prePostEpisodeOfCare),
                  returnsNormally);
            });

            test('Throws Exceptions', () async {
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 400);
              });

              expect(
                  () => service.editPrePost(
                      prePostEpisodeOfCare: prePostEpisodeOfCare),
                  throwsA(isA<BadRequestException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 401);
              });

              expect(
                  () => service.editPrePost(
                      prePostEpisodeOfCare: prePostEpisodeOfCare,
                      isRetry: true),
                  throwsA(isA<ExpiredTokenException>()));
              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 500);
              });

              expect(
                  () => service.editPrePost(
                      prePostEpisodeOfCare: prePostEpisodeOfCare),
                  throwsA(isA<ServerErrorException>()));

              when((service.client as MockClient).send(any))
                  .thenAnswer((_) async {
                return http.StreamedResponse(
                    Stream.fromIterable([utf8.encode(json.encode({}))]), 401);
              });

              expect(
                  () => service.editPrePost(
                      prePostEpisodeOfCare: prePostEpisodeOfCare),
                  throwsA(isA<ExpiredTokenException>()));
            });
          });
        });

        group('addDomainWeightDistribution', () {
          late DomainWeightDistribution domainWeightDistribution;

          setUp(() {
            domainWeightDistribution = MockDomainWeightDistribution();
            when(domainWeightDistribution.comfort).thenReturn(anyNum);
            when(domainWeightDistribution.function).thenReturn(anyNum);
            when(domainWeightDistribution.satisfaction).thenReturn(anyNum);
            when(domainWeightDistribution.goals).thenReturn(anyNum);
            when(domainWeightDistribution.community).thenReturn(anyNum);
            when(domainWeightDistribution.toJson()).thenReturn({});
          });

          test('Returns normally if the http call completes successfully',
              () async {
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json
                        .encode({'_id': anyString, '_creationTime': anyDate}))
                  ]),
                  201);
            });

            expect(
                () => service.addDomainWeightDistribution(
                    patientName: anyString,
                    domainWeightDist: domainWeightDistribution),
                returnsNormally);
          });

          test('Throws Exceptions', () async {
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json
                        .encode({'_id': anyString, '_creationTime': anyDate}))
                  ]),
                  400);
            });

            expect(
                () => service.addDomainWeightDistribution(
                    patientName: anyString,
                    domainWeightDist: domainWeightDistribution),
                throwsA(isA<BadRequestException>()));

            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json
                        .encode({'_id': anyString, '_creationTime': anyDate}))
                  ]),
                  401);
            });

            expect(
                () => service.addDomainWeightDistribution(
                    patientName: anyString,
                    domainWeightDist: domainWeightDistribution,
                    isRetry: true),
                throwsA(isA<ExpiredTokenException>()));
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json
                        .encode({'_id': anyString, '_creationTime': anyDate}))
                  ]),
                  500);
            });

            expect(
                () => service.addDomainWeightDistribution(
                    patientName: anyString,
                    domainWeightDist: domainWeightDistribution),
                throwsA(isA<ServerErrorException>()));

            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json
                        .encode({'_id': anyString, '_creationTime': anyDate}))
                  ]),
                  401);
            });

            expect(
                () => service.addDomainWeightDistribution(
                    patientName: anyString,
                    domainWeightDist: domainWeightDistribution),
                throwsA(isA<ExpiredTokenException>()));
          });
        });

        group('addKLevel', () {
          late KLevel kLevel;

          setUp(() {
            kLevel = MockKLevel();
            when(kLevel.kLevelValue).thenReturn(anyNum);
            when(kLevel.toJson()).thenReturn({});
          });

          test('Returns normally if the http call completes successfully',
              () async {
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json.encode({'_id': anyString}))
                  ]),
                  201);
            });

            expect(
                () => service.addKLevel(patientName: anyString, kLevel: kLevel),
                returnsNormally);
          });

          test('Throws Exceptions', () async {
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json.encode({'_id': anyString}))
                  ]),
                  400);
            });

            expect(
                () => service.addKLevel(patientName: anyString, kLevel: kLevel),
                throwsA(isA<BadRequestException>()));

            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json.encode({'_id': anyString}))
                  ]),
                  401);
            });

            expect(
                () => service.addKLevel(
                    patientName: anyString, kLevel: kLevel, isRetry: true),
                throwsA(isA<ExpiredTokenException>()));
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json.encode({'_id': anyString}))
                  ]),
                  500);
            });

            expect(
                () => service.addKLevel(patientName: anyString, kLevel: kLevel),
                throwsA(isA<ServerErrorException>()));

            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json.encode({'_id': anyString}))
                  ]),
                  401);
            });

            expect(
                () => service.addKLevel(patientName: anyString, kLevel: kLevel),
                throwsA(isA<ExpiredTokenException>()));
          });
        });

        group('addCondition', () {
          late Condition condition;

          setUp(() {
            condition = MockCondition();
            when(condition.conditionsList).thenReturn([]);
            when(condition.toJson()).thenReturn({});
          });

          test('Returns normally if the http call completes successfully',
              () async {
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json.encode({'_id': anyString}))
                  ]),
                  201);
            });

            expect(() => service.addCondition(condition, anyString),
                returnsNormally);
          });

          test('Throws Exceptions', () async {
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json.encode({'_id': anyString}))
                  ]),
                  400);
            });

            expect(() => service.addCondition(condition, anyString),
                throwsA(isA<BadRequestException>()));

            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json.encode({'_id': anyString}))
                  ]),
                  401);
            });

            expect(
                () => service.addCondition(condition, anyString, isRetry: true),
                throwsA(isA<ExpiredTokenException>()));
            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json.encode({'_id': anyString}))
                  ]),
                  500);
            });

            expect(() => service.addCondition(condition, anyString),
                throwsA(isA<ServerErrorException>()));

            when((service.client as MockClient).send(any))
                .thenAnswer((_) async {
              return http.StreamedResponse(
                  Stream.fromIterable([
                    utf8.encode(json.encode({'_id': anyString}))
                  ]),
                  401);
            });

            expect(() => service.addCondition(condition, anyString),
                throwsA(isA<ExpiredTokenException>()));
          });
        });
      });

      group('getOrganizationCodeById -', () {
        test('Returns normally if the http GET call completes successfully',
            () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'code': anyString,
                  }),
                  200));

          expect(() => service.getOrganizationCodeById(), returnsNormally);
        });

        test('Throws Exceptions', () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'code': anyString,
                  }),
                  401));

          expect(() => service.getOrganizationCodeById(isRetry: true),
              throwsA(isA<ExpiredTokenException>()));

          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'code': anyString,
                  }),
                  401));

          expect(() => service.getOrganizationCodeById(),
              throwsA(isA<ExpiredTokenException>()));
        });
      });

      group('getPatients', () {
        test('Returns normally if the http GET call completes successfully',
            () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 200));

          expect(() => service.getPatients(), returnsNormally);
        });

        test('Check if json data is converted to Patient successfully.',
            () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'data': [
                      {
                        'patient_id': anyString,
                        '_name': {
                          'firstName': anyString,
                          'lastName': anyString
                        },
                        '_email': anyString,
                        '_dateOfBirth': anyDate,
                        '_creationTime': anyDate
                      }
                    ]
                  }),
                  200));

          var patients = await service.getPatients();

          expect(patients, everyElement(isA<Patient>()));
        });

        test('Throws Exceptions', () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'data': [],
                  }),
                  400));

          expect(
              () => service.getPatients(), throwsA(isA<BadRequestException>()));

          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'data': [],
                  }),
                  401));

          expect(() => service.getPatients(isRetry: true),
              throwsA(isA<ExpiredTokenException>()));
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'data': [],
                  }),
                  500));

          expect(() => service.getPatients(),
              throwsA(isA<ServerErrorException>()));

          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async {
            return http.Response(
                json.encode({
                  'data': [],
                }),
                401);
          });

          expect(() => service.getPatients(),
              throwsA(isA<ExpiredTokenException>()));
        });
      });

      group('getEncounters', () {
        test('Returns normally if GET completes successfully', () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 200));

          expect(() => service.getEncounters(patientEntityId: anyString),
              returnsNormally);
        });

        test('Check if json data is converted to Encounter successfully.',
            () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 200));

          var encounters =
              await service.getEncounters(patientEntityId: anyString);
          for (var element in encounters) {
            element.domainScoresId = anyString;
          }

          expect(encounters, everyElement(isA<Encounter>()));
        });

        test('Throws Exceptions', () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 400));

          expect(() => service.getEncounters(patientEntityId: anyString),
              throwsA(isA<BadRequestException>()));

          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 401));

          expect(
              () => service.getEncounters(
                  patientEntityId: anyString, isRetry: true),
              throwsA(isA<ExpiredTokenException>()));
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 500));

          expect(() => service.getEncounters(patientEntityId: anyString),
              throwsA(isA<ServerErrorException>()));

          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 401));

          expect(() => service.getEncounters(patientEntityId: anyString),
              throwsA(isA<ExpiredTokenException>()));
        });
      });

      group('getAmputations', () {
        test('Returns normally if GET completes successfully', () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 200));

          expect(() => service.getAmputations(patientId: anyString),
              returnsNormally);
        });

        test('Check if json data is converted to Amputation successfully.',
            () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 200));

          var amputations = await service.getAmputations(patientId: anyString);

          expect(amputations, everyElement(isA<Amputation>()));
        });

        test('Throws Exceptions', () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 400));

          expect(() => service.getAmputations(patientId: anyString),
              throwsA(isA<BadRequestException>()));

          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 401));

          expect(
              () => service.getAmputations(patientId: anyString, isRetry: true),
              throwsA(isA<ExpiredTokenException>()));
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 500));

          expect(() => service.getAmputations(patientId: anyString),
              throwsA(isA<ServerErrorException>()));

          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(json.encode({'data': []}), 401));

          expect(() => service.getAmputations(patientId: anyString),
              throwsA(isA<ExpiredTokenException>()));
        });
      });

      group('GET Amputation - ', () {
        test('Returns normally if GET completes successfully',
            () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'data': [
                      {
                        'amp_date': anyDate,
                        'amp_side': anyNum,
                        'amp_cause': anyNum,
                        'amp_type': anyNum,
                        'amp_level': anyNum,
                        'ability_to_walk': anyNum
                      }
                    ]
                  }),
                  200));

          expect(() => service.getAmputation(amputationId: anyString),
              returnsNormally);
        });

        test('Check if json data is converted to Amputation successfully.',
            () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'data': [
                      {
                        'amp_date': anyDate,
                        'amp_side': anyNum,
                        'amp_cause': anyNum,
                        'amp_type': anyNum,
                        'amp_level': anyNum,
                        'ability_to_walk': anyNum
                      }
                    ]
                  }),
                  200));

          var amputation = await service.getAmputation(amputationId: anyString);

          expect(amputation, isA<Amputation>());
        });

        test('Throws Exceptions if GET failed', () async {
          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'data': [{}]
                  }),
                  400));

          expect(() => service.getAmputation(amputationId: anyString),
              throwsA(isA<BadRequestException>()));

          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'data': [{}]
                  }),
                  401));

          expect(
              () =>
                  service.getAmputation(amputationId: anyString, isRetry: true),
              throwsA(isA<ExpiredTokenException>()));

          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'data': [{}]
                  }),
                  500));

          expect(() => service.getAmputation(amputationId: anyString),
              throwsA(isA<ServerErrorException>()));

          when((service.client as MockClient)
                  .get(any, headers: anyNamed('headers')))
              .thenAnswer((_) async => http.Response(
                  json.encode({
                    'data': [{}]
                  }),
                  401));

          expect(() => service.getAmputation(amputationId: anyString),
              throwsA(isA<ExpiredTokenException>()));
        });
      });
    });
  });
}
