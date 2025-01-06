import 'package:biot/ui/common/app_colors.dart';
import 'package:biot/ui/widgets/outcome%20measure%20widgets/tminwt_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:stacked/stacked.dart';

import '../../../generated/locale_keys.g.dart';
import '../../../model/encounter.dart';
import '../../../model/outcome_measures/outcome_measure.dart';
import '../../common/ui_helpers.dart';
import '../../widgets/outcome measure widgets/evaluation.dart';
import '../../widgets/outcome measure widgets/tug_timer.dart';
import 'evaluation_viewmodel.dart';

class EvaluationView extends StackedView<EvaluationViewModel> {
  final Encounter encounter;

  const EvaluationView(this.encounter, {super.key});

  Widget _getEvaluation(OutcomeMeasure outcomeMeasure) {
    switch (outcomeMeasure.id) {
      case 'tug':
        return TugTimer(
            key: Key(outcomeMeasure.id), outcomeMeasure: outcomeMeasure);
      case 'tminwt':
        return TminwtView(
            key: Key(outcomeMeasure.id), outcomeMeasure: outcomeMeasure);
      default:
        return Evaluation(
            key: Key(outcomeMeasure.id), outcomeMeasure: outcomeMeasure);
    }
  }

  void optionalIncompleteAlert(context, Function finished) {
    Alert(
      context: context,
      style: kAlertStyle,
      title: LocaleKeys.incomplete.tr(),
      desc: LocaleKeys.incompleteDesc.tr(),
      buttons: [
        DialogButton(
          height: kAlertButtonHeight,
          color: kcBackgroundColor,
          radius: BorderRadius.circular(kAlertButtonHeight/2),
          onPressed: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: const Text(
              LocaleKeys.back,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ).tr(),
          ),
        ),
        DialogButton(
          height: kAlertButtonHeight,
          color: kcBackgroundColor,
          radius: BorderRadius.circular(kAlertButtonHeight/2),
          onPressed: () {
            Navigator.pop(context);
            finished();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: const Text(
              LocaleKeys.yesFinished,
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ).tr(),
          ),
        ),
      ],
    ).show();
  }

  @override
  Widget builder(
    BuildContext context,
    EvaluationViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: viewModel.isBusy
            ? const Text('Starting Evaluations...')
            : Text(viewModel.getCurrentOutcomeName()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: viewModel.onBackButtonTapped,
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // viewModel.stopTts();
                viewModel.isBusy ? null : viewModel.navigateToInfo();
              })
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          viewModel.isBusy
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        flex: 1,
                        child: _getEvaluation(viewModel.currentOutcomeMeasure)),
                    GestureDetector(
                        onTap: () {
                          // viewModel.stopTts();
                          if (viewModel.currentOutcomeMeasure.canProceed()) {
                            if (viewModel.currentOutcomeMeasure.isComplete) {
                              //User completed all required questionnaire
                              viewModel.nextOutcome();
                            } else {
                              //User didn't complete all questionnaire but it was optional
                              //Prompt the user to encourage them to complete all questionnaire
                              optionalIncompleteAlert(
                                  context, viewModel.nextOutcome);
                            }
                          } else {
                            if (viewModel.currentOutcomeMeasure.id == 'tug' ||
                                viewModel.currentOutcomeMeasure.id == 'fsst') {
                              //Prompt the user to complete the timer based outcome measure
                              var timerDesc = LocaleKeys.timeTrialRequired.tr();
                              // incompleteAlert(context, timerDesc);
                            } else if (viewModel.currentOutcomeMeasure.id ==
                                '10mwt') {
                              String errorDescription =
                                  LocaleKeys.timeTrialRequired.tr();
                              if (viewModel
                                      .currentOutcomeMeasure.questionCollection
                                      .getQuestionById('10mwt_6')
                                      ?.value ==
                                  null) {
                                errorDescription =
                                    LocaleKeys.assistanceLevelRequired.tr();
                              } else if (viewModel
                                      .currentOutcomeMeasure.questionCollection
                                      .getQuestionById('10mwt_7')
                                      ?.value ==
                                  null) {
                                errorDescription =
                                    LocaleKeys.distanceRequired.tr();
                              }
                              // incompleteAlert(context, errorDescription);
                            } else {
                              //Prompt the user to complete the required outcome measure
                              var defaultDesc =
                                  LocaleKeys.questionsRequired.tr();
                              // incompleteAlert(context, defaultDesc);
                            }
                          }
                        },
                        child: Container(
                          height: kAlertButtonHeight,
                          width: double.infinity,
                          color: kcBackgroundColor,
                          child: Center(
                              child: viewModel.currentOutcomeIdx ==
                                      viewModel.outcomeMeasures.length - 1
                                  ? Text(
                                      LocaleKeys.finish,
                                      style: buttonTextStyle,
                                    ).tr()
                                  : Text(LocaleKeys.next,
                                          style: buttonTextStyle)
                                      .tr()),
                        ))
                  ],
                ),
          // if (viewModel.isDictionaryOpen) DictionaryTile()
        ],
      ),
    );
  }

  @override
  EvaluationViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      EvaluationViewModel(encounter: encounter);

  @override
  void onViewModelReady(EvaluationViewModel viewModel) {
    viewModel.initState();
  }
}
