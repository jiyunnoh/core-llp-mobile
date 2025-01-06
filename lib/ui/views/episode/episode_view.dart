import 'package:biot/model/episode_of_care.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../generated/locale_keys.g.dart';
import '../../../model/encounter.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../widgets/episode_page1.dart';
import '../../widgets/episode_page2.dart';
import 'episode_viewmodel.dart';

class EpisodeView extends StackedView<EpisodeViewModel> {
  final Encounter encounter;
  final bool isEdit;
  final Function(EpisodeOfCare)? onUpdate;

  const EpisodeView(this.encounter,
      {super.key, required this.isEdit, this.onUpdate});

  @override
  Widget builder(
    BuildContext context,
    EpisodeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              'Episode of Rehabilitation Care (${viewModel.isLastPage ? '2' : '1'}/2)'),
          leading: viewModel.isEdit
              ? viewModel.isLastPage
                  ? IconButton(
                      key: const Key('backButton'),
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: viewModel.onBackButtonTapped,
                    )
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: viewModel.navigateBack,
                    )
              : IconButton(
                  key: const Key('backButton'),
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: viewModel.onBackButtonTapped,
                )),
      body: Column(
        children: [
          viewModel.isLastPage
              ? Page2(
                  episodeOfCare: viewModel.episodeOfCare,
                  isEdit: viewModel.isEdit,
                  onChange: (value) => viewModel.onChange(value))
              : Page1(
                  episodeOfCare: viewModel.episodeOfCare,
                  isEdit: viewModel.isEdit,
                  onChange: (value) => viewModel.onChange(value)),
          isEdit ? buildUpdateButton(viewModel) : buildNextButton(viewModel)
        ],
      ),
    );
  }

  Widget buildNextButton(EpisodeViewModel viewModel) {
    return GestureDetector(
        onTap: () => viewModel.onNextButtonTapped(),
        child: Container(
          key: const Key('nextButton'),
          height: kAlertButtonHeight,
          width: double.infinity,
          color: kcBackgroundColor,
          child: Center(
              child: Text(viewModel.isLastPage ? 'Finish' : LocaleKeys.next,
                      style: buttonTextStyle)
                  .tr()),
        ));
  }

  Widget buildUpdateButton(EpisodeViewModel viewModel) {
    return GestureDetector(
        onTap: viewModel.isLastPage
            ? viewModel.isModified
                ? () {
                    onUpdate!(viewModel.episodeOfCare);
                    viewModel.navigateBack();
                  }
                : null
            : () => viewModel.onNextButtonTapped(),
        child: Container(
          key: const Key('updateButton'),
          height: kAlertButtonHeight,
          width: double.infinity,
          color: isEdit && viewModel.isLastPage
              ? viewModel.isModified
                  ? kcBackgroundColor
                  : Colors.grey
              : kcBackgroundColor,
          child: Center(
              child: Text(
                      isEdit && viewModel.isLastPage
                          ? 'Update'
                          : LocaleKeys.next,
                      style: buttonTextStyle)
                  .tr()),
        ));
  }

  @override
  EpisodeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      EpisodeViewModel(encounter: encounter, isEdit: isEdit);
}
