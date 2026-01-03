import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restim_flutter/providers/device_provider.dart';
import 'package:restim_flutter/providers/settings_provider.dart';
import 'package:restim_flutter/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProxyProvider<SettingsProvider, DeviceProvider>(
          create: (context) => DeviceProvider(settingsProvider),
          update: (context, settings, previous) => 
            previous!..updateSettings(settings),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FOC Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F95DC),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'OpenSans',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F95DC),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'OpenSans',
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
