import 'package:flutter_test/flutter_test.dart';
import 'package:foc_companion/services/funscript_bundle_loader.dart';

void main() {
  group('FunscriptBundleLoader.detectAxisSuffix', () {
    test('detects alpha suffix', () {
      expect(FunscriptBundleLoader.detectAxisSuffix('video.alpha.funscript'), 'alpha');
    });

    test('detects volume suffix', () {
      expect(FunscriptBundleLoader.detectAxisSuffix('scene.volume.funscript'), 'volume');
    });

    test('detects multi-word suffix', () {
      expect(FunscriptBundleLoader.detectAxisSuffix('test.pulse_frequency.funscript'), 'pulse_frequency');
    });

    test('returns null for no suffix', () {
      expect(FunscriptBundleLoader.detectAxisSuffix('something.funscript'), null);
    });

    test('returns null for wrong extension', () {
      expect(FunscriptBundleLoader.detectAxisSuffix('video.alpha.txt'), null);
    });

    test('handles case insensitivity for extension', () {
      expect(FunscriptBundleLoader.detectAxisSuffix('video.alpha.FUNSCRIPT'), 'alpha');
    });
    
    test('handles multiple dots in prefix', () {
      expect(FunscriptBundleLoader.detectAxisSuffix('my.complex.filename.beta.funscript'), 'beta');
    });
  });
}
