import 'package:easy_localization/easy_localization.dart';

import '../constants/app_strings.dart';
import '../constants/enum.dart';
import '../generated/locale_keys.g.dart';

abstract class Question {
  final String id;
  final QuestionType type;
  String text;
  final int? group;
  final int? scoreGroup;
  dynamic value;
  String? _ttsText;

  Question(
      {required this.type,
      required this.id,
      required this.text,
      this.group,
      this.scoreGroup,
      this.value});

  bool get hasResponded => value != null;

  void clearResponse() => value = null;

  String get ttsText => _ttsText ?? text;

  Map<String, dynamic> toJson() {
    return {
      kID: id,
      // kType: type,
      // kText: text,
      // kGroup: group,
      // kScoreGroup: scoreGroup,
      kResponseValue: value
    };
  }

  String toJSONString() {
    return '{'
        '"$kDocumentUID": $id,'
        '"$kType": $type,'
        '"$kText": $text,'
        '}';
  }

  void createTtsText() {}

  Map<String, String>? get exportResponse =>
      value == null ? null : {id: "$value"};

  @override
  String toString() {
    return toJSONString();
  }
}

class BasicQuestion extends Question {
  BasicQuestion(String id, String text)
      : super(id: id, text: text, type: QuestionType.basic);

  factory BasicQuestion.fromJson(question) {
    return BasicQuestion(
      question['id'],
      question['question'],
    );
  }
}

class QuestionWithTimerResponse extends Question {
  QuestionWithTimerResponse(String id, String text, int? responseValue)
      : super(id: id, text: text, type: QuestionType.time) {
    if (responseValue != null) {
      value = Duration(milliseconds: responseValue);
    }
  }

  factory QuestionWithTimerResponse.fromJson(question) {
    return QuestionWithTimerResponse(
        question[kID], question[kQuestion], question[kResponseValue]);
  }

  @override
  Map<String, String>? get exportResponse {
    if (value == null) {
      return null;
    } else {
      Duration duration = value;
      var min = duration.inMinutes % 60;
      var sec = (duration.inMilliseconds - (min * 60000)) / 1000;
      var map = {"${id}_min": "$min", "${id}_sec": sec.toStringAsFixed(2)};
      return map;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Duration? duration = value;
    return {
      kID: id,
      // kType: type.name,
      // kGroup: group,
      // kScoreGroup: scoreGroup,
      // kQuestion: text,
      kResponseValue: duration?.inMilliseconds
    };
  }
}

class QuestionWithTextResponse extends Question {
  QuestionWithTextResponse(
      String id, int group, String text, dynamic responseValue)
      : super(
            id: id,
            group: group,
            text: text,
            type: QuestionType.text,
            value: responseValue);

  factory QuestionWithTextResponse.fromJson(question) {
    return QuestionWithTextResponse(question[kID], question[kGroup],
        question[kQuestion], question[kResponseValue]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      kID: id,
      // kType: type.name,
      // kGroup: group,
      // kScoreGroup: scoreGroup,
      // kQuestion: text,
      kResponseValue: value
    };
  }
}

class QuestionWithRadialResponse extends Question {
  List options;

  QuestionWithRadialResponse(String id, int group, int? scoreGroup, String text,
      this.options, dynamic responseValue)
      : super(
            id: id,
            group: group,
            scoreGroup: scoreGroup,
            text: text,
            type: QuestionType.radial,
            value: responseValue) {
    createTtsText();
  }

  factory QuestionWithRadialResponse.fromJson(question) {
    return QuestionWithRadialResponse(
        question[kID],
        question[kGroup],
        question[kScoreGroup],
        question[kQuestion],
        question[kOption],
        question[kResponseValue]);
  }

  @override
  void createTtsText() {
    _ttsText = text;
    _ttsText = '$_ttsText. ${options.join('. ')}';
  }

