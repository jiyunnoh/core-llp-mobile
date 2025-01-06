import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:biot/ui/common/app_colors.dart';
import 'package:biot/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'info_alert_dialog_model.dart';

class InfoAlertDialog extends StackedView<InfoAlertDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const InfoAlertDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  Widget builder(
    BuildContext context,
    InfoAlertDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    request.title!,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                verticalSpaceMedium,
                if (request.description != null)
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      request.description!,
                      style: const TextStyle(fontSize: 18),
                      maxLines: 3,
                      softWrap: true,
                    ),
                  ),
                if (request.data != null) Text(request.data)
              ],
            ),
            verticalSpaceMedium,
            ElevatedButton(
              onPressed: () => completer(DialogResponse(
                confirmed: true,
              )),
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 45.0, vertical: 10.0),
                  child: Text(
                    request.mainButtonTitle ?? 'Close',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  @override
  InfoAlertDialogModel viewModelBuilder(BuildContext context) =>
      InfoAlertDialogModel();
}
