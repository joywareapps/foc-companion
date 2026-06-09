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
  final TextEditingController _heresphereIpController = TextEditingController();
  final TextEditingController _herespherePortController = TextEditingController();
  final TextEditingController _mpcHcIpController = TextEditingController();
  final TextEditingController _mpcHcPortController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInputs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInputs();
  }

  void _loadInputs() {
    final m = Provider.of<SettingsProvider>(context, listen: false).mediaSync;
    _heresphereIpController.text = m.hereSphereIp;
    _herespherePortController.text = m.hereSpherePort.toString();
    _mpcHcIpController.text = m.mpcHcIp;
    _mpcHcPortController.text = m.mpcHcPort.toString();
  }

  @override
  void dispose() {
    _heresphereIpController.dispose();
    _herespherePortController.dispose();
    _mpcHcIpController.dispose();
    _mpcHcPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final m = settings.mediaSync;

    return Scaffold(
      appBar: AppBar(title: const Text('Video Sync Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ── Active Player Selector ──
          const Text("Video Sync",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          DropdownButtonFormField<VideoPlayerType>(
            value: m.activePlayer,
            decoration: const InputDecoration(
              labelText: "Active Player",
              prefixIcon: Icon(Icons.play_circle_outline),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: VideoPlayerType.none,
                child: Text("None"),
              ),
              DropdownMenuItem(
                value: VideoPlayerType.heresphere,
                child: Text("HereSphere"),
              ),
              DropdownMenuItem(
                value: VideoPlayerType.mpcHc,
                child: Text("MPC-HC / mpv"),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => m.activePlayer = v);
            },
          ),

          const SizedBox(height: 24),

          // ── HereSphere Section ──
          if (m.activePlayer == VideoPlayerType.heresphere) ...[
            const Text("HereSphere",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            SwitchListTile(
              title: const Text("Enable HereSphere Integration"),
              value: m.hereSphereEnabled,
              onChanged: (v) => setState(() => m.hereSphereEnabled = v),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: "Player IP Address",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
              controller: _heresphereIpController,
              onChanged: (v) => m.hereSphereIp = v,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "Player Port",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.router),
              ),
              controller: _herespherePortController,
              keyboardType: TextInputType.number,
              onChanged: (v) => m.hereSpherePort = int.tryParse(v) ?? 23554,
            ),
          ],

          // ── MPC-HC Section ──
          if (m.activePlayer == VideoPlayerType.mpcHc) ...[
            const Text("MPC-HC / mpv",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "Connects via HTTP JSON-RPC. Also works with mpv using the mpv-jsonipc Lua script.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: "Player IP Address",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
              controller: _mpcHcIpController,
              onChanged: (v) => m.mpcHcIp = v,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "Web Interface Port",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.router),
                helperText: "Default: 13579",
              ),
              controller: _mpcHcPortController,
              keyboardType: TextInputType.number,
              onChanged: (v) => m.mpcHcPort = int.tryParse(v) ?? 13579,
            ),
          ],

          const Divider(height: 40),

          // ── Funscript Locations ──
          const Text("Funscript Locations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ...m.funscriptLocations.map((loc) => ListTile(
                title: Text(loc.name),
                subtitle: Text("${loc.type}: ${loc.localPath}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      setState(() => m.funscriptLocations.remove(loc)),
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
              if (mounted) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(const SnackBar(content: Text("Settings Saved")));
              }
            },
            child: const Text("Save Media Settings"),
          ),
        ],
      ),
    );
  }
}
