import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:biot/ui/common/app_colors.dart';
import 'package:biot/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'confirm_alert_dialog_model.dart';

class ConfirmAlertDialog extends StackedView<ConfirmAlertDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const ConfirmAlertDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  Widget builder(
    BuildContext context,
    ConfirmAlertDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
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
                    request.title ?? 'Hello Stacked Dialog!!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (request.description != null) ...[
                  verticalSpaceMedium,
                  Text(
                    request.description!,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    maxLines: 3,
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (request.secondaryButtonTitle != null)
                  ElevatedButton(
                    key: const Key('secondaryButton'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcBackgroundColor
                    ),
                    onPressed: () => completer(DialogResponse(
                      confirmed: true,
                    )),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 45.0, vertical: 10.0),
                        child: Text(
                          request.secondaryButtonTitle!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        )),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kcBackgroundColor
                  ),
                  onPressed: () => completer(DialogResponse(
                    confirmed: false,
                  )),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 45.0, vertical: 10.0),
                      child: Text(
                        request.mainButtonTitle!,
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
  ConfirmAlertDialogModel viewModelBuilder(BuildContext context) =>
      ConfirmAlertDialogModel();
}
