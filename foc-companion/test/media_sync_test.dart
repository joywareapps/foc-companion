import 'package:flutter_test/flutter_test.dart';
import 'package:foc_companion/services/file_source_service.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

void main() {
  group('FileSourceService.findBundles', () {
    late FileSourceService service;
    late Directory tempDir;

    setUp(() async {
      service = FileSourceService();
      tempDir = await Directory.systemTemp.createTemp('foc_test_bundles');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('finds .focb bundle in local location', () async {
      final loc = FunscriptLocation()
        ..type = 'local'
        ..localPath = tempDir.path;

      final file = File(p.join(tempDir.path, 'Video1.focb'));
      await file.create();

      final results = await service.findBundles(loc, 'Video1');
      expect(results, contains(file.path));
    });

    test('finds .zip bundle in local location', () async {
      final loc = FunscriptLocation()
        ..type = 'local'
        ..localPath = tempDir.path;

      final file = File(p.join(tempDir.path, 'VR_Scene_01.zip'));
      await file.create();

      final results = await service.findBundles(loc, 'VR_Scene_01');
      expect(results, contains(file.path));
    });

    test('is case insensitive', () async {
      final loc = FunscriptLocation()
        ..type = 'local'
        ..localPath = tempDir.path;

      final file = File(p.join(tempDir.path, 'video_A.FOCB'));
      await file.create();

      final results = await service.findBundles(loc, 'VIDEO_a');
      expect(results, contains(file.path));
    });

    test('ignores unrelated files', () async {
      final loc = FunscriptLocation()
        ..type = 'local'
        ..localPath = tempDir.path;

      await File('${tempDir.path}/Video1.txt').create();
      await File('${tempDir.path}/OtherVideo.focb').create();

      final results = await service.findBundles(loc, 'Video1');
      expect(results, isEmpty);
    });
  });
}
