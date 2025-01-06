import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'app_description_viewmodel.dart';

class AppDescriptionView extends StackedView<AppDescriptionViewModel> {
  const AppDescriptionView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AppDescriptionViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('App Description'),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(
            child: Text(
                'This is the placeholder for app description & funding info.')),
      ),
    );
  }

  @override
  AppDescriptionViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AppDescriptionViewModel();
}
