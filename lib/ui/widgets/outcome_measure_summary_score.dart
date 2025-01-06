import 'package:biot/constants/enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';

import '../../model/outcome_measures/outcome_measure.dart';
import '../common/ui_helpers.dart';
import '../views/summary/summary_viewmodel.dart';

class OutcomeScore extends ViewModelWidget<SummaryViewModel> {
  final OutcomeMeasure outcomeMeasure;
  const OutcomeScore(this.outcomeMeasure, {super.key});
  @override
  Widget build(BuildContext context, SummaryViewModel viewModel) {
    List<String> scores = [''];
    if (outcomeMeasure.totalScore.isNotEmpty) {
      scores.clear();
      outcomeMeasure.totalScore.forEach((key, value) {
        if(value == CompletionStatus.incomplete.code.toString()){
          scores.add(CompletionStatus.incomplete.displayName);
        }else{
          scores.add(value);
        }
      });
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            outcomeMeasure.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Column(
            children: scores
                .asMap()
                .entries
                .map((e) => Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(outcomeMeasure.getSummaryScoreTitle(e.key),
                              style: contentTextStyle),
                          Text(
                            e.value,
                            style: contentTextStyle,
                          )
                        ],
                      ),
                    ))
                .toList())
      ],
    );
  }
}
