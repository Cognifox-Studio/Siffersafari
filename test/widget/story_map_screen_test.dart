import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/providers/story_progress_provider.dart';

void main() {
  test('[Widget] storyProgressProvider can be overridden to null', () {
    final container = ProviderContainer(
      overrides: [
        storyProgressProvider.overrideWithValue(null),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(storyProgressProvider), isNull);
  });
}
