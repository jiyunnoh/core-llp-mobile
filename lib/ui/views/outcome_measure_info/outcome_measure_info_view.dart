import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:stacked/stacked.dart';

import '../../../model/outcome_measures/outcome_measure.dart';
import '../../widgets/outcome_measure_info.dart';
import 'outcome_measure_info_viewmodel.dart';

class OutcomeMeasureInfoView extends StackedView<OutcomeMeasureInfoViewModel> {
  const OutcomeMeasureInfoView({super.key});

  @override
  Widget builder(
    BuildContext context,
    OutcomeMeasureInfoViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Device.get().isTablet
              ? Text(viewModel.getCurrentOutcomeName())
              : Text(viewModel.outcomeMeasure.shortName),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: OutcomeMeasureInfo(viewModel.outcomeMeasure),
        ));
  }

  @override
  OutcomeMeasureInfoViewModel viewModelBuilder(
    BuildContext context,
  ) {
    final OutcomeMeasure arguments =
        ModalRoute.of(context)!.settings.arguments as OutcomeMeasure;
    return OutcomeMeasureInfoViewModel(outcomeMeasure: arguments);
  }
}
