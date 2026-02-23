import 'package:flutter/material.dart';
import 'package:foc_companion/screens/control_screen.dart';
import 'package:foc_companion/screens/device_settings_screen.dart';
import 'package:foc_companion/screens/pulse_settings_screen.dart';
// import 'package:foc_companion/screens/media_sync_screen.dart';  // hidden — re-enable with Media tab
import 'package:foc_companion/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    ControlScreen(),
    DeviceSettingsScreen(),
    PulseSettingsScreen(),
    // MediaSyncScreen(),  // hidden for now — re-enable by restoring this line and its NavigationDestination
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FOC Companion'),
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            label: 'Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            label: 'Device',
          ),
          NavigationDestination(
            icon: Icon(Icons.electric_bolt),
            label: 'Pulse',
          ),
          // NavigationDestination(icon: Icon(Icons.sync), label: 'Media'),  // hidden
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