  @override
  Map<String, String>? get exportResponse =>
      value == null ? null : {"${id}_$value": "Yes"};

  @override
  String toJSONString() {
    return '{'
        '"$kID": $id,'
        '"$kType": $type,'
        '"$kText": $text,'
        '"options": $options,'
        '}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      kID: id,
      // kType: type.name,
      // kGroup: group,
      // kScoreGroup: scoreGroup,
      // kQuestion: text,
      kResponseValue: value,
      // kOption: options
    };
  }
}

class QuestionWithRadialCheckBoxResponse extends Question {
  List options;
  String tapQuestion;
  bool isChecked = false;

  @override
  bool get hasResponded => value != null || isChecked != false;

  QuestionWithRadialCheckBoxResponse(
      String id,
      int group,
      int? scoreGroup,
      String text,
      this.options,
      this.tapQuestion,
      dynamic responseValue,
      bool? checkBoxResponseValue)
      : super(
            id: id,
            group: group,
            scoreGroup: scoreGroup,
            text: text,
            type: QuestionType.radial_checkbox,
            value: responseValue) {
    if (checkBoxResponseValue != null) {
      isChecked = checkBoxResponseValue;
    }
    createTtsText();
  }

  factory QuestionWithRadialCheckBoxResponse.fromJson(question) {
    return QuestionWithRadialCheckBoxResponse(
        question[kID],
        question[kGroup],
        question[kScoreGroup],
        question[kQuestion],
        question[kOption],
        question[kTapQuestion],
        question[kResponseValue],
        question[kCheckBoxResponseValue]);
  }

  @override
  void createTtsText() {
    _ttsText = text;
    _ttsText = '$_ttsText. ${options.join('. ')}';
    _ttsText = '$_ttsText. ${LocaleKeys.or.tr()}, $tapQuestion';
  }

  @override
  Map<String, String>? get exportResponse {
    return value == null
        ? isChecked
            ? {"${id}_tap": "Yes"}
            : null
        : {"${id}_$value": "Yes"};
  }

  @override
  String toJSONString() {
    return '{'
        '"$kID": $id,'
        '"$kType": $type,'
        '"$kText": $text,'
        '"options": $options,'
        '}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      kID: id,
      // kType: type.name,
      // kGroup: group,
      // kScoreGroup: scoreGroup,
      // kQuestion: text,
      kResponseValue: value,
      // kTapQuestion: tapQuestion,
      kCheckBoxResponseValue: isChecked,
      // kOption: options
    };
  }
}

class QuestionWithVasResponse extends Question {
  double get scaleValue => value ?? 0.0;

  set scaleValue(value) {
    this.value = value;
  }

  String min;
  String max;

  QuestionWithVasResponse(String id, int group, int? scoreGroup, String text,
      this.min, this.max, dynamic responseValue)
      : super(
            id: id,
            group: group,
            scoreGroup: scoreGroup,
            text: text,
            type: QuestionType.vas,
            value: responseValue);

  factory QuestionWithVasResponse.fromJson(question) {
    return QuestionWithVasResponse(
        question[kID],
        question[kGroup],
        question[kScoreGroup],
        question[kQuestion],
        question[kMin],
        question[kMax],
        question[kResponseValue]);
  }

  @override
  Map<String, String>? get exportResponse {
    return value == null ? null : {id: "${value.toInt()}"};
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      kID: id,
      // kType: type.name,
      // kGroup: group,
      // kScoreGroup: scoreGroup,
      // kQuestion: text,
      // kMin: min,
      // kMax: max,
      kResponseValue: value
    };
  }
}

class QuestionWithDiscreteScaleResponse extends Question {
  double get scaleValue => value ?? min.toDouble();

  set scaleValue(value) {
    this.value = value;
  }

  int min;
  int max;
  int interval;

