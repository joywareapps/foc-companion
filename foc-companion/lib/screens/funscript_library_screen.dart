import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/funscript_bundle_loader.dart';

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

  @override
  void initState() {
    super.initState();
    _initLibrary();
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
        allowedExtensions: ['focb'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot access selected file')),
          );
        }
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importing bundle…')),
      );

      await FunscriptBundleLoader.importFromUri(
        Uri.file(file.path!),
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

  void _navigateToPlayer(Map<String, dynamic> meta) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(
            child: Text('Player placeholder — Phase D'),
          ),
        ),
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
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 2,
                                children: axes
                                    .map((a) => Chip(
                                          label: Text(a,
                                              style: const TextStyle(
                                                  fontSize: 11)),
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          labelPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6),
                                          visualDensity: VisualDensity.compact,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (importDate.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
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
