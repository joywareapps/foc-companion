import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/file_source_service.dart';
import 'package:path/path.dart' as p;

void main() {
  group('FileSourceService.findBundle', () {
    late FileSourceService service;
    late Directory tempDir;

    setUp(() async {
      service = FileSourceService();
      tempDir = await Directory.systemTemp.createTemp('foc_test_bundles');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    FunscriptLocation _loc() => FunscriptLocation()
      ..type = 'local'
      ..localPath = tempDir.path;

    test('finds .focb archive', () async {
      final file = File(p.join(tempDir.path, 'Video1.focb'));
      // Write a minimal valid zip with one funscript entry so axes are detected.
      // (Empty file → no axes → still returned as the only candidate.)
      await file.create();
      final result = await service.findBundle(_loc(), 'Video1');
      expect(result, isNotNull);
      expect(result!.isArchive, isTrue);
      expect(result.archivePath, equals(file.path));
    });

    test('finds .zip archive', () async {
      final file = File(p.join(tempDir.path, 'VR_Scene_01.zip'));
      await file.create();
      final result = await service.findBundle(_loc(), 'VR_Scene_01');
      expect(result, isNotNull);
      expect(result!.isArchive, isTrue);
    });

    test('is case insensitive', () async {
      final file = File(p.join(tempDir.path, 'video_A.focb'));
      await file.create();
      final result = await service.findBundle(_loc(), 'VIDEO_A');
      expect(result, isNotNull);
    });

    test('finds loose funscript files', () async {
      await File(p.join(tempDir.path, 'MyVideo.alpha.funscript')).writeAsString('{"version":"1.0","actions":[]}');
      await File(p.join(tempDir.path, 'MyVideo.beta.funscript')).writeAsString('{"version":"1.0","actions":[]}');
      final result = await service.findBundle(_loc(), 'MyVideo');
      expect(result, isNotNull);
      expect(result!.isArchive, isFalse);
      expect(result.axes, containsAll(['alpha', 'beta']));
    });

    test('ignores unrelated files', () async {
      await File(p.join(tempDir.path, 'Video1.txt')).create();
      await File(p.join(tempDir.path, 'OtherVideo.focb')).create();
      final result = await service.findBundle(_loc(), 'Video1');
      expect(result, isNull);
    });

    test('loose preferred when archive has fewer axes', () async {
      // Archive: empty zip (0 axes). Loose: alpha + beta (2 axes).
      await File(p.join(tempDir.path, 'Scene.focb')).create();
      await File(p.join(tempDir.path, 'Scene.alpha.funscript')).writeAsString('{"version":"1.0","actions":[]}');
      await File(p.join(tempDir.path, 'Scene.beta.funscript')).writeAsString('{"version":"1.0","actions":[]}');

      final result = await service.findBundle(_loc(), 'Scene');
      // Archive axes={} so all union axes missing → loose wins.
      expect(result, isNotNull);
      expect(result!.isArchive, isFalse);
    });
  });
}
