import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restim_flutter/providers/settings_provider.dart';
import 'package:restim_flutter/models/settings_models.dart';

class MediaSyncScreen extends StatefulWidget {
  const MediaSyncScreen({super.key});

  @override
  State<MediaSyncScreen> createState() => _MediaSyncScreenState();
}

class _MediaSyncScreenState extends State<MediaSyncScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final m = settings.mediaSync;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text("HereSphere Sync", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SwitchListTile(
          title: const Text("Enable HereSphere Integration"),
          value: m.hereSphereEnabled,
          onChanged: (v) => setState(() => m.hereSphereEnabled = v),
        ),
        
        TextField(
          decoration: const InputDecoration(labelText: "Player IP Address"),
          controller: TextEditingController(text: m.hereSphereIp),
          onChanged: (v) => m.hereSphereIp = v,
        ),
        
        TextField(
          decoration: const InputDecoration(labelText: "Player Port"),
          controller: TextEditingController(text: m.hereSpherePort.toString()),
          keyboardType: TextInputType.number,
          onChanged: (v) => m.hereSpherePort = int.tryParse(v) ?? 23554,
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Settings Saved")),
            );
          },
          child: const Text("Save Media Settings"),
        ),
      ],
    );
  }
}
