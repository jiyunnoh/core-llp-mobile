import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../../app/app.locator.dart';
import '../../../constants/enum.dart';
import '../../../generated/locale_keys.g.dart';
import '../../../model/outcome_measures/outcome_measure.dart';
import '../../../model/question.dart';
import '../../../services/app_locale_service.dart';
import '../../../services/tts_service.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../response widgets/discrete_scale_checkbox_response.dart';
import '../response widgets/discrete_scale_response.dart';
import '../response widgets/discrete_scale_text_response.dart';
import '../response widgets/radiobutton_checkbox_response.dart';
import '../response widgets/radiobutton_response.dart';
import '../response widgets/text_checkbox_response.dart';
import '../response widgets/text_response.dart';
import '../response widgets/vas_checkbox_response.dart';
import '../response widgets/vas_response.dart';

// final log = getLogger('Evaluation');

class Evaluation extends StatefulWidget {
  final OutcomeMeasure outcomeMeasure;

  const Evaluation({super.key, required this.outcomeMeasure});

  @override
  State<Evaluation> createState() => _EvaluationState();
}

class _EvaluationState extends State<Evaluation> {
  int currentStep = 0;
  int currentGroup = 0;
  late List<int> currentGroupSteps;
  List<UniqueKey> itemKeys = [];
  String _selectedKey = '';
  final _localeService = locator<AppLocaleService>();
  final _ttsService = locator<TtsService>();
  final ItemScrollController _scrollController = ItemScrollController();

  TtsState get ttsState => _ttsService.ttsState;

  @override
  initState() {
    super.initState();
    if (widget.outcomeMeasure.questionCollection.groupHeaders != null) {
      currentGroup = 0;
      currentGroupSteps = List<int>.generate(
          widget.outcomeMeasure.questionCollection.groupHeaders!.length,
          (index) => 0);
    }

    if (widget.outcomeMeasure.supportedLocale.length == 1) {
      _ttsService.setLanguage(const Locale('en'));
    } else {
      _ttsService.setLanguage(_localeService.locale);
    }

    _ttsService.addListener(notifyListener);
  }

  void notifyListener() {
    if (ttsState == TtsState.stopped) {
      _selectedKey = '';
    }

    setState(() {});
  }

  void onSelectKey(String newKey) {
    _selectedKey = newKey;
  }

  Widget _getResponseTile(Question q) {
    switch (q.type) {
      case QuestionType.radial:
        QuestionWithRadialResponse myQ = q as QuestionWithRadialResponse;
        return RadioButtonResponse(
            key: Key(myQ.id), question: myQ, answerStateChanged: () => {});
      case QuestionType.radial_checkbox:
        QuestionWithRadialCheckBoxResponse myQ =
            q as QuestionWithRadialCheckBoxResponse;
        return RadioButtonCheckBoxResponse(
            key: Key(myQ.id), question: myQ, answerStateChanged: () => {});
      case QuestionType.vas:
        QuestionWithVasResponse myQ = q as QuestionWithVasResponse;
        return VasResponse(
            key: Key(myQ.id), question: myQ, answerStateChanged: () => {});
      case QuestionType.discrete_scale:
        QuestionWithDiscreteScaleResponse myQ =
            q as QuestionWithDiscreteScaleResponse;
        return DiscreteScaleResponse(
            key: Key(myQ.id), question: myQ, answerStateChanged: () => {});
      case QuestionType.discrete_scale_checkbox:
        QuestionWithDiscreteScaleCheckBoxResponse myQ =
            q as QuestionWithDiscreteScaleCheckBoxResponse;
        return DiscreteScaleCheckBoxResponse(
            key: Key(myQ.id), question: myQ, answerStateChanged: () => {});
      case QuestionType.discrete_scale_text:
        QuestionWithDiscreteScaleTextResponse myQ =
            q as QuestionWithDiscreteScaleTextResponse;
        return DiscreteScaleTextResponse(
            key: Key(myQ.id), question: myQ, answerStateChanged: () => {});
      case QuestionType.vas_checkbox_combo:
        QuestionWithVasCheckboxResponse myQ =
            q as QuestionWithVasCheckboxResponse;
        return VasCheckboxResponse(
            key: Key(myQ.id), question: myQ, answerStateChanged: () => {});
      case QuestionType.text:
        QuestionWithTextResponse myQ = q as QuestionWithTextResponse;
        return TextResponse(
            key: Key(myQ.id), question: myQ, answerStateChanged: () => {});
      case QuestionType.text_checkbox:
        QuestionWithTextCheckBoxResponse myQ =
            q as QuestionWithTextCheckBoxResponse;
        return TextCheckBoxResponse(
            key: Key(myQ.id), question: myQ, answerStateChanged: () => {});
      default:
        return Container();
    }
  }

