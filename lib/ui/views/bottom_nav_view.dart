import 'package:biot/ui/common/app_colors.dart';
import 'package:biot/ui/views/patient_view_navigator.dart';
import 'package:biot/ui/views/settings_view_navigator.dart';
import 'package:flutter/material.dart';
import '../common/constants.dart';

class BottomNavView extends StatefulWidget {
  const BottomNavView({super.key});

  @override
  _BottomNavViewState createState() => _BottomNavViewState();
}

class _BottomNavViewState extends State<BottomNavView>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            key: bottomNavKey,
            backgroundColor: kcBackgroundColor,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey.shade500,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Clients',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: 'Settings')
            ],
            currentIndex: _selectedIndex,
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            }),
        body: SafeArea(
            top: false,
            child: IndexedStack(index: _selectedIndex, children: const <Widget>[
              PatientViewNavigator(),
              SettingsViewNavigator()
            ])));
  }
}