  QuestionWithDiscreteScaleResponse(String id, int group, int? scoreGroup,
      String text, this.min, this.max, this.interval, dynamic responseValue)
      : super(
            id: id,
            group: group,
            scoreGroup: scoreGroup,
            text: text,
            type: QuestionType.discrete_scale) {
    scaleValue = responseValue;
  }

  factory QuestionWithDiscreteScaleResponse.fromJson(question) {
    return QuestionWithDiscreteScaleResponse(
        question[kID],
        question[kGroup],
        question[kScoreGroup],
        question[kQuestion],
        question[kMin],
        question[kMax],
        question[kInterval],
        question[kResponseValue]);
  }

  @override
  Map<String, String>? get exportResponse {
    return value == null ? null : {id: "${value.toInt()}"};
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      kID: id,
      // kType: type.name,
      // kGroup: group,
      // kScoreGroup: scoreGroup,
      // kQuestion: text,
      // kMin: min,
      // kMax: max,
      // kInterval: interval,
      kResponseValue: value
    };
  }
}

class QuestionWithDiscreteScaleTextResponse extends Question {
  double get scaleValue => value ?? min.toDouble();

  set scaleValue(value) {
    this.value = value;
  }

  int min;
  int max;
  int interval;
  String textResponse = '';

  QuestionWithDiscreteScaleTextResponse(
      String id,
      int group,
      int? scoreGroup,
      String text,
      this.min,
      this.max,
      this.interval,
      double? scaleResponseValue,
      String? textResponseValue)
      : super(
            id: id,
            group: group,
            scoreGroup: scoreGroup,
            text: text,
            type: QuestionType.discrete_scale_text) {
    scaleValue = scaleResponseValue;
    textResponseValue == null
        ? textResponse = ''
        : textResponse = textResponseValue;
  }

  factory QuestionWithDiscreteScaleTextResponse.fromJson(question) {
    return QuestionWithDiscreteScaleTextResponse(
        question[kID],
        question[kGroup],
        question[kScoreGroup],
        question[kQuestion],
        question[kMin],
        question[kMax],
        question[kInterval],
        question[kScaleResponseValue],
        question[kTextResponseValue]);
  }

  @override
  Map<String, String>? get exportResponse {
    return value == null || textResponse == ''
        ? null
        : {"${id}_text": textResponse, id: "${value.toInt()}"};
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      kID: id,
      // kType: type.name,
      // kGroup: group,
      // kScoreGroup: scoreGroup,
      // kQuestion: text,
      // kMin: min,
      // kMax: max,
      // kInterval: interval,
      kScaleResponseValue: value,
      kTextResponseValue: textResponse
    };
  }
}

// TODO: tts for spanish
class QuestionWithDiscreteScaleCheckBoxResponse extends Question {
  double get scaleValue => value ?? min.toDouble();

  set scaleValue(value) {
    isChecked = false;
    this.value = value;
  }

  int min;
  int max;
  int interval;
  String tapQuestion;
  bool isChecked = false;

  @override
  bool get hasResponded => value != null || isChecked != false;

  QuestionWithDiscreteScaleCheckBoxResponse(
      String id,
      int group,
      int? scoreGroup,
      String text,
      this.min,
      this.max,
      this.interval,
      this.tapQuestion,
      dynamic responseValue,
      bool? checkBoxResponseValue)
      : super(
            id: id,
            group: group,
            scoreGroup: scoreGroup,
            text: text,
            type: QuestionType.discrete_scale_checkbox) {
    if (responseValue != null) {
      scaleValue = responseValue;
    }
    if (checkBoxResponseValue != null) {
      isChecked = checkBoxResponseValue;
    }
    createTtsText();
  }

  factory QuestionWithDiscreteScaleCheckBoxResponse.fromJson(question) {
    return QuestionWithDiscreteScaleCheckBoxResponse(
        question[kID],
        question[kGroup],
        question[kScoreGroup],
        question[kQuestion],
        question[kMin],
        question[kMax],
        question[kInterval],
        question[kTapQuestion],
        question[kResponseValue],
        question[kCheckBoxResponseValue]);
  }

