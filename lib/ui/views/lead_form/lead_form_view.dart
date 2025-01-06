import 'package:biot/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../constants/sex_at_birth.dart';
import '../../../model/patient.dart';
import '../../common/ui_helpers.dart';
import 'lead_form_viewmodel.dart';

class LeadFormView extends StackedView<LeadFormViewModel> {
  final bool isEdit;
  final Patient? patient;
  final Function(Patient patient) onClickedDone;

  const LeadFormView(this.onClickedDone,
      {super.key, this.isEdit = false, this.patient});

  @override
  Widget builder(
    BuildContext context,
    LeadFormViewModel viewModel,
    Widget? child,
  ) {
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildPatientInfo(viewModel, context),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () async {
                    viewModel.formValidated();
                  },
                  child: Text(
                    isEdit ? 'Update' : 'Add',
                    style: navigatorButtonStyle,
                  )),
            ),
          ],
        ));
  }

  Column buildPatientInfo(LeadFormViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        verticalSpaceSmall,
        _buildDob(viewModel, context),
        const Divider(
          indent: 10,
        ),
        verticalSpaceSmall,
        _buildSexAtBirth(viewModel)
      ],
    );
  }

  Widget _buildDob(LeadFormViewModel viewModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(viewModel.birthYearHeader),
        verticalSpaceSmall,
        SizedBox(
            height: 200,
            child: GridView.count(
              controller: viewModel.yearController,
              childAspectRatio: 3.0,
              crossAxisCount: 3,
              scrollDirection: Axis.vertical,
              children: List.generate(
                  100,
                  (index) => ChoiceChip(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        label: Text((viewModel.startYear + index).toString()),
                        labelStyle: TextStyle(
                            color: viewModel.birthYear == index
                                ? Colors.white
                                : Colors.black),
                        selected: viewModel.birthYear == index,
                        onSelected: (value) {
                          viewModel.onChangeBirthYear(value, index);
                        },
                        pressElevation: 0.0,
                        selectedColor: kcBackgroundColor,
                    showCheckmark: false,
                      )),
            )),
      ],
    );
  }

  Widget _buildSexAtBirth(LeadFormViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(viewModel.sexHeader),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: SexAtBirth.values
              .where((e) => e != SexAtBirth.unknown)
              .map((e) => ChoiceChip(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    label: Text(e.displayName),
                    labelStyle: TextStyle(
                        color: viewModel.selectedSexAtBirth == e
                            ? Colors.white
                            : Colors.black),
                    selected: viewModel.selectedSexAtBirth == e,
                    onSelected: (value) {
                      viewModel.onChangeSexAtBirth(value, e);
                    },
                    pressElevation: 0.0,
                    selectedColor: kcBackgroundColor,
            showCheckmark: false,
                  ))
              .toList(),
        ),
      ],
    );
  }

  @override
  LeadFormViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LeadFormViewModel(onClickedDone, isEdit: isEdit, patient: patient);
}
