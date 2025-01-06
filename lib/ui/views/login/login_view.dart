import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  LoginView({super.key, this.isAuthCheck = false});

  final formKey = GlobalKey<FormState>();

  final bool isAuthCheck;

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 25),
        child: Stack(children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'LEAD and COMPASS',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  verticalSpaceLarge,
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          key: const Key('email'),
                          controller: viewModel.emailController,
                          decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            filled: true,
                            hintText: 'Email',
                          ),
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[a-zA-Z0-9@+.]"))
                          ],
                          validator: (value) => value != null && value.isEmpty
                              ? 'Email is required'
                              : null,
                        ),
                        verticalSpaceSmall,
                        TextFormField(
                          key: const Key('pwd'),
                          controller: viewModel.pwdController,
                          obscureText: !viewModel.isPwdVisible,
                          decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent)),
                              filled: true,
                              hintText: 'Password',
                              suffixIcon: IconButton(
                                  onPressed: viewModel.onTogglePwdVisible,
                                  icon: Icon(
                                    (viewModel.isPwdVisible)
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.black,
                                  ))),
                          keyboardType: TextInputType.text,
                          validator: (value) => value != null && value.isEmpty
                              ? 'Password is required'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  verticalSpaceMedium,
                  Column(
                    children: [
                      ElevatedButton(
                          key: const Key('loginBtn'),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 90.0, vertical: 10.0),
                            child: Text(
                              'LOGIN',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          onPressed: () async {
                            final isValid = formKey.currentState?.validate();
                            if (isValid!) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              viewModel.login(viewModel.emailController.text,
                                  viewModel.pwdController.text);
                            }
                          }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                Image.asset('packages/comet_foundation/images/atscale.png', width: 260, fit: BoxFit.fitHeight),
                Image.asset('packages/comet_foundation/images/ispo.png', width: 260, fit: BoxFit.fitHeight)
              ],
            ),
          ),
          
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: viewModel.navigateToSettingsView,
                iconSize: 30.0),
          ),
        ]),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginViewModel();
}
