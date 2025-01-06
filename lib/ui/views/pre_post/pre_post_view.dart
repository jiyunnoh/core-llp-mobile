import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/model/pre_post_episode_of_care.dart';
import 'package:biot/ui/common/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../constants/compass_lead_info.dart';
import '../../../generated/locale_keys.g.dart';
import '../../../model/encounter.dart';
import '../../common/ui_helpers.dart';
import 'pre_post_viewmodel.dart';

class PrePostView extends StackedView<PrePostViewModel> {
  final Encounter encounter;
  final bool isEdit;
  final Function(PrePostEpisodeOfCare)? onUpdate;

  const PrePostView(this.encounter,
      {super.key, required this.isEdit, this.onUpdate});

  @override
  Widget builder(
    BuildContext context,
    PrePostViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${viewModel.encounter.prefix!.displayName} Episode of Care'),
          leading: viewModel.isEdit
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: viewModel.navigateBack,
                )
              : IconButton(
            key: const Key('backButton'),
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: viewModel.onCancelDataCollection,
                )),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 46.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateOfCare(viewModel, context),
                  _buildMobilityDevices(viewModel),
                  if (viewModel.mobilityDevices
                              .where((element) => element == true)
                              .length >
                          1 ||
                      (viewModel.mobilityDevices
                                  .where((element) => element == true)
                                  .length ==
                              1 &&
                          viewModel.mobilityDevices[0] == false))
                    _buildMobilityDeviceUsages(viewModel),
                  _buildParticipation(viewModel),
                  _buildParticipationWithLimb(viewModel),
                  _buildAbilityToWork(viewModel),
                  _buildAbilityToWorkWithLimb(viewModel),
                  _buildStandingTime(viewModel),
                  _buildWalkingTime(viewModel),
                  _buildFall(viewModel),
                  if (viewModel.prePostEpisodeOfCare.fall == YesOrNo.yes)
                    _buildInjuriousFall(viewModel),
                  _buildSupportAtHome(viewModel),
                  if (viewModel.prePostEpisodeOfCare.socialSupportAccess ==
                      YesOrNo.yes)
                    _buildUtilizeSupport(viewModel),
                  _buildCommunityService(viewModel),
                  if (viewModel.prePostEpisodeOfCare.communityServiceAccess ==
                      YesOrNo.yes)
                    _buildCommunityServiceOptions(viewModel)
                ],
              ),
            ),
          )),
          GestureDetector(
              onTap: isEdit
                  ? viewModel.isModified
                      ? () {
                          onUpdate!(viewModel.prePostEpisodeOfCare);
                          viewModel.navigateBack();
                        }
                      : null
                  : () => viewModel.navigateToEvaluationView(),
              child: Container(
                key: const Key('updateButton'),
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
              ))
        ],
      ),
    );
  }

  Widget _buildCommunityServiceOptions(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 38,
              ),
              Expanded(
                child: Text(
                  'Where do you utilize services from?',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('serviceOption'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: viewModel.prePostEpisodeOfCare.communityService,
                    items: CommunityService.values
                        .map((e) => DropdownMenuItem(
                            key: Key('serviceOption_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) =>
                        viewModel.onChangeCommunityServiceOptions(
                            CommunityService.fromType(value!.type)),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityService(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('accessToService_info'),
                  onPressed: () => viewModel.showInfoDialog(
                      title: 'Community Support', body: sectionY_2),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                  child: Text(
                'Do you have access to organized community services?',
                style: episodeHeaderTextStyle,
              )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('accessToService'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value:
                        viewModel.prePostEpisodeOfCare.communityServiceAccess,
                    items: YesOrNo.values
                        .map((e) => DropdownMenuItem(
                            key: Key('accessToService_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) => viewModel.onChangeCommunityService(
                        YesOrNo.fromType(value!.type)),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilizeSupport(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 38,
              ),
              Expanded(
                child: Text(
                  'Do you utilize assistance of family and social support?',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('utilizeSupport'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: viewModel.prePostEpisodeOfCare.socialSupportUtil,
                    items: YesOrNo.values
                        .map((e) => DropdownMenuItem(
                            key: Key('utilizeSupport_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) => viewModel
                        .onChangeUtilizeSupport(YesOrNo.fromType(value!.type)),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportAtHome(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('supportAtHome_info'),
                  onPressed: () => viewModel.showInfoDialog(
                      title: 'Social Support', body: sectionY_1),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: Text(
                  'Do you have access to family and social support and assistance at home?',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('supportAtHome'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: viewModel.prePostEpisodeOfCare.socialSupportAccess,
                    items: YesOrNo.values
                        .map((e) => DropdownMenuItem(
                            key: Key('supportAtHome_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) => viewModel
                        .onChangeSupportAtHome(YesOrNo.fromType(value!.type)),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInjuriousFall(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('injuriousFall_info'),
                  onPressed: () =>
                      viewModel.showInfoDialog(title: 'Fall', body: sectionX_2),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                  child: Text(
                'Has fall resulted in an injury?',
                style: episodeHeaderTextStyle,
              )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('injuriousFall'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: viewModel.prePostEpisodeOfCare.isInjuriousFall,
                    items: YesOrNo.values
                        .map((e) => DropdownMenuItem(
                            key: Key('injuriousFall_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) =>
                        viewModel.onChangeInjury(YesOrNo.fromType(value!.type)),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFall(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('fall_info'),
                  onPressed: () =>
                      viewModel.showInfoDialog(title: 'Fall', body: sectionX_1),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                  child: Text(
                'Do you on occasion fall?',
                style: episodeHeaderTextStyle,
              )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('fall'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: viewModel.prePostEpisodeOfCare.fall,
                    items: YesOrNo.values
                        .map((e) => DropdownMenuItem(
                            key: Key('fall_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) =>
                        viewModel.onChangeFall(YesOrNo.fromType(value!.type)),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (viewModel.prePostEpisodeOfCare.fall == YesOrNo.yes)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 38,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      key: const Key('fallFrequency'),
                      hint: const Text('Fall frequency - Not Selected'),
                      disabledHint: null,
                      value: viewModel.prePostEpisodeOfCare.fallFrequency,
                      items: FallFrequency.values
                          .map((e) => DropdownMenuItem(
                              key: Key('fallFrequency_${e.displayName}'),
                              value: e,
                              child: Text(e.displayName)))
                          .toList(),
                      onChanged: (value) => viewModel.onChangeFallFrequency(
                          FallFrequency.fromType(value!.type)),
                      decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.transparent)),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          filled: true,
                          labelText:
                              viewModel.prePostEpisodeOfCare.fallFrequency !=
                                      null
                                  ? 'Fall frequency'
                                  : null),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWalkingTime(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 38,
              ),
              Expanded(
                child: Text(
                  'How many hours do you spend walking in a normal day?',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('walkingTime'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: viewModel.prePostEpisodeOfCare.walkingTimeInHour,
                    items: AmbulatoryActivityLevel.values
                        .map((e) => DropdownMenuItem(
                            key: Key('walkingTime_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) => viewModel.onChangeWalkingTime(
                        AmbulatoryActivityLevel.fromType(value!.type)),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingTime(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 38,
              ),
              Expanded(
                child: Text(
                  'How many hours do you spend standing in a normal day?',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('standingTime'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: viewModel.prePostEpisodeOfCare.standingTimeInHour,
                    items: AmbulatoryActivityLevel.values
                        .map((e) => DropdownMenuItem(
                            key: Key('standingTime_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) => viewModel.onChangeStandingTime(
                        AmbulatoryActivityLevel.fromType(value!.type)),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilityToWorkWithLimb(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('abilityToWorkWithLimb_info'),
                  onPressed: () => viewModel.showInfoDialog(
                      title: 'Ability to Work', body: sectionV),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: Text(
                  'Relative to someone without limb loss in similar circumstances but without limb absence, how do you currently rate your problems participating in the formal or informal labour market if given the opportunity?',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('abilityToWorkWithLimb'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: viewModel.prePostEpisodeOfCare.abilityToWorkWithLimb,
                    items: IcfQualifiers.values
                        .map((e) => DropdownMenuItem(
                            key: Key('abilityToWorkWithLimb_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) =>
                        viewModel.onChangeAbilityToWorkWithLimb(
                            IcfQualifiers.fromType(value!.type)),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilityToWork(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('abilityToWork_info'),
                  onPressed: () => viewModel.showInfoDialog(
                      title: 'Ability to Work', body: sectionV),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: Text(
                  'Relative to your own expectations, how do you currently rate your problems participating in the formal or informal labour market if given the opportunity?',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('abilityToWork'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: viewModel.prePostEpisodeOfCare.abilityToWork,
                    items: IcfQualifiers.values
                        .map((e) => DropdownMenuItem(
                            key: Key('abilityToWork_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) => viewModel.onChangeAbilityToWork(
                        IcfQualifiers.fromType(value!.type)),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipationWithLimb(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('participationWithLimb_info'),
                  onPressed: () => viewModel.showInfoDialog(
                      title: 'Participation', body: sectionU),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: Text(
                  'Relative to someone without limb loss in similar circumstances but without lower limb absence, how do you currently rate your problems participating in your community?',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('participationWithLimb'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: viewModel
                        .prePostEpisodeOfCare.communityParticipationWithLimb,
                    items: IcfQualifiers.values
                        .map((e) => DropdownMenuItem(
                            key: Key('participationWithLimb_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) =>
                        viewModel.onChangeParticipationWithLimb(
                            IcfQualifiers.fromType(value!.type)),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipation(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('participation_info'),
                  onPressed: () => viewModel.showInfoDialog(
                      title: 'Participation', body: sectionU),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: Text(
                  'Relative to your own expectations, how do you currently rate your problems participating in the community?',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('participation'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value:
                        viewModel.prePostEpisodeOfCare.communityParticipation,
                    items: IcfQualifiers.values
                        .map((e) => DropdownMenuItem(
                            key: Key('participation_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) => viewModel.onChangeParticipation(
                        IcfQualifiers.fromType(value!.type)),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilityDeviceUsages(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 38,
              ),
              Expanded(
                child: Text(
                  'How much do you use these walking aids in a normal day?',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          Column(
            children: viewModel.mobilityDevices.asMap().entries.map((e) {
              int i = e.key;
              if (i != 0 && viewModel.mobilityDevices[i]) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 38,
                      ),
                      Expanded(
                        child: DropdownButtonFormField(
                          key: Key('mobilityDevices_${i}_usage'),
                          hint: Text(
                            '${MobilityDevice.values[i].displayName} - Not Selected',
                          ),
                          disabledHint: null,
                          value: viewModel
                              .prePostEpisodeOfCare.mobilityDeviceUsages[i],
                          items: MobilityDeviceUsage.values
                              .map((e) => DropdownMenuItem(
                            key: Key('mobilityDevices_${i}_usage_${e.displayName}'),
                                  value: e, child: Text(e.displayName)))
                              .toList(),
                          onChanged: (value) =>
                              viewModel.onChangeMobilityDeviceUsage(
                                  i, MobilityDeviceUsage.fromType(value!.type)),
                          decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent)),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              filled: true,
                              labelText: viewModel.prePostEpisodeOfCare
                                          .mobilityDeviceUsages[i] !=
                                      null
                                  ? MobilityDevice.values[i].displayName
                                  : null),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilityDevices(PrePostViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('mobilityDevices_info'),
                  onPressed: () => viewModel.showInfoDialog(
                      title: 'Use of Mobility Devices', body: sectionT),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: Text(
                  'Please select the walking aids and other mobility devices that you have.',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: MobilityDevice.values.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () => viewModel.onChangeMobilityDevices(index),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 38,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            MobilityDevice.values[index].displayName,
                            style: episodeOptionsTextStyle,
                          ),
                          Checkbox(
                              key: Key('mobilityDevices_$index'),
                              value: viewModel.mobilityDevices[index],
                              onChanged: (bool? value) =>
                                  viewModel.onChangeMobilityDevices(index))
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              indent: 38,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfCare(PrePostViewModel viewModel, BuildContext context) {
    String title = viewModel.encounter.prefix == EpisodePrefix.pre
        ? 'Date of commencement of rehab care'
        : 'Date of completion of rehab care';
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('dateOfCare_info'),
                  onPressed: () =>
                      viewModel.showInfoDialog(title: 'Date of Rehabilitation Care', body: sectionS),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                  child: Text(
                title,
                style: episodeHeaderTextStyle,
              )),
            ],
          ),
          Row(
            children: [
              const SizedBox(
                width: 38,
              ),
              Expanded(
                child: TextFormField(
                  key: const Key('dateOfCare'),
                  onTap: () async {
                    viewModel.pickedDate =
                        await _showDatePicker(context, viewModel);
                    if (viewModel.pickedDate != null) {
                      viewModel.onChangeDateOfCare();
                    }
                  },
                  readOnly: true,
                  controller: viewModel.dateController,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    filled: true,
                    hintText: 'Date of Rehabilitation care',
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                    key: const Key('dateOfCare'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      viewModel.pickedDate =
                          await _showDatePicker(context, viewModel);
                      if (viewModel.pickedDate != null) {
                        viewModel.onChangeDateOfCare();
                      }
                    },
                    icon: const Icon(Icons.date_range_rounded)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future _showDatePicker(
      BuildContext context, PrePostViewModel viewModel) async {
    DateTime now = DateTime.now();
    return showDatePicker(
        context: context,
        keyboardType: TextInputType.text,
        initialDate: viewModel.pickedDate == null ? now : viewModel.pickedDate!,
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
  PrePostViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PrePostViewModel(encounter: encounter, isEdit: isEdit);
}