  void onStepContinue() {
    setState(() {
      currentStep <
              widget.outcomeMeasure.questionCollection.questions.length - 1
          ? currentStep += 1
          : null;
    });
  }

  Widget controlsBuilder(BuildContext context, int group,
      int currentQuestionNum, OutcomeMeasure outcomeMeasure,
      {Function? onStepContinue, Function? onStepCancel}) {
    Color cancelColor;
    print('controllBuilder - group: $group, question: $currentQuestionNum');
    switch (Theme.of(context).brightness) {
      case Brightness.light:
        cancelColor = Colors.black54;
        break;
      case Brightness.dark:
        cancelColor = Colors.white70;
        break;
    }

    const OutlinedBorder buttonShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)));
    const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 16.0);

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            // The Material spec no longer includes a Stepper widget. The continue
            // and cancel button styles have been configured to match the original
            // version of this widget.
            children: <Widget>[
              if (currentQuestionNum != 0 || group != 0)
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 8.0),
                  child: TextButton(
                    onPressed: () {
                      if (onStepCancel != null) {
                        onStepCancel();
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: cancelColor,
                      padding: buttonPadding,
                      shape: buttonShape,
                    ),
                    child:
                        Text(LocaleKeys.previousAllCap, style: contentTextStyle)
                            .tr(),
                  ),
                ),
              group != outcomeMeasure.questionCollection.numGroups - 1
                  ? TextButton(
                      onPressed: () {
                        if (onStepContinue != null) {
                          onStepContinue();
                        }
                      },
                      child:
                          Text(LocaleKeys.nextAllCap, style: contentTextStyle)
                              .tr(),
                    )
                  : currentQuestionNum <
                          outcomeMeasure.questionCollection
                                  .getQuestionsForGroup(group)
                                  .length -
                              1
                      ? TextButton(
                          onPressed: () {
                            if (onStepContinue != null) {
                              onStepContinue();
                            }
                          },
                          child: Text(LocaleKeys.nextAllCap,
                                  style: contentTextStyle)
                              .tr(),
                        )
                      : Container()
            ],
          ),
          // Last question of the last group
          if (group == outcomeMeasure.questionCollection.numGroups - 1 &&
              currentQuestionNum ==
                  outcomeMeasure.questionCollection
                          .getQuestionsForGroup(group)
                          .length -
                      1)
            Text('- End of outcome measure -', style: contentTextStyle)
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ttsService.removeListener(notifyListener);
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.outcomeMeasure.questionCollection.hasGroupHeaders
            ? ScrollablePositionedList.builder(
                itemScrollController: _scrollController,
                itemCount: widget
                    .outcomeMeasure.questionCollection.groupHeaders!.length,
                itemBuilder: (context, group) {
                  if (group >= itemKeys.length) {
                    itemKeys.add(UniqueKey());
                  }
                  final uniqueKey = itemKeys[group];
                  return StickyHeader(
                      header: Container(
                        key: uniqueKey,
                        height: stickyHeaderHeight,
                        color: (_selectedKey == uniqueKey.toString())
                            ? CometColors.ttsColor
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                    widget.outcomeMeasure.questionCollection
                                        .groupHeaders![group],
                                    style: evalHeaderStyle),
                              ),
                              // Material(
                              //   color: (_selectedKey == uniqueKey.toString())
                              //       ? CometColors.ttsColor
                              //       : Colors.white,
                              //   child: IconButton(
                              //     onPressed: () {
                              //       _ttsService.speak(widget
                              //           .outcomeMeasure
                              //           .questionCollection
                              //           .groupHeaders![group]);
                              //       onSelectKey(uniqueKey.toString());
                              //     },
                              //     icon: const Icon(Icons.volume_up),
                              //     splashRadius: 24.0,
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ),
                      content: Stepper(
                          physics: const ClampingScrollPhysics(),
                          currentStep: currentGroupSteps[group],
                          controlsBuilder: (context, details) {
                            return controlsBuilder(context, group,
                                currentGroupSteps[group], widget.outcomeMeasure,
                                onStepContinue: details.onStepContinue,
                                onStepCancel: details.onStepCancel);
                          },
                          onStepTapped: (step) {
                            currentGroup = group;
                            print('onStepTapped: $step');
                            print('group: $group');
                            setState(() {
                              currentGroupSteps[currentGroup] = step;
                            });
                          },
                          onStepContinue: () {
                            // log.i('onStepContinue: $group');
                            setState(() {
                              currentGroup = group;
                              if (currentGroupSteps[currentGroup] <
                                  widget.outcomeMeasure.questionCollection
                                          .getQuestionsForGroup(currentGroup)
                                          .length -
                                      1) {
                                currentGroupSteps[currentGroup] += 1;
                              } else if (currentGroup <
                                  widget.outcomeMeasure.questionCollection
                                          .groupHeaders!.length -
                                      1) {
                                currentGroup++;
                                _scrollController.scrollTo(
                                    index: currentGroup,
                                    duration:
                                        const Duration(milliseconds: 500));
                              } else {
                                null;
                              }
                            });
                          },
                          onStepCancel: () {
                            setState(() {
                              currentGroup = group;
                              if(currentGroupSteps[currentGroup] > 0){
                                currentGroupSteps[currentGroup] -= 1;
                              }else if(currentGroup > 0){
                                currentGroup--;
                                _scrollController.scrollTo(
                                    index: currentGroup,
                                    duration:
                                    const Duration(milliseconds: 500));
                              }else{
                                null;
                              }
                            });
                          },
                          steps: widget.outcomeMeasure.questionCollection
                              .getQuestionsForGroup(group)
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            Question q = entry.value;
                            return Step(
                                title: Container(
                                  key: Key(index.toString()),
                                  color: _selectedKey == index.toString()
                                      ? CometColors.ttsColor
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          q.text,
                                          style: contentTextStyle,
                                        ),
                                      ),
                                      // if (currentGroupSteps[currentGroup] ==
                                      //     index)
                                      //   IconButton(
                                      //     onPressed: () {
                                      //       _ttsService.speak(q.ttsText);
                                      //       onSelectKey(index.toString());
                                      //     },
                                      //     icon: const Icon(Icons.volume_up),
                                      //   )
                                    ],
                                  ),
                                ),
                                content: Container(
                                    color: _selectedKey == index.toString()
                                        ? CometColors.ttsColor
                                        : Colors.transparent,
                                    child: _getResponseTile(q)),
                                isActive: currentGroup >= group ||
                                    currentGroupSteps[group] >= index,
                                state: currentGroup >= group
                                    ? currentGroupSteps[group] >= index
                                        ? currentGroupSteps[group] == index
                                            ? StepState.indexed
                                            : q.hasResponded
                                                ? StepState.complete
                                                : StepState.error
                                        : StepState.disabled
                                    : StepState.disabled);
                          }).toList()));
                },
              )
            : Stepper(
                physics: const ClampingScrollPhysics(),
                currentStep: currentStep,
                controlsBuilder: (context, details) {
                  return controlsBuilder(
                      context, currentStep, 0, widget.outcomeMeasure,
                      onStepContinue: details.onStepContinue,
                      onStepCancel: details.onStepCancel);
                },
                onStepTapped: (step) {
                  setState(() {
                    currentStep = step;
                  });
                },
                onStepContinue: onStepContinue,
                onStepCancel: () {
                  setState(() {
                    currentStep > 0 ? currentStep -= 1 : null;
                  });
                },
                steps: widget.outcomeMeasure.questionCollection.questions
                    .asMap()
                    .entries
                    .map((entry) {
                  int index = entry.key;
                  Question q = entry.value;
                  // log.i(q);
                  return Step(
                      title: Container(
                        key: Key(index.toString()),
                        color: _selectedKey == index.toString()
                            ? CometColors.ttsColor
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(q.text, style: contentTextStyle)),
                            // if (currentStep == index)
                            //   IconButton(
                            //     onPressed: () {
                            //       _ttsService.speak(q.ttsText);
                            //       onSelectKey(index.toString());
                            //     },
                            //     icon: const Icon(Icons.volume_up),
                            //   )
                          ],
                        ),
                      ),
                      content: Container(
                          color: _selectedKey == index.toString()
                              ? CometColors.ttsColor
                              : Colors.transparent,
                          child: _getResponseTile(q)),
                      isActive: currentStep >= index,
                      state: currentStep >= index
                          ? currentStep == index
                              ? StepState.indexed
                              : widget.outcomeMeasure.questionCollection
                                      .questions[index].hasResponded
                                  ? StepState.complete
                                  : StepState.error
                          : StepState.disabled);
                }).toList()),
        if (_ttsService.ttsState == TtsState.playing)
          Positioned.fill(
              child: Listener(
            onPointerDown: (e) => _ttsService.stop(),
            child: Container(
              color: Colors.black.withOpacity(0),
            ),
          ))
      ],
    );
  }
}
