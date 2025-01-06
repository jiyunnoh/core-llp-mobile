import 'package:biot/constants/compass_lead_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import '../../constants/amputation_info.dart';
import '../common/ui_helpers.dart';
import '../views/amputation_form/amputation_form_viewmodel.dart';

class AmputationCard extends StackedHookView<AmputationFormViewModel> {
  final int index;

  const AmputationCard({required this.index, super.key});

  Widget _buildSideOfAmputation(AmputationFormViewModel viewModel, int index) {
    return Row(
      children: [
        GestureDetector(
            onTap: () {
              viewModel.showInfoDialog(
                  title: 'Amputation Side',
                  body:
                      'Choose \'Hemicorporectomy\' if level of amputation is hemicorporectomy.');
            },
            child: Icon(key: Key('sideInfo_$index'), Icons.info_outline)),
        horizontalSpaceSmall,
        Expanded(
          child: DropdownButtonFormField(
            key: Key('sideDropDownMenu_$index'),
            hint: const Text('Side - Not Selected'),
            disabledHint: null,
            value: viewModel.amputations[index].side,
            items: viewModel.amputations[index].level ==
                    LevelOfAmputation.hemicorporectomy
                ? AmputationSide.values
                    .where(
                        (element) => element == AmputationSide.hemicorporectomy)
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e.displayName)))
                    .toList()
                : AmputationSide.values
                    .where(
                        (element) => element != AmputationSide.hemicorporectomy)
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e.displayName)))
                    .toList(),
            validator: (value) => value == null
                ? 'Amputation side is required'
                : viewModel.amputations
                            .where((element) => element.side == value)
                            .toList()
                            .length >
                        1
                    ? 'Amputation side must be distinct.'
                    : null,
            onChanged: (value) {
              viewModel.onChangeAmputationSide(index, value);
            },
            decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                filled: true,
                labelText:
                    viewModel.amputations[index].side != null ? 'Side' : null),
          ),
        ),
      ],
    );
  }

  Widget _buildDateOfAmputation(AmputationFormViewModel viewModel,
      BuildContext context, int index, TextEditingController controller) {
    return Row(
      children: [
        GestureDetector(
            onTap: () {
              viewModel.showInfoDialog(
                  title: 'Date of Amputation', body: 'If congenital, use DOB.');
            },
            child: Icon(key: Key('dateInfo_$index'), Icons.info_outline)),
        horizontalSpaceSmall,
        Expanded(
          child: TextFormField(
            key: Key('dateFormField_$index'),
            onTap: () async {
              DateTime? pickedDate = await _showDatePicker(context, viewModel);
              if (pickedDate != null) {
                viewModel.amputations[index].dateOfAmputation = pickedDate;
                controller.text =
                    viewModel.amputations[index].dateOfAmputationString!;
                viewModel.onChangeDateOfAmputation(index, pickedDate);
              }
            },
            readOnly: true,
            controller: controller,
            validator: (value) => value != null && value.isEmpty
                ? 'Date of amputation/limb absence is required'
                : null,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                filled: true,
                hintText: 'Date of Amputation',
                labelText: viewModel.amputations[index].dateOfAmputation != null
                    ? 'Date of Amputation'
                    : null),
            keyboardType: TextInputType.text,
          ),
        ),
        IconButton(
            onPressed: () async {
              DateTime? pickedDate = await _showDatePicker(context, viewModel);
              if (pickedDate != null) {
                viewModel.amputations[index].dateOfAmputation = pickedDate;
                controller.text =
                    viewModel.amputations[index].dateOfAmputationString!;
                viewModel.onChangeDateOfAmputation(index, pickedDate);
              }
            },
            icon: const Icon(Icons.date_range_rounded))
      ],
    );
  }

  Widget _buildCauseOfAmputation(AmputationFormViewModel viewModel, int index,
      TextEditingController controller) {
    if (viewModel.amputations[index].otherPrimaryCause != null) {
      controller.text = viewModel.amputations[index].otherPrimaryCause!;
    }
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
                onTap: () {
                  viewModel.showInfoDialog(
                      title: 'Primary Cause of Amputation',
                      body:
                          'Primary cause is the main predisposing reason for this amputation or limb absence.\n• Trauma includes acts of violence, accidents, injury etc.\n• Diabetes - micro-vascular.\n• Vascular - macro-vascular.\n• Cancer - Amputation to remove cancerous growth.\n• Infection - local or systemic infection.\n• Congenital difference - limb absence or difference from birth.\n• Other - any other primary causes of amputation.');
                },
                child: Icon(key: Key('causeInfo_$index'), Icons.info_outline)),
            horizontalSpaceSmall,
            Expanded(
              child: DropdownButtonFormField(
                key: Key('causeDropDownMenu_$index'),
                hint: const Text('Primary Cause - Not Selected'),
                disabledHint: null,
                value: viewModel.amputations[index].cause,
                items: CauseOfAmputation.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.displayName),
                        ))
                    .toList(),
                validator: (value) => value == null
                    ? 'Primary Cause of amputation is required'
                    : null,
                onChanged: (value) =>
                    viewModel.onChangeCauseOfAmputation(index, value),
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    filled: true,
                    labelText: viewModel.amputations[index].cause != null
                        ? 'Primary Cause'
                        : null),
              ),
            ),
          ],
        ),
        if (viewModel.amputations[index].cause == CauseOfAmputation.other)
          Padding(
            padding: const EdgeInsets.only(left: 35.0),
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Please specify',
              ),
              onChanged: (String? value) {
                viewModel.onChangeOtherCauseOfAmputation(index, value);
              },
              validator: (String? value) {
                return (value == null || value.isEmpty)
                    ? 'Please specify the primary cause of amputation'
                    : null;
              },
            ),
          )
      ],
    );
  }

  Widget _buildTypeOfAmputation(AmputationFormViewModel viewModel, int index) {
    return Row(
      children: [
        GestureDetector(
            onTap: () {
              viewModel.showInfoDialog(
                  title: 'Type of Amputation',
                  body:
                      '• Major amputation changes the bony level through or above a joint.\n• Bone revision does not progress to a higher named level through or above a more proximal joint and includes removal of bone spurs and changing of the contour of bone etc.\n• Soft tissue revision does not affect the bony anatomy but removes redundant or diseased soft tissue only.');
            },
            child: Icon(key: Key('typeInfo_$index'), Icons.info_outline)),
        horizontalSpaceSmall,
        Expanded(
          child: DropdownButtonFormField(
            key: Key('typeDropDownMenu_$index'),
            hint: const Text('Type - Not Selected'),
            disabledHint: null,
            value: viewModel.amputations[index].type,
            items: TypeOfAmputation.values
                .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e.displayName)))
                .toList(),
            validator: (value) =>
                value == null ? 'Type of amputation is required' : null,
            onChanged: (value) =>
                viewModel.onChangeTypeOfAmputation(index, value),
            decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                filled: true,
                labelText:
                    viewModel.amputations[index].type != null ? 'Type' : null),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelOfAmputation(AmputationFormViewModel viewModel, int index) {
    return Row(
      children: [
        GestureDetector(
            onTap: () {
              viewModel.showInfoDialog(
                  title: 'Level of Amputation',
                  body:
                      '• Trans tarsal amputations include Chopart, Pigoroff and Boyd variations.\n• If select Hemicorporectomy, amputation side should be bilateral.');
            },
            child: Icon(key: Key('levelInfo_$index'), Icons.info_outline)),
        horizontalSpaceSmall,
        Expanded(
          child: DropdownButtonFormField(
            key: Key('levelDropDownMenu_$index'),
            hint: const Text('Level - Not Selected'),
            disabledHint: null,
            value: viewModel.amputations[index].level,
            items: LevelOfAmputation.values
                .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e.displayName)))
                .toList(),
            validator: (value) => value == null
                ? 'Level of amputation is required'
                : viewModel.amputations.length == 2 &&
                        viewModel.amputations.any((element) =>
                            element.level == LevelOfAmputation.hemicorporectomy)
                    ? 'If a client has hemicorporectomy, please add only one amputation.'
                    : null,
            onChanged: (value) =>
                viewModel.onChangeLevelOfAmputation(index, value),
            decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                filled: true,
                labelText: viewModel.amputations[index].level != null
                    ? 'Level'
                    : null),
          ),
        ),
      ],
    );
  }

  Widget _buildAbilityToWalk(AmputationFormViewModel viewModel, int index) {
    return Row(
      children: [
        GestureDetector(
            onTap: () {
              viewModel.showInfoDialog(
                  title: 'Ability to Walk',
                  body:
                      'Walking defined as moving with or without walking aids while bearing weight on lower limbs.');
            },
            child: Icon(key: Key('abilityToWalkInfo_$index'), Icons.info_outline)),
        horizontalSpaceSmall,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Were you able to walk in the 3 months prior to your amputation?',
                style: episodeHeaderTextStyle,
              ),
              DropdownButtonFormField(
                key: Key('abilityToWalkDropDownMenu_$index'),
                hint: const Text('Ability to Walk - Not Selected'),
                disabledHint: null,
                value: viewModel.amputations[index].abilityToWalk,
                items: YesOrNo.values
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e.displayName)))
                    .toList(),
                validator: (value) => value == null ? 'Required field' : null,
                onChanged: (value) =>
                    viewModel.onChangeAbilityToWalk(index, value),
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  filled: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future _showDatePicker(
      BuildContext context, AmputationFormViewModel viewModel) async {
    DateTime now = DateTime.now();
    return showDatePicker(
        context: context,
        keyboardType: TextInputType.text,
        initialDate: viewModel.amputations[index].dateOfAmputation ?? now,
        firstDate: DateTime(DateTime.now().year - 120),
        lastDate: now,
        builder: (context, child) {
          return Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                      onSurface: Colors.black),
                  textButtonTheme: TextButtonThemeData(
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.black))),
              child: child!);
        });
  }

  @override
  Widget builder(BuildContext context, AmputationFormViewModel model) {
    final dateOfAmputation = useTextEditingController(
        text: model.amputations[index].dateOfAmputationString);
    final otherPrimaryCause = useTextEditingController(
        text: model.amputations[index].otherPrimaryCause);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Column(
            children: [
              Column(
                children: [
                  _buildLevelOfAmputation(model, index),
                  verticalSpaceSmall,
                  _buildSideOfAmputation(model, index),
                  verticalSpaceSmall,
                  _buildDateOfAmputation(
                      model, context, index, dateOfAmputation),
                  verticalSpaceSmall,
                  _buildCauseOfAmputation(model, index, otherPrimaryCause),
                  verticalSpaceSmall,
                  _buildTypeOfAmputation(model, index),
                  verticalSpaceSmall,
                  _buildAbilityToWalk(model, index),
                ],
              ),
              verticalSpaceSmall,
              if (model.amputations.length == 2 && model.isEdit == false)
                GestureDetector(
                  onTap: () {
                    model.removeAmputation(index);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      horizontalSpaceTiny,
                      Text(
                        key: Key('removeAmputation_$index'),
                        'Remove',
                        style: const TextStyle(color: Colors.red),
                      )
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
