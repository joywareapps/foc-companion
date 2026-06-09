import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/models/settings_models.dart';

class MediaSyncScreen extends StatefulWidget {
  const MediaSyncScreen({super.key});

  @override
  State<MediaSyncScreen> createState() => _MediaSyncScreenState();
}

class _MediaSyncScreenState extends State<MediaSyncScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _updateControllers(MediaSyncSettings m) {
    if (m.selectedPlayer == "HereSphere") {
      _ipController.text = m.hereSphereIp;
      _portController.text = m.hereSpherePort.toString();
    } else {
      _ipController.text = m.mpcHcIp;
      _portController.text = m.mpcHcPort.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final m = settings.mediaSync;

    // Sync controllers on first build or if player changed
    if (_ipController.text.isEmpty && _portController.text.isEmpty) {
      _updateControllers(m);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Player Sync"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text("Sync Provider", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: m.selectedPlayer,
            decoration: const InputDecoration(
              labelText: "Select Player",
              border: OutlineInputBorder(),
            ),
            items: ["HereSphere", "MPC-HC"]
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  m.selectedPlayer = v;
                  _updateControllers(m);
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: "Player IP Address",
              hintText: "e.g. 192.168.1.5",
              border: OutlineInputBorder(),
            ),
            controller: _ipController,
            onChanged: (v) {
              if (m.selectedPlayer == "HereSphere") {
                m.hereSphereIp = v;
              } else {
                m.mpcHcIp = v;
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: "Player Port",
              border: OutlineInputBorder(),
            ),
            controller: _portController,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final port = int.tryParse(v) ?? (m.selectedPlayer == "HereSphere" ? 23554 : 13579);
              if (m.selectedPlayer == "HereSphere") {
                m.hereSpherePort = port;
              } else {
                m.mpcHcPort = port;
              }
            },
          ),

          const Divider(height: 40),
          const Text("Funscript Locations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ...m.funscriptLocations.map((loc) => ListTile(
            title: Text(loc.name),
            subtitle: Text("${loc.type}: ${loc.localPath}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => m.funscriptLocations.remove(loc)),
            ),
          )),

          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("Add Local Location"),
            onTap: () {
              setState(() {
                m.funscriptLocations.add(FunscriptLocation()
                  ..name = "New Local"
                  ..type = "local"
                  ..localPath = "/storage/emulated/0/Download");
              });
            },
          ),

          const SizedBox(height: 30),
          FilledButton(
            onPressed: () async {
              await settings.saveSettings();
              ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                const SnackBar(content: Text("Settings Saved")),
              );
            },
            child: const Text("Save Media Settings"),
          ),
        ],
      ),
    );
  }
}
