import 'package:biot/constants/amputation_info.dart';
import 'package:biot/ui/common/app_colors.dart';
import 'package:biot/ui/widgets/amputation_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../generated/locale_keys.g.dart';
import '../../../model/encounter.dart';
import '../../common/ui_helpers.dart';
import 'amputation_form_viewmodel.dart';

class AmputationFormView extends StackedView<AmputationFormViewModel> {
  final Encounter? encounter;
  final bool isEdit;
  //set this flag to true if cloud should be updated when 'Update' button is tapped.
  final bool shouldUpdateCloud;

  const AmputationFormView(
      {super.key,
      this.encounter,
      required this.isEdit,
      this.shouldUpdateCloud = false});

  Widget _buildNextButton(AmputationFormViewModel viewModel) {
    return GestureDetector(
        onTap: viewModel.isEdit
            ? viewModel.isModified
                ? viewModel.validateForm
                : null
            : viewModel.validateForm,
        child: Container(
          key: const Key('nextUpdateButton'),
          height: kAlertButtonHeight,
          width: double.infinity,
          color: isEdit
              ? viewModel.isModified
                  ? kcBackgroundColor
                  : Colors.grey
              : kcBackgroundColor,
          child: Center(
              child: Text(isEdit ? 'Update' : LocaleKeys.next,
                      style: buttonTextStyle)
                  .tr()),
        ));
  }

  Widget _buildAddOtherSideButton(AmputationFormViewModel viewModel) {
    return Column(
      children: [
        if(viewModel.isEdit == false)
        const Text(
          'Attention: If the client has bilateral amputations,\n enter information for the other side NOW by clicking the button below.',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        ElevatedButton(
            onPressed: viewModel.createNewAmputation,
            child: const Text('Add Other Side')),
      ],
    );
  }

  @override
  Widget builder(
    BuildContext context,
    AmputationFormViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amputation'),
        leading: viewModel.isEdit
            ? IconButton(
                key: const Key('closeButton'),
                icon: const Icon(Icons.close),
                onPressed: viewModel.navigateBack,
              )
            : IconButton(
                key: const Key('backButton'),
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: viewModel.onCancelDataCollection,
              ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: viewModel.amputationFormKey,
                child: Column(children: [
                  if (viewModel.amputations.isNotEmpty)
                    const AmputationCard(index: 0),
                  if (viewModel.amputations.length == 2)
                    const AmputationCard(index: 1),
                  if (viewModel.amputations.length < 2 &&
                      viewModel.amputations.every((element) =>
                          element.level !=
                          LevelOfAmputation.hemicorporectomy) &&
                      (!isEdit || viewModel.isAmputationUpdate))
                    _buildAddOtherSideButton(viewModel)
                ]),
              ),
            ),
          ),
          _buildNextButton(viewModel)
        ],
      ),
    );
  }

  @override
  AmputationFormViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AmputationFormViewModel(
          encounter: encounter,
          isEdit: isEdit,
          isAmputationUpdate: shouldUpdateCloud);
}
