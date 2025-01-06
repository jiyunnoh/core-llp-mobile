import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'loading_indicator_dialog_model.dart';

class LoadingIndicatorDialog extends StackedView<LoadingIndicatorDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const LoadingIndicatorDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  Widget builder(
    BuildContext context,
    LoadingIndicatorDialogModel viewModel,
    Widget? child,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
        ),
        const CircularProgressIndicator(
          backgroundColor: Colors.black,
          color: Colors.white,
        )
      ],
    );
  }

  @override
  LoadingIndicatorDialogModel viewModelBuilder(BuildContext context) =>
      LoadingIndicatorDialogModel();
}
