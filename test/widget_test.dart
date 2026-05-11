import 'package:flutter_test/flutter_test.dart';
import 'package:openair/env.dart';

void main() {
  test('Env class is loadable', () {
    expect(Env.apiKey, isNotEmpty);
  });
}
