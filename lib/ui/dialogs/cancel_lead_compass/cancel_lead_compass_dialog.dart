import 'package:flutter/material.dart';
import 'package:biot/ui/common/app_colors.dart';
import 'package:biot/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'cancel_lead_compass_dialog_model.dart';

const double _graphicSize = 60;

class CancelLeadCompassDialog
    extends StackedView<CancelLeadCompassDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const CancelLeadCompassDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CancelLeadCompassDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
      key: const Key('cancelLeadCompassDialog'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    viewModel.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                verticalSpaceMedium,
                  Text(
                    viewModel.description,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    maxLines: 3,
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                ],
            ),
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red
                  ),
                  onPressed: () => completer(DialogResponse(
                    confirmed: true,
                  )),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 45.0, vertical: 10.0),
                      child: Text(
                        viewModel.secondaryButtonTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      )),
                ),
                ElevatedButton(
                  onPressed: () => completer(DialogResponse(confirmed: false)),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 45.0, vertical: 10.0),
                      child: Text(
                        viewModel.mainButtonTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onViewModelReady(CancelLeadCompassDialogModel viewModel) {
    viewModel.onModelReady();
  }

  @override
  CancelLeadCompassDialogModel viewModelBuilder(BuildContext context) =>
      CancelLeadCompassDialogModel();
}
