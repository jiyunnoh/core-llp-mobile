import 'package:biot/ui/common/app_colors.dart';
import 'package:biot/ui/views/lead_form/lead_form_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../model/patient.dart';
import '../../common/ui_helpers.dart';
import 'add_lead_dialog_viewmodel.dart';

class AddLeadDialogView extends StackedView<AddLeadDialogViewModel> {
  final bool isEdit;
  final Patient? patient;
  final Function(Patient patient) onClickedDone;

  const AddLeadDialogView(this.onClickedDone,
      {super.key, this.isEdit = false, this.patient});

  @override
  Widget builder(
    BuildContext context,
    AddLeadDialogViewModel viewModel,
    Widget? child,
  ) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      title: Container(
          color: kcBackgroundColor,
          height: kAlertButtonHeight,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    )),
              ),
              Expanded(
                flex: 8,
                child: Text(
                  patient != null ? 'Edit Client' : 'Add New Client',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer()
            ],
          )),
      content: SizedBox(
          width: 650,
          height: 400,
          child: LeadFormView(onClickedDone, isEdit: isEdit, patient: patient)),
    );
  }

  @override
  AddLeadDialogViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AddLeadDialogViewModel();
}
