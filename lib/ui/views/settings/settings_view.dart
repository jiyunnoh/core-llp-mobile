import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../common/ui_helpers.dart';
import 'settings_viewmodel.dart';

class SettingsView extends StackedView<SettingsViewModel> {
  const SettingsView({super.key, this.isBeforeLogin = false});

  final bool isBeforeLogin;

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.black,
        title: const Text('Settings'),
        actions: (viewModel.isBeforeLogin)
            ? null
            : [
                IconButton(
                    onPressed: () => viewModel.showConfirmLogoutDialog(context),
                    icon: const Icon(Icons.logout))
              ],
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'About',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.security,
                        color: Colors.black,
                      ),
                      title: const Text(
                        'Data Privacy',
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        size: 30.0,
                        color: Colors.black54,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 0),
                      onTap: viewModel.dataPrivacyTapped,
                    ),
                    const Divider(
                      indent: 30,
                      endIndent: 30,
                      color: Colors.black38,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.email_outlined,
                        color: Colors.black,
                      ),
                      title: const Text(
                        'Contact Support',
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        size: 30.0,
                        color: Colors.black54,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 0),
                      onTap: viewModel.sendEmailTapped,
                    ),
                    const Divider(
                      indent: 30,
                      endIndent: 30,
                      color: Colors.black38,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.new_releases_outlined,
                        color: Colors.black,
                      ),
                      title: const Text(
                        'App Version',
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: Text(viewModel.appVersion),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 0),
                    ),
                    const Divider(
                      indent: 30,
                      endIndent: 30,
                      color: Colors.black38,
                    ),
                  ],
                ),
                verticalSpaceSmall,
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.school_outlined,
              color: Colors.black,
            ),
            title: const Text(
              'Acknowledgement',
              style: TextStyle(fontSize: 18),
            ),
            subtitle: Column(
              children: [
                const Text(
                    'This app was developed under grant 2023/007 from ATscale in support of the work of the ISPO LEAD and COMPASS working group, a project managed through the United Nations Office for Project Services (UNOPS)'),
                verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('packages/comet_foundation/images/atscale.png',
                        width: 260, fit: BoxFit.fitHeight),
                    Image.asset('packages/comet_foundation/images/ispo.png',
                        width: 260, fit: BoxFit.fitHeight)
                  ],
                )
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black12))),
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, (viewModel.isBeforeLogin) ? 32 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Image.asset(
                      'packages/comet_foundation/images/oi-logo.png'),
                ),
                verticalSpaceTiny,
                Expanded(
                  child: Column(
                    children: [
                      Text('©2023 - ${DateTime.now().year}'),
                      const Text('Orthocare Innovations'),
                      const Text('Edmonds, WA, USA'),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }

  @override
  SettingsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      SettingsViewModel(isBeforeLogin: isBeforeLogin);
}
