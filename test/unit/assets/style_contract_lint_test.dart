import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Future<ProcessResult> _runAssetLint() async {
  final commands = Platform.isWindows
      ? <String>["python", "py"]
      : <String>["python3", "python"];

  ProcessException? lastError;

  for (final command in commands) {
    try {
      final result = await Process.run(
        command,
        const ["tools/pipeline.py", "lint-assets", "--strict"],
      );
      if (result.exitCode == 0) {
        return result;
      }
      return result;
    } on ProcessException catch (error) {
      lastError = error;
    }
  }

  throw lastError ?? ProcessException("python", const ["tools/pipeline.py"]);
}

void main() {
  group('[Unit] Asset style contract', () {
    test('style contract exists', () {
      expect(File('specs/style_contract.yaml').existsSync(), isTrue);
    });

    test('lint-assets strict passes', () async {
      final result = await _runAssetLint();
      expect(
        result.exitCode,
        0,
        reason:
            'lint-assets failed:\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}',
      );
    });
  });
}
