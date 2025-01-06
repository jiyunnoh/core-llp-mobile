import 'package:biot/ui/views/lead_form/lead_form_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../model/patient.dart';
import 'add_lead_viewmodel.dart';

class AddLeadView extends StackedView<AddLeadViewModel> {
  final bool isEdit;
  final Patient? patient;
  final Function(Patient patient) onClickedDone;

  const AddLeadView(this.onClickedDone,
      {super.key, this.isEdit = false, this.patient});

  @override
  Widget builder(
    BuildContext context,
    AddLeadViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(patient != null ? 'Edit Client' : 'Add New Client'),
      ),
      body: LeadFormView(
        onClickedDone,
        isEdit: isEdit,
        patient: patient,
      ),
    );
  }

  @override
  AddLeadViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AddLeadViewModel();
}
