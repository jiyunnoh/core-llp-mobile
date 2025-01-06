import 'package:biot/model/outcome_measures/outcome_measure.dart';
import 'package:flutter/material.dart';

import '../common/ui_helpers.dart';

class OutcomeMeasureInfo extends StatelessWidget {
  final OutcomeMeasure outcomeMeasure;
  const OutcomeMeasureInfo(this.outcomeMeasure, {super.key});

  Widget _buildInfoItem(String header, String body) {
    Widget bodyWidget;
    if (body.contains("{img")) {
      List<String> s = body.split("|*|");
      bodyWidget = Column(
          children: s.map((e) {
        //TODO: parse {img:} tag properly to create image dynamically.
        if (e.contains("{img:")) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Image.asset(
                "packages/comet_foundation/images/${outcomeMeasure.info.images![0]}.png"),
          );
        } else {
          return Text(e, style: const TextStyle(fontSize: 16));
        }
      }).toList());
    } else {
      bodyWidget = Text(body,
          style: const TextStyle(
            fontSize: 16,
          ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        verticalSpaceTiny,
        bodyWidget,
        verticalSpaceMedium
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildInfoItem('Overview', outcomeMeasure.info.overview),
        _buildInfoItem('Population', outcomeMeasure.info.population),
        _buildInfoItem('Equipment', outcomeMeasure.info.equipment),
        _buildInfoItem('Instructions', outcomeMeasure.info.instructions),
        _buildInfoItem(
            'Score Calculation', outcomeMeasure.info.scoreCalculation),
        _buildInfoItem(
            'Score Interpretation', outcomeMeasure.info.scoreInterpretation),
        _buildInfoItem('MCID MDC', outcomeMeasure.info.mcidMdc),
        _buildInfoItem('References', outcomeMeasure.info.references),
      ],
    );
  }
}
