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
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text("Autoload Matching Bundles"),
            subtitle: const Text("Automatically find and load .focb/.zip files when video changes"),
            value: m.autoloadEnabled,
            onChanged: (v) => setState(() => m.autoloadEnabled = v),
          ),

          const Divider(height: 40),
          const Text("Funscript Locations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ...m.funscriptLocations.map((loc) => ListTile(
            title: Text(loc.name),
            subtitle: Text(loc.type == 'local' ? "Local: ${loc.localPath}" : "SMB: ${loc.smbHost}/${loc.smbShare}"),
            onTap: () => _showAddLocationDialog(context, m, location: loc),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => m.funscriptLocations.remove(loc)),
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

  void _showAddLocationDialog(BuildContext context, MediaSyncSettings m, {FunscriptLocation? location}) {
    final isEditing = location != null;
    String name = location?.name ?? "";
    String type = location?.type ?? "local";
    String localPath = location?.localPath ?? "/storage/emulated/0/Download";
    String smbHost = location?.smbHost ?? "";
    String smbShare = location?.smbShare ?? "";
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
