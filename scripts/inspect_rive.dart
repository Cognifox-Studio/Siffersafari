import 'dart:io';
import 'dart:typed_data';

import 'package:rive/rive.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    stderr.writeln('Usage: dart run scripts/inspect_rive.dart <path-to-riv>');
    exitCode = 64;
    return;
  }

  for (final path in arguments) {
    final file = File(path);
    if (!file.existsSync()) {
      stderr.writeln('Missing file: $path');
      exitCode = 66;
      continue;
    }

    final bytes = await file.readAsBytes();
    final riveFile = RiveFile.import(ByteData.sublistView(bytes));

    stdout.writeln('=== $path ===');
    stdout.writeln('Main artboard: ${riveFile.mainArtboard.name}');

    for (final artboard in riveFile.artboards) {
      stdout.writeln('Artboard: ${artboard.name}');

      if (artboard.animations.isEmpty) {
        stdout.writeln('  Animations: none');
      } else {
        for (final animation in artboard.animations) {
          stdout.writeln('  Animation: ${animation.name}');
        }
      }

      if (artboard.stateMachines.isEmpty) {
        stdout.writeln('  State machines: none');
      } else {
        for (final machine in artboard.stateMachines) {
          stdout.writeln('  State machine: ${machine.name}');
          if (machine.inputs.isEmpty) {
            stdout.writeln('    Inputs: none');
          } else {
            for (final input in machine.inputs) {
              stdout.writeln('    Input: ${input.name} (${input.runtimeType})');
            }
          }
        }
      }
    }
  }
}