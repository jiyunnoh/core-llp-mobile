import 'package:biot/constants/amputation_info.dart';
import 'package:biot/ui/common/ui_helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'amputation_viewmodel.dart';

class AmputationView extends StackedView<AmputationViewModel> {

  const AmputationView( {super.key});

  @override
  Widget builder(
    BuildContext context,
    AmputationViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amputation'),
        actions: [
          TextButton(onPressed: viewModel.navigateToAmputationFormView, child: const Text('Edit', style: TextStyle(fontSize: 20, color: Colors.white),))
        ],
      ),
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: viewModel.currentPatient.amputations.map((amputation) =>
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(amputation.side!.displayName,
                  style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListTile(
                        title: const Text('Date'),
                        trailing: Text(DateFormat('yyyy-MM-dd')
                            .format(amputation.dateOfAmputation!))),
                    const Divider(
                      height: 1,
                      indent: 20,
                    ),
                    ListTile(
                        title: const Text('Primary Cause'),
                        trailing: (amputation.cause == CauseOfAmputation.other)? Text(amputation.otherPrimaryCause!) : Text(amputation.cause!.displayName)),
                    const Divider(
                      height: 1,
                      indent: 20,
                    ),
                    ListTile(
                        title: const Text('Type'),
                        trailing: Text(amputation.type!.displayName)),
                    const Divider(
                      height: 1,
                      indent: 20,
                    ),
                    ListTile(
                        title: const Text('Level'),
                        trailing: Text(amputation.level!.displayName)),
                    const Divider(
                      height: 1,
                      indent: 20,
                    ),
                    ListTile(
                        title: const Text('Ability to walk prior to your amputation?'),
                        trailing: Text(amputation.abilityToWalk!.displayName))
                  ],
                ),
              ),
              verticalSpaceMedium
            ],
          )).toList()

        ),
      ),
    );
  }

  @override
  AmputationViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AmputationViewModel();
}
