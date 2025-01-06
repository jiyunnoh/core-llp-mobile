import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/ui/common/ui_helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:stacked/stacked.dart';

import '../../../generated/locale_keys.g.dart';
import '../../../model/encounter.dart';
import 'complete_viewmodel.dart';

class CompleteView extends StackedView<CompleteViewModel> {
  final Encounter encounter;
  String? pdfPath;

  CompleteView(this.encounter, {super.key, this.pdfPath});

  Future<bool?> progressIndicatorAlert(CompleteViewModel viewModel, context) {
    return Alert(
        context: context,
        style: kAlertStyle,
        title: LocaleKeys.pdfGenProgressTitle.tr(),
        desc:
            "Your PDF report is being generated.\nThis may take up to 1 minute.",
        onWillPopActive: true,
        buttons: []).show();
  }

  @override
  Widget builder(
    BuildContext context,
    CompleteViewModel viewModel,
    Widget? child,
  ) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Congratulations!!\nYou have successfully completed collecting ${viewModel.currentPatient.id}\'s LEAD and COMPASS.\nPlease make sure the client\'s ID is written down.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
              ],
            ),
            verticalSpaceLarge,
            Column(
              children: [
                if (viewModel.encounter.prefix == EpisodePrefix.post)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: SizedBox(
                      width: 300,
                      height: kAlertButtonHeight,
                      child: ElevatedButton(
                          onPressed: viewModel.surveyForPatientTapped,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star),
                              horizontalSpaceSmall,
                              Expanded(
                                child: Text(
                                  'Client Survey',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18),
                                ),
                              )
                            ],
                          )),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SizedBox(
                    width: 300,
                    height: kAlertButtonHeight,
                    child: ElevatedButton(
                        onPressed: () async {
                          viewModel.onGenerateReportButtonTapped();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.ios_share_rounded),
                            horizontalSpaceSmall,
                            Expanded(
                              child: Text(
                                'Export Report',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          ],
                        )),
                  ),
                ),
                SizedBox(
                  width: 300,
                  height: kAlertButtonHeight,
                  child: ElevatedButton(
                      onPressed: viewModel.navigateToPatientList,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people),
                          horizontalSpaceSmall,
                          Expanded(
                            child: Text(
                              'Client List',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        ],
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  CompleteViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CompleteViewModel(encounter: encounter, pdfPath: pdfPath);
}
