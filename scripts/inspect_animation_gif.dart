import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.containsKey('help') || parsed.containsKey('h') || args.isEmpty) {
    _printHelp();
    exit(0);
  }

  final gifPath = parsed['gif'] ?? parsed['g'];
  if (gifPath == null || gifPath.trim().isEmpty) {
    stderr.writeln('Missing required arg: --gif');
    _printHelp();
    exit(2);
  }

  final outStripPath = parsed['outStrip'] ?? parsed['strip'];
  final cols = int.tryParse(parsed['cols'] ?? '') ?? 8;
  final safeCols = cols <= 0 ? 8 : cols;

  final file = File(gifPath);
  if (!file.existsSync()) {
    stderr.writeln('GIF not found: $gifPath');
    exit(2);
  }

  final bytes = file.readAsBytesSync();
  final decoded = img.decodeGif(bytes);
  if (decoded == null) {
    stderr.writeln('Failed to decode GIF: $gifPath');
    exit(2);
  }

  final frames = decoded.frames;
  final frameCount = decoded.numFrames;

  stdout.writeln('GIF: ${file.path}');
  stdout.writeln('Size: ${decoded.width}x${decoded.height}');
  stdout.writeln('Frames: $frameCount');
  stdout.writeln('LoopCount: ${decoded.loopCount} (0 = forever)');

  final durationsMs = <int>[];
  for (final f in frames) {
    durationsMs.add(f.frameDuration);
  }

  final nonZero = durationsMs.where((d) => d > 0).toList();
  final avgMs = nonZero.isEmpty
      ? 0
      : (nonZero.reduce((a, b) => a + b) / nonZero.length).round();
  final approxFps = avgMs > 0 ? (1000 / avgMs).toStringAsFixed(2) : 'n/a';

  stdout.writeln('Frame durations (ms): ${durationsMs.join(', ')}');
  stdout.writeln('Avg non-zero frame duration: ${avgMs == 0 ? 'n/a' : '${avgMs}ms'}');
  stdout.writeln('Approx fps: $approxFps');

  if (outStripPath != null && outStripPath.trim().isNotEmpty) {
    final stripFile = File(outStripPath);
    stripFile.parent.createSync(recursive: true);

    final w = decoded.width;
    final h = decoded.height;
    final cols = safeCols;
    final rows = ((frameCount + cols - 1) / cols).floor();

    final strip = img.Image(width: w * cols, height: h * rows, numChannels: 4);

    for (var i = 0; i < frameCount; i++) {
      final f = frames[i].convert(format: img.Format.uint8);
      final x = (i % cols) * w;
      final y = (i ~/ cols) * h;
      img.compositeImage(strip, f, dstX: x, dstY: y);
    }

    final pngBytes = img.encodePng(strip);
    stripFile.writeAsBytesSync(pngBytes);

    stdout.writeln('Wrote strip: ${stripFile.path}');
  }
}

void _printHelp() {
  stdout.writeln('''
Inspect an animated GIF (frame count, timing) and optionally create a PNG strip.

Required:
  --gif <path>          Path to a .gif file

Optional:
  --outStrip <path>     Write a contact sheet (PNG) with all frames
  --cols <int>          Columns in the strip (default 8)

Examples:
  dart run scripts/inspect_animation_gif.dart --gif artifacts/comfyui/previews/idle.gif --outStrip artifacts/comfyui/previews/idle_strip.png --cols 8
''');
}

Map<String, String?> _parseArgs(List<String> args) {
  final out = <String, String?>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (!a.startsWith('-')) continue;

    final key = a.replaceFirst(RegExp(r'^-+'), '');
    String? value;

    final eqIndex = key.indexOf('=');
    if (eqIndex != -1) {
      final k = key.substring(0, eqIndex);
      value = key.substring(eqIndex + 1);
      out[k] = value;
      continue;
    }

    if (i + 1 < args.length && !args[i + 1].startsWith('-')) {
      value = args[i + 1];
      i++;
    } else {
      value = 'true';
    }

    out[key] = value;
  }
  return out;
}
