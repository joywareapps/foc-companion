import 'package:flutter_test/flutter_test.dart';
import 'package:foc_companion/services/funscript_parser.dart';

void main() {
  test('parses fractional at/pos values by rounding', () {
    final script = FunscriptParser.parse(
      '{"actions":[{"at":1000.6,"pos":37.5},{"at":0,"pos":10}]}',
    );
    expect(script.actions.length, 2);
    expect(script.actions[0].at, 0);
    expect(script.actions[1].at, 1001);
    expect(script.actions[1].pos, 38);
  });
}
