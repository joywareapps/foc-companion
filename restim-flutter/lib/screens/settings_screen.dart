import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restim_flutter/providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _ipController.text = settings.focStim.wifiIp;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text("Global Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 10),
        TextField(
          controller: _ipController,
          decoration: const InputDecoration(
            labelText: "FOC-Stim Device IP",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.wifi),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () {
            settings.focStim.wifiIp = _ipController.text;
            settings.saveSettings();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Settings Saved")),
            );
          },
          child: const Text("Save Settings"),
        ),
      ],
    );
  }
}
