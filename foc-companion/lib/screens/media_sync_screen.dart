import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/samba_service.dart';

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
  final TextEditingController _vlcIpController = TextEditingController();
  final TextEditingController _vlcPortController = TextEditingController();
  final TextEditingController _vlcPasswordController = TextEditingController();
  final TextEditingController _kodiIpController = TextEditingController();
  final TextEditingController _kodiPortController = TextEditingController();

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
    _vlcIpController.text = m.vlcIp;
    _vlcPortController.text = m.vlcPort.toString();
    _vlcPasswordController.text = m.vlcPassword;
    _kodiIpController.text = m.kodiIp;
    _kodiPortController.text = m.kodiPort.toString();
  }

  @override
  void dispose() {
    _heresphereIpController.dispose();
    _herespherePortController.dispose();
    _mpcHcIpController.dispose();
    _mpcHcPortController.dispose();
    _vlcIpController.dispose();
    _vlcPortController.dispose();
    _vlcPasswordController.dispose();
    _kodiIpController.dispose();
    _kodiPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final m = settings.mediaSync;

    return Scaffold(
      appBar: AppBar(title: const Text('Video Player Sync')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ── Active Player Selector ──
          const Text("Sync Provider",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<VideoPlayerType>(
            value: m.activePlayer,
            decoration: const InputDecoration(
              labelText: "Select Player",
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
              DropdownMenuItem(
                value: VideoPlayerType.vlc,
                child: Text("VLC"),
              ),
              DropdownMenuItem(
                value: VideoPlayerType.kodi,
                child: Text("Kodi"),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => m.activePlayer = v);
            },
          ),

          const SizedBox(height: 16),

          // ── HereSphere Section ──
          if (m.activePlayer == VideoPlayerType.heresphere) ...[
            TextField(
              decoration: const InputDecoration(
                labelText: "HereSphere IP Address",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
              controller: _heresphereIpController,
              onChanged: (v) => m.hereSphereIp = v,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "HereSphere Port",
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
            TextField(
              decoration: const InputDecoration(
                labelText: "MPC-HC IP Address",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
              controller: _mpcHcIpController,
              onChanged: (v) => m.mpcHcIp = v,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "MPC-HC Port",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.router),
                helperText: "Default: 13579",
              ),
              controller: _mpcHcPortController,
              keyboardType: TextInputType.number,
              onChanged: (v) => m.mpcHcPort = int.tryParse(v) ?? 13579,
            ),
          ],

          // ── Kodi Section ──
          if (m.activePlayer == VideoPlayerType.kodi) ...[
            TextField(
              decoration: const InputDecoration(
                labelText: "Kodi IP Address",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
              controller: _kodiIpController,
              onChanged: (v) => m.kodiIp = v,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "Kodi WebSocket Port",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.router),
                helperText: "Default: 9090 (Settings → Services → Control → Allow remote control)",
              ),
              controller: _kodiPortController,
              keyboardType: TextInputType.number,
              onChanged: (v) => m.kodiPort = int.tryParse(v) ?? 9090,
            ),
          ],

          // ── VLC Section ──
          if (m.activePlayer == VideoPlayerType.vlc) ...[
            TextField(
              decoration: const InputDecoration(
                labelText: "VLC IP Address",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
              controller: _vlcIpController,
              onChanged: (v) => m.vlcIp = v,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "VLC Port",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.router),
                helperText: "Default: 8080",
              ),
              controller: _vlcPortController,
              keyboardType: TextInputType.number,
              onChanged: (v) => m.vlcPort = int.tryParse(v) ?? 8080,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "VLC Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              controller: _vlcPasswordController,
              onChanged: (v) => m.vlcPassword = v,
            ),
          ],

          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text("Autoload Matching Bundles"),
            subtitle: const Text("Automatically find and load .focb/.zip files when video changes"),
            value: m.autoloadEnabled,
            onChanged: (v) => setState(() => m.autoloadEnabled = v),
          ),

          const Divider(height: 40),

          // ── Funscript Locations ──
          const Text("Funscript Locations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ...m.funscriptLocations.map((loc) => ListTile(
                title: Text(loc.name),
                subtitle: Text(loc.type == 'local'
                    ? "Local: ${loc.localPath}"
                    : "SMB: ${loc.smbHost}/${loc.smbShare}${loc.smbPath.isNotEmpty ? '/${loc.smbPath}' : ''}"),
                onTap: () => _showAddLocationDialog(context, m, location: loc),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      setState(() => m.funscriptLocations.remove(loc)),
                ),
              )),

          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("Add Location"),
            onTap: () => _showAddLocationDialog(context, m),
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

  void _showAddLocationDialog(BuildContext context, MediaSyncSettings m, {FunscriptLocation? location}) {
    final isEditing = location != null;
    String name = location?.name ?? "";
    String type = location?.type ?? "local";
    String localPath = location?.localPath ?? "/storage/emulated/0/Download";
    String smbHost = location?.smbHost ?? "";
    String smbShare = location?.smbShare ?? "";
    String smbPath = location?.smbPath ?? "";
    String smbDomain = location?.smbDomain ?? "WORKGROUP";
    String smbUser = location?.smbUsername ?? "";
    String smbPass = location?.smbPassword ?? "";

    bool isTesting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEditing ? "Edit Funscript Location" : "Add Funscript Location"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Location Name"),
                  controller: TextEditingController(text: name)..selection = TextSelection.collapsed(offset: name.length),
                  onChanged: (v) => name = v,
                ),
                DropdownButtonFormField<String>(
                  value: type,
                  items: const [
                    DropdownMenuItem(value: "local", child: Text("Local Folder")),
                    DropdownMenuItem(value: "smb", child: Text("SMB Share")),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                if (type == "local")
                  TextField(
                    decoration: const InputDecoration(labelText: "Local Path"),
                    controller: TextEditingController(text: localPath)..selection = TextSelection.collapsed(offset: localPath.length),
                    onChanged: (v) => localPath = v,
                  ),
                if (type == "smb") ...[
                  TextField(
                    decoration: const InputDecoration(labelText: "SMB Host (IP)"),
                    controller: TextEditingController(text: smbHost)..selection = TextSelection.collapsed(offset: smbHost.length),
                    onChanged: (v) => smbHost = v,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Share Name"),
                    controller: TextEditingController(text: smbShare)..selection = TextSelection.collapsed(offset: smbShare.length),
                    onChanged: (v) => smbShare = v,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Subfolder (optional)",
                      hintText: "e.g. funscripts/hd",
                    ),
                    controller: TextEditingController(text: smbPath)..selection = TextSelection.collapsed(offset: smbPath.length),
                    onChanged: (v) => smbPath = v,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Workgroup / Domain"),
                    controller: TextEditingController(text: smbDomain)..selection = TextSelection.collapsed(offset: smbDomain.length),
                    onChanged: (v) => smbDomain = v,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Username (optional)"),
                    controller: TextEditingController(text: smbUser)..selection = TextSelection.collapsed(offset: smbUser.length),
                    onChanged: (v) => smbUser = v,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Password (optional)"),
                    obscureText: true,
                    controller: TextEditingController(text: smbPass)..selection = TextSelection.collapsed(offset: smbPass.length),
                    onChanged: (v) => smbPass = v,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isTesting ? null : () async {
                setDialogState(() => isTesting = true);
                String? error;
                if (type == "local") {
                  if (!await Directory(localPath).exists()) {
                    error = "Local directory does not exist or is inaccessible.";
                  }
                } else {
                  final testLoc = FunscriptLocation()
                    ..type = "smb"
                    ..smbHost = smbHost
                    ..smbShare = smbShare
                    ..smbDomain = smbDomain
                    ..smbUsername = smbUser
                    ..smbPassword = smbPass;
                  error = await SambaService.instance.testConnection(testLoc);
                }
                setDialogState(() => isTesting = false);
                
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(error ?? "Connection Successful!"),
                    backgroundColor: error == null ? Colors.green : Colors.red,
                  ));
                }
              },
              child: isTesting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Text("Test"),
            ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                setState(() {
                  final target = location ?? FunscriptLocation();
                  target.name = name.isNotEmpty ? name : (type == "local" ? "Local" : "SMB");
                  target.type = type;
                  target.localPath = localPath;
                  target.smbHost = smbHost;
                  target.smbShare = smbShare;
                  target.smbPath = smbPath;
                  target.smbDomain = smbDomain;
                  target.smbUsername = smbUser;
                  target.smbPassword = smbPass;
                  
                  if (!isEditing) {
                    m.funscriptLocations.add(target);
                  }
                });
                Navigator.pop(ctx);
              },
              child: Text(isEditing ? "Save" : "Add"),
            ),
          ],
        ),
      ),
    );
  }
}
