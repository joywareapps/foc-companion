import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:foc_companion/providers/device_provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/screens/home_screen.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/shared_file_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Filter shared files for .focb and forward to SharedFileService.
void _processSharedFiles(List<SharedMediaFile> files) {
  for (final f in files) {
    final path = f.path;
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.focb') || lowerPath.endsWith('.zip')) {
      SharedFileService.add(Uri.file(path));
    } else {
      AppLogger.instance.d('main: ignoring shared file (not .focb or .zip): $path');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlutterForegroundTask.initCommunicationPort();
  
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  // Handle files that opened the app (cold start)
  final initialFiles = await ReceiveSharingIntent.instance.getInitialMedia();
  _processSharedFiles(initialFiles);

  // Handle files while app is running (hot resume)
  ReceiveSharingIntent.instance.getMediaStream().listen(_processSharedFiles);

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
