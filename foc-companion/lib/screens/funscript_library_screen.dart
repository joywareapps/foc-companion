import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/funscript_bundle_loader.dart';
import 'package:foc_companion/services/shared_file_service.dart';
import 'package:foc_companion/providers/device_provider.dart';
import 'package:foc_companion/screens/funscript_player_screen.dart';

/// Library browser for imported funscript bundles.
class FunscriptLibraryScreen extends StatefulWidget {
  const FunscriptLibraryScreen({super.key});

  @override
  State<FunscriptLibraryScreen> createState() => _FunscriptLibraryScreenState();
}

class _FunscriptLibraryScreenState extends State<FunscriptLibraryScreen> {
  List<Map<String, dynamic>> _bundles = [];
  bool _isLoading = true;
  String _libraryDir = '';
  StreamSubscription<Uri>? _sharedFileSub;

  @override
  void initState() {
    super.initState();
    _initLibrary();

    // Handle pending shared file from cold start
    final pending = SharedFileService.consumePending();
    if (pending != null) {
      // Import after the library dir is initialised
      _initLibrary().then((_) => _importFromUri(pending));
    }

    // Auto-import .focb files shared while app is running (hot resume)
    _sharedFileSub = SharedFileService.stream.listen((uri) {
      _importFromUri(uri);
    });
  }

  @override
  void dispose() {
    _sharedFileSub?.cancel();
    super.dispose();
  }

  Future<void> _initLibrary() async {
    final appDir = await getApplicationDocumentsDirectory();
    final libDir = '${appDir.path}/funscript_library';
    setState(() => _libraryDir = libDir);
    await _loadBundles();
  }

  Future<void> _loadBundles() async {
    setState(() => _isLoading = true);
    try {
      final bundles = await FunscriptBundleLoader.listAll(_libraryDir);
      if (mounted) setState(() => _bundles = bundles);
    } catch (e) {
      AppLogger.instance.e('FunscriptLibraryScreen: failed to load bundles', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load library: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _importBundle() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['focb', 'zip'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final path = file.path;
      if (path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot access selected file')),
          );
        }
        return;
      }

      // Quick validation check
      final isValid = await FunscriptBundleLoader.isValidBundle(path);
      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid bundle: no .funscript files found inside')),
          );
        }
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importing bundle…')),
      );

      await FunscriptBundleLoader.importFromUri(
        Uri.file(path),
        _libraryDir,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bundle imported successfully')),
        );
        await _loadBundles();
      }
    } catch (e) {
      AppLogger.instance.e('FunscriptLibraryScreen: import failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  /// Import a .focb file from a URI (e.g. shared from another app).
  Future<void> _importFromUri(Uri uri) async {
    if (_libraryDir.isEmpty) {
      // Library not initialised yet – wait for _initLibrary.
      await _initLibrary();
    }

    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importing bundle…')),
      );

      await FunscriptBundleLoader.importFromUri(uri, _libraryDir);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bundle imported successfully')),
        );
        await _loadBundles();
      }
    } catch (e) {
      AppLogger.instance.e('FunscriptLibraryScreen: shared-file import failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Future<void> _deleteBundle(String bundleId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bundle'),
        content: Text('Delete "$name" from your library?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FunscriptBundleLoader.delete(bundleId, _libraryDir);
      await _loadBundles();
    } catch (e) {
      AppLogger.instance.e('FunscriptLibraryScreen: delete failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _renameBundle(String bundleId, String currentName) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _RenameDialog(currentName: currentName);
      },
    );

    if (!mounted) return;
    if (newName == null || newName.isEmpty || newName == currentName) return;

    try {
      await FunscriptBundleLoader.rename(bundleId, newName, _libraryDir);
      if (!mounted) return;
      await _loadBundles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Renamed to "$newName"')),
        );
      }
    } catch (e) {
      AppLogger.instance.e('FunscriptLibraryScreen: rename failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rename failed: $e')),
        );
      }
    }
  }

  void _navigateToPlayer(Map<String, dynamic> meta) {
    final device = context.read<DeviceProvider>();
    if (!device.api.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect a device first to play funscripts')),
      );
      return;
    }
    if (device.isLoopRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stop pattern playback first before playing funscripts')),
      );
      return;
    }
    // Attach boxIndex so the player knows which device to target
    meta['boxIndex'] = device.settings.activeUiBoxIndex;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FunscriptPlayerScreen(meta: meta),
      ),
    );
  }

  String _formatDuration(int ms) {
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funscript Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Import .focb',
            onPressed: _importBundle,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bundles.isEmpty
              ? _buildEmptyState()
              : _buildBundleList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_music_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No bundles yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share a .focb file with FOC Companion\nor tap + to import.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _bundles.length,
      itemBuilder: (context, index) {
        final meta = _bundles[index];
        return _buildBundleTile(meta);
      },
    );
  }

  Widget _buildBundleTile(Map<String, dynamic> meta) {
    final id = meta['id'] as String;
    final name = meta['name'] as String? ?? 'Unknown';
    final durationMs = meta['durationMs'] as int? ?? 0;
    final axes = (meta['axes'] as List<dynamic>?)?.cast<String>() ?? [];
    final importDate = meta['importDate'] as String? ?? '';
    final sourceFile = meta['sourceFile'] as String? ?? '';

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Bundle'),
            content: Text('Delete "$name" from your library?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await _deleteBundle(id, name);
          return false; // already deleted
        }
        return false;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: InkWell(
          onTap: () => _navigateToPlayer(meta),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _formatDuration(durationMs),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (axes.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Axes: ${axes.join(", ")}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (sourceFile.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              Icon(Icons.attach_file, size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  sourceFile,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey[500]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (importDate.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Imported ${_formatDate(importDate)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Rename',
                  onPressed: () => _renameBundle(id, name),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Play',
                  color: Colors.green,
                  onPressed: () => _navigateToPlayer(meta),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standalone rename dialog with its own TextEditingController lifecycle.
class _RenameDialog extends StatefulWidget {
  final String currentName;
  const _RenameDialog({required this.currentName});

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Bundle'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Name',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          final trimmed = value.trim();
          if (trimmed.isNotEmpty) Navigator.pop(context, trimmed);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final trimmed = _controller.text.trim();
            if (trimmed.isNotEmpty) Navigator.pop(context, trimmed);
          },
          child: const Text('Rename'),
        ),
      ],
    );
  }
}
