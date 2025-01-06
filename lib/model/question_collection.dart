import 'package:biot/model/question.dart';
import 'package:hive/hive.dart';

import '../constants/app_strings.dart';
import '../constants/enum.dart';
// import 'package:oi_flutter_comet/src/app/app_constants.dart';
// import 'package:oi_flutter_comet/src/datamodels/question.dart';
// import '../enum/enum.dart';
// import '../presentation/shared/logger.dart';

// final log = getLogger('QuestionCollection');

class QuestionCollection extends HiveObject {
  bool get hasGroupHeaders => groupHeaders != null;
  List? groupHeaders;
  int get numGroups {
    if (groupHeaders != null){
      return groupHeaders!.length;
    }else{
      return -1;
    }
  }
  List<Question> questions;

  int get totalQuestions => questions.length;

  QuestionCollection(this.questions);

  factory QuestionCollection.fromJson(rawQuestions) {
    List<Question> questions = [];
    for (var i = 0; i < rawQuestions.length; i++) {
      var q = rawQuestions[i];
      String type = rawQuestions[i][kType];
      Question question;
      switch (type) {
        case 'radial':
          question = QuestionWithRadialResponse.fromJson(q);
        case 'radial_checkbox':
          question = QuestionWithRadialCheckBoxResponse.fromJson(q);
        case 'vas':
          question = QuestionWithVasResponse.fromJson(q);
        case 'discrete_scale':
          question = QuestionWithDiscreteScaleResponse.fromJson(q);
        case 'discrete_scale_text':
          question = QuestionWithDiscreteScaleTextResponse.fromJson(q);
        case 'discrete_scale_checkbox':
          question = QuestionWithDiscreteScaleCheckBoxResponse.fromJson(q);
        case 'checkbox':
          question = BasicQuestion.fromJson(q);
        case 'vas_checkbox_combo':
          question = QuestionWithVasCheckboxResponse.fromJson(q);
        case 'text':
          question = QuestionWithTextResponse.fromJson(q);
        case 'text_checkbox':
          question = QuestionWithTextCheckBoxResponse.fromJson(q);
        case 'time':
          question = QuestionWithTimerResponse.fromJson(q);
        default:
          question = BasicQuestion.fromJson(q);
      }
      questions.add(question);
    }
    return QuestionCollection(questions);
  }

  List<Map<String, dynamic>> toJson() {
    return questions.map((e) => e.toJson()).toList();
  }

  List<Question> getQuestionsForGroup(int group, [int? length]) {
    if (length == null) {
      return questions.where((e) => e.group == group).toList();
    } else {
      List<Question> questionList = [];
      for (var i = group; i < group + length; i++) {
        questionList.addAll(questions.where((e) => e.group == i).toList());
      }
      return questionList;
    }
  }

  List<Question> getQuestionsForScoreGroup(int scoreGroup) {
    return questions.where((e) => e.scoreGroup == scoreGroup).toList();
  }

  Question? getQuestionById(String id) {
    try {
      return questions.where((e) => e.id == id).toList().first;
    } catch (e) {
      // log.e('Question ID not found');
      Exception('Question ID not found');
      return null;
    }
  }

  int skippedQuestionsForScoreGroup(int scoreGroup) {
    List<Question> qs = getQuestionsForScoreGroup(scoreGroup);
    return qs.where((element) => element.hasResponded == false).length;
  }

  int skippedQuestionsForGroup(int group) {
    List<Question> qs = getQuestionsForGroup(group);
    return qs.where((element) => element.hasResponded == false).length;
  }

  bool isGroupComplete(int group, {String? conditionalQuestionId, int conditionalValue = 0}){
    if(conditionalQuestionId == null){
      return skippedQuestionsForGroup(group) == 0;
    }else{
      Question? q = getQuestionById(conditionalQuestionId);
      if(q!.hasResponded && q.value == conditionalValue){
        return true;
      }else{
        return skippedQuestionsForGroup(group) == 0;
      }
    }
  }

  bool get isComplete {
    return questions.where((element) => element.hasResponded == false).isEmpty;
  }

  int get numOfAnsweredQuestions {
    return questions.where((element) => element.hasResponded == true).length;
  }

  void localizeWith(List localizedRawQuestions) {
    for (var i = 0; i < questions.length; i++) {
      Question question = questions[i];
      Map<String, dynamic> localizedQuestion = localizedRawQuestions[i];
      question.text = localizedQuestion[kQuestion];
      if (question.type == QuestionType.discrete_scale_checkbox) {
        QuestionWithDiscreteScaleCheckBoxResponse q =
            question as QuestionWithDiscreteScaleCheckBoxResponse;
        q.tapQuestion = localizedQuestion[kTapQuestion];
      } else if (question.type == QuestionType.radial_checkbox) {
        QuestionWithRadialCheckBoxResponse q =
            question as QuestionWithRadialCheckBoxResponse;
        q.tapQuestion = localizedQuestion[kTapQuestion];
        q.options = localizedQuestion[kOption];
      } else if (question.type == QuestionType.text_checkbox) {
        QuestionWithTextCheckBoxResponse q =
            question as QuestionWithTextCheckBoxResponse;
        q.tapQuestion = localizedQuestion[kTapQuestion];
      } else if (question.type == QuestionType.radial) {
        QuestionWithRadialResponse q = question as QuestionWithRadialResponse;
        q.options = localizedQuestion[kOption];
      }
      question.createTtsText();
    }
  }
}
