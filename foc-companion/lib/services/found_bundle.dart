/// Result of searching a funscript location for a specific video basename.
/// Either an archive (.focb / .zip) or a set of loose .funscript files.
class FoundBundle {
  final bool isArchive;

  /// Archive: local file path or SMB remote path.
  final String? archivePath;

  /// Loose: local file paths or SMB remote paths (one per axis file).
  final List<String>? loosePaths;

  /// Detected axis names (e.g. {'alpha', 'beta', 'volume'}).
  final Set<String> axes;

  /// Modification date used to pick the newest complete candidate.
  final DateTime date;

  const FoundBundle.archive(String path, {required this.axes, required this.date})
      : isArchive = true,
        archivePath = path,
        loosePaths = null;

  const FoundBundle.loose(List<String> paths, {required this.axes, required this.date})
      : isArchive = false,
        archivePath = null,
        loosePaths = paths;
}

/// Picks the winner between an archive and a loose-file candidate.
///
/// Completeness rule: the union of both candidates' axes defines the
/// required set. A candidate missing any axis from that union is
/// disqualified. Among complete candidates, the newest date wins.
/// If both are disqualified (pathological), the archive is preferred.
FoundBundle? pickBundleWinner(FoundBundle? archive, FoundBundle? loose) {
  if (archive == null) return loose;
  if (loose == null) return archive;

  final allAxes = {...archive.axes, ...loose.axes};
  final archiveComplete = allAxes.every(archive.axes.contains);
  final looseComplete = allAxes.every(loose.axes.contains);

  if (archiveComplete && !looseComplete) return archive;
  if (looseComplete && !archiveComplete) return loose;
  if (!archiveComplete && !looseComplete) return archive; // fallback

  // Both complete — pick newest.
  return archive.date.isAfter(loose.date) ? archive : loose;
}
