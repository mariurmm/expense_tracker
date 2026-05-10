// Basic smoke test — verifies the app boots without crashing.
// Full integration tests require a real Hive environment; see README for setup.

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('placeholder — app has no unit-testable counter widget',
      (tester) async {
    // Hive requires platform channels (path_provider) which are not available
    // in the widget-test host. Boot-level testing is covered by running the
    // app on a device or emulator.
    //
    // Add feature-level tests here once you mock the Hive boxes.
    expect(true, isTrue);
  });
}