  @override
  void createTtsText() {
    _ttsText = text;
    _ttsText = '$_ttsText. ${LocaleKeys.or.tr()}, $tapQuestion';
  }

  @override
  Map<String, String>? get exportResponse {
    return value == null
        ? isChecked
            ? {"${id}_tap": "Yes"}
            : null
        : {id: "${value.toInt()}"};
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      kID: id,
      // kType: type.name,
      // kGroup: group,
      // kScoreGroup: scoreGroup,
      // kQuestion: text,
      // kMin: min,
      // kMax: max,
      // kInterval: interval,
      // kTapQuestion: tapQuestion,
      kCheckBoxResponseValue: isChecked,
      kResponseValue: value
    };
  }

  @override
  void clearResponse() {
    isChecked = false;
    value = 0.0;
  }
}

// TODO: tts for spanish
class QuestionWithTextCheckBoxResponse extends Question {
  String tapQuestion;
  bool isChecked = false;

  @override
  bool get hasResponded => value != null || isChecked != false;

  QuestionWithTextCheckBoxResponse(
      String id,
      int group,
      int? scoreGroup,
      String text,
      this.tapQuestion,
      bool? checkBoxResponseValue,
      String? responseValue)
      : super(
            id: id,
            group: group,
            scoreGroup: scoreGroup,
            text: text,
            type: QuestionType.text_checkbox,
            value: responseValue) {
    if (checkBoxResponseValue != null) {
      isChecked = checkBoxResponseValue;
    }
    createTtsText();
  }

  factory QuestionWithTextCheckBoxResponse.fromJson(question) {
    return QuestionWithTextCheckBoxResponse(
        question[kID],
        question[kGroup],
        question[kScoreGroup],
        question[kQuestion],
        question[kTapQuestion],
        question[kCheckBoxResponseValue],
        question[kResponseValue]);
  }

  @override
  void createTtsText() {
    _ttsText = text;
    _ttsText = '$_ttsText. ${LocaleKeys.or.tr()}, $tapQuestion';
    print(_ttsText);
  }

  @override
  Map<String, String>? get exportResponse {
    return value == null
        ? isChecked
            ? {"${id}_tap": "Yes"}
            : null
        : {id: "$value"};
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      kID: id,
      // kType: type.name,
      // kGroup: group,
      // kScoreGroup: scoreGroup,
      // kQuestion: text,
      // kTapQuestion: tapQuestion,
      kCheckBoxResponseValue: isChecked,
      kResponseValue: value
    };
  }

  @override
  void clearResponse() {
    isChecked = false;
    value = 0.0;
  }
}

class QuestionWithVasCheckboxResponse extends Question {
  String min;
  String max;
  double get scaleValue => value ?? 0.0;

  set scaleValue(value) {
    isChecked = false;
    this.value = value;
  }

  String alternativeQuestion;
  bool isChecked = false;

  @override
  bool get hasResponded => value != null || isChecked != false;

  QuestionWithVasCheckboxResponse(String id, int group, int? scoreGroup,
      String text, this.min, this.max, this.alternativeQuestion)
      : super(
            id: id,
            group: group,
            scoreGroup: scoreGroup,
            text: text,
            type: QuestionType.vas_checkbox_combo);

  factory QuestionWithVasCheckboxResponse.fromJson(question) {
    return QuestionWithVasCheckboxResponse(
        question['id'],
        question['group'],
        question['score_group'],
        question['question'],
        question['min'],
        question['max'],
        question['question2']);
  }

  @override
  Map<String, String>? get exportResponse {
    return value == null
        ? isChecked
            ? {"${id}_tap": "Yes", id: "100"}
            : null
        : {id: "${value.toInt()}"};
  }

  @override
  void clearResponse() {
    isChecked = false;
    value = null;
  }
}
