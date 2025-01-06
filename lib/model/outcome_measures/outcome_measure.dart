import 'package:biot/constants/app_strings.dart';
import 'package:biot/constants/enum.dart';
import 'package:biot/model/outcome_measures/patient_specific_functional_scale.dart';
import 'package:biot/model/outcome_measures/prosthesis_evaluation_questionnaire.dart';
import 'package:biot/model/outcome_measures/tapes_r.dart';
import 'package:biot/model/outcome_measures/timed_up_and_go.dart';
import 'package:biot/model/outcome_measures/two_minute_walk_test.dart';
import 'package:biot/model/patient.dart';
import 'package:biot/services/outcome_measure_load_service.dart';
import 'package:intl/intl.dart';
import '../../app/app.locator.dart';
import '../outcome_measure_info.dart';
import '../question_collection.dart';
import 'amp.dart';
import 'eq_5d_5l.dart';

abstract class OutcomeMeasure {
  final _outcomeMeasureLoadService = locator<OutcomeMeasureLoadService>();

  ///Fields from outcome measure template json file
  // this is the outcome measure prefix id and must match prefix id used in the cloud environment
  late String id;
  late String _name;
  late String _shortName;
  late OutcomeMeasureInfo info;
  late DomainType domainType;
  int estTimeToComplete = 0;
  bool isAssistantNeeded = false;
  List<dynamic>? tags;
  late List<dynamic> supportedLocale;
  String? familyName;
  String? familyShortName;

  ///Fields from cloud backend
  String? entityId;
  String? templateId;
  DateTime? creationTime;
  String? patientId;
  String? sessionId;
  int? index;

  String get rawName => _name;

  String get rawShortName => _shortName;

  String get name =>
      familyShortName == null ? _name : '$familyShortName-$_name';

  String get shortName =>
      familyShortName == null ? _shortName : '$familyShortName-$_shortName';
  late double rawValue;
  List<Map<String, String>>? summaryDataToBeModified;
  bool isPopulated = false;
  int numOfGraph = 1;
  bool isSelected = false;
  late QuestionCollection questionCollection;
  Map<String, dynamic>? data;
  String? encounterCreatedTimeString;
  String? outcomeMeasureCreatedTimeString;
  int timeToComplete = 0;
  DateTime? _startTime;

  DateTime? get outcomeMeasureCreatedTime =>
      (outcomeMeasureCreatedTimeString != null)
          ? DateTime.parse(outcomeMeasureCreatedTimeString!)
          : null;

  String get chartYAxisTitle =>
      '${info.yAxisLabel} ${(info.yAxisUnit == null) ? '' : '(${info.yAxisUnit})'}';

  // String size should be between 1 and 32.
  String get currentTime =>
      '${DateFormat.yMd().format(DateTime.now())}_${DateFormat.Hms().format(DateTime.now())}';

  bool get isComplete => questionCollection.isComplete;

  OutcomeMeasure({required this.id, this.data}) {
    if (data != null) {
      _name = data!['name'];
      _shortName = data!['shortName'];
      tags = data!['tags'] ?? [];
      familyName = data!['familyName'];
      familyShortName = data!['familyShortName'];
      domainType = DomainType.fromType(data!['domainType']);
      estTimeToComplete = int.parse(data!['estimatedTime']);
      isAssistantNeeded =
          bool.parse(data!['isAssistantNeeded'], caseSensitive: false);
      supportedLocale = data![kSupportedLocales] ?? ['en'];
    } else {
      copyOutcomeMeasureTemplateData();
    }
  }

  void copyOutcomeMeasureTemplateData() {
    OutcomeMeasure template =
        _outcomeMeasureLoadService.allOutcomeMeasures.getOutcomeMeasureById(id);
    _name = template.rawName;
    _shortName = template.rawShortName;
    tags = template.tags;
    familyName = template.familyName;
    familyShortName = template.familyShortName;
    domainType = template.domainType;
    estTimeToComplete = template.estTimeToComplete;
    isAssistantNeeded = template.isAssistantNeeded;
    supportedLocale = template.supportedLocale;
  }

  bool canProceed() {
    return true;
  }

  double? normalizeSigDiffPositive() {
    return null;
  }

  double? normalizeSigDiffNegative() {
    return null;
  }

  void started() {
    _startTime = DateTime.now();
  }

  void completed() {
    if (_startTime != null) {
      Duration duration = DateTime.now().difference(_startTime!);
      timeToComplete += duration.inSeconds;
    }
  }

  Future<void> build({bool shouldLocalize = false}) async {
    await buildInfo();
    await buildQuestions(shouldLocalize: shouldLocalize);
  }

  Future buildInfo() async {
    try {
      var info = await _outcomeMeasureLoadService.getOutcomeInfo('${id}_info');
      this.info = OutcomeMeasureInfo.fromJson(id, info);
      return true;
    } catch (e) {
      return Exception('Building info failed for outcome measure with id:$id');
    }
  }

  Future<void> buildQuestions({bool shouldLocalize = false}) async {
    try {
      var rawQuestions = await _outcomeMeasureLoadService
          .getOutcomeQuestions('${id}_questions');
      if (shouldLocalize) {
        questionCollection.localizeWith(rawQuestions);
      } else {
        questionCollection = QuestionCollection.fromJson(rawQuestions);
      }
      questionCollection.groupHeaders = info.groupHeaders;
    } catch (e) {
      Exception('Building questions failed for outcome measure with id:$id');
    }
  }

  void populateWithJson(Map<String, dynamic> json);

  String getSummaryScoreTitle(int index) {
    String summaryScoreTitle = info.summaryScore![index];
    return summaryScoreTitle;
  }

  Map<String, dynamic> toJson(
      String ownerOrganizationId, Patient patient, int index);

  factory OutcomeMeasure.withId(String id, [Map<String, dynamic>? data]) {
    switch (id) {
      case '10mwt':
      case ksPsfs:
        return Psfs(id: id, data: data);
      case ksTug:
        return Tug(id: id, data: data);
      case ksEq5d:
        return Eq5d(id: id, data: data);
      case 'tminwt':
        return Tminwt(id: id, data: data);
      case 'peq_ut':
        return PeqUt(id: id, data: data);
      case 'peq_rl':
        return PeqRl(id: id, data: data);
      case 'tapes_r':
        return TapesR(id: id, data: data);
      case 'amp':
        return Amp(id: id, data: data);
      default:
        return Tug(id: id, data: data);
    }
  }

  factory OutcomeMeasure.fromJson(Map<String, dynamic> data) {
    if (data[ksTemplate]['name'] == ksPsfs) {
      return Psfs.fromJson(data);
    }
    if (data[ksTemplate]['name'] == ksTug) {
      return Tug.fromJson(data);
    }
    if (data[ksTemplate]['name'] == ksEq5d) {
      return Eq5d.fromJson(data);
    }
    throw UnimplementedError();
  }

  factory OutcomeMeasure.fromTemplateJson(Map<String, dynamic> data) {
    return OutcomeMeasure.withId(data['id'], data);
  }

  // Override hashCode and operator== for proper comparison.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OutcomeMeasure && other.id == id;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  Map<String, dynamic> exportResponses(String locale) {
    Map<String, dynamic> responses = {};
    for (var element in questionCollection.questions) {
      if (element.exportResponse != null) {
        responses.addAll(element.exportResponse!);
      }
    }
    responses.addAll(totalScore);
    return responses;
  }

  @override
  Map<String, dynamic> get totalScore => {};
}
