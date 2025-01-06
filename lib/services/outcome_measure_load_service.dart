import 'dart:convert';

import 'package:biot/model/outcome_measures/outcome_measure.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

// import 'package:oi_flutter_comet/src/app/app_constants.dart';
// import 'package:oi_flutter_comet/src/datamodels/question.dart';
// import 'package:oi_flutter_comet/src/datamodels/outcome.dart';
// import 'package:oi_flutter_comet/src/presentation/shared/logger.dart';
// import 'package:oi_flutter_comet/src/services/app_locale_service.dart';

import '../app/app.locator.dart';
import '../model/outcome_measure_collection.dart';
import 'app_locale_service.dart';

// final log = getLogger('OutcomeMeasurementService');
class OutcomeMeasureLoadService {
  final _pathToOutcomeTest =
      'packages/comet_foundation/outcome_measurement_tests/';
  final _appLocale = locator<AppLocaleService>();
  List<dynamic> allOutcomeMeasuresJson = [];
  late OutcomeMeasureCollection allOutcomeMeasures;
  List<OutcomeMeasureCollection> defaultOutcomeMeasureCollections = [];

  OutcomeMeasureLoadService() {
    getAllOutcomeMeasures('outcome_measures');
    getOutcomeMeasureCollections('default_collection');
  }

  Future<String> _loadAssetJSONAsString(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<OutcomeMeasureCollection> getAllOutcomeMeasures(
      String fileName) async {
    // log.i('getOutcomeMeasurements');
    print('getting outcome measures');
    String outcomesStr;
    try {
      outcomesStr = await _loadAssetJSONAsString(
          '$_pathToOutcomeTest$fileName${_appLocale.localeToAppend}.json');
    } catch (e) {
      print(e);
      // log.e('No outcome list file named \"$fileName${_appLocale.localeToAppend}.json\" found');
      outcomesStr =
          await _loadAssetJSONAsString('$_pathToOutcomeTest$fileName.json');
    }
    allOutcomeMeasuresJson = json.decode(outcomesStr);

    List<OutcomeMeasure> outcomeMeasures = allOutcomeMeasuresJson
        .map((o) => OutcomeMeasure.fromTemplateJson(o))
        .toList();
    allOutcomeMeasures =
        OutcomeMeasureCollection(outcomeMeasures: outcomeMeasures);
    return allOutcomeMeasures;
  }

  Future<void> getOutcomeMeasureCollections(String fileName) async {
    String collectionStr;
    try {
      collectionStr = await _loadAssetJSONAsString(
          '$_pathToOutcomeTest$fileName${_appLocale.localeToAppend}.json');
    } catch (e) {
      print(e);
      collectionStr =
          await _loadAssetJSONAsString('$_pathToOutcomeTest$fileName.json');
    }
    Map<String, dynamic> collectionMap = json.decode(collectionStr);

    defaultOutcomeMeasureCollections = collectionMap.keys.map((key) {
      List<dynamic> outcomeMeasureIds = collectionMap[key]['outcomeMeasures'];
      List<OutcomeMeasure> outcomeMeasures = [];
      for (String outcomeMeasureId in outcomeMeasureIds) {
        for (Map<String, dynamic> map in allOutcomeMeasuresJson) {
          if (map['id'] == outcomeMeasureId) {
            OutcomeMeasure temp = OutcomeMeasure.fromTemplateJson(map);
            outcomeMeasures.add(temp);
          }
        }
      }
      return OutcomeMeasureCollection(
          outcomeMeasures: outcomeMeasures,
          id: collectionMap[key]['id'],
          title: collectionMap[key]['title']);
    }).toList();
  }

  Future<List<dynamic>> getOutcomeQuestions(String fileName) async {
    // log.i('getOutcomeQuestions');
    String questionsStr;
    List<dynamic> jsonAsMap;
    try {
      questionsStr = await _loadAssetJSONAsString(
          '$_pathToOutcomeTest$fileName${_appLocale.localeToAppend}.json');
    } catch (e) {
      print(
          'No outcome question file named "$fileName${_appLocale.localeToAppend}.json" found');
      // log.e('No outcome question file named \"$fileName${_appLocale.localeToAppend}.json\" found');
      questionsStr =
          await _loadAssetJSONAsString('$_pathToOutcomeTest$fileName.json');
    }
    jsonAsMap = json.decode(questionsStr);
    return jsonAsMap;
  }

  Future<dynamic> getOutcomeInfo(String fileName) async {
    // log.i('getOutcomeInfo');
    String infoStr;
    dynamic jsonAsMap;
    try {
      infoStr = await _loadAssetJSONAsString(
          '$_pathToOutcomeTest$fileName${_appLocale.localeToAppend}.json');
    } catch (e) {
      // log.e('No outcome info file named \"$fileName${_appLocale.localeToAppend}.json\" found');
      infoStr =
          await _loadAssetJSONAsString('$_pathToOutcomeTest$fileName.json');
    }
    jsonAsMap = json.decode(infoStr);
    return jsonAsMap;
  }

  OutcomeMeasureCollection getCollection({required String id}){
    try{
      return defaultOutcomeMeasureCollections.firstWhere((element) => element.id == id);
    }catch(e){
      throw Exception(e);
    }
  }

}
