import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.containsKey('help') || parsed.containsKey('h') || args.isEmpty) {
    _printHelp();
    exit(0);
  }

  final dirPath = parsed['dir'] ?? parsed['d'];
  if (dirPath == null) {
    stderr.writeln('Missing required arg: --dir');
    _printHelp();
    exit(2);
  }

  final prefix = parsed['prefix'];

  final dir = Directory(dirPath);
  if (!dir.existsSync()) {
    stderr.writeln('Directory not found: $dirPath');
    exit(2);
  }

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.png'))
      .where((f) {
        if (prefix == null || prefix.trim().isEmpty) return true;
        return f.uri.pathSegments.last.startsWith(prefix);
      })
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    stderr.writeln('No PNG files found in: $dirPath');
    exit(2);
  }

  final decoded = <_Frame>[];
  for (final f in files) {
    final bytes = f.readAsBytesSync();
    final sha = sha256.convert(bytes).toString().substring(0, 12);

    final image = img.decodePng(bytes);
    if (image == null) {
      stderr.writeln('Failed to decode: ${f.path}');
      continue;
    }

    final aHash = _averageHash(image, size: 8);
    final small = img.copyResize(image, width: 64, height: 64, interpolation: img.Interpolation.average);

    decoded.add(
      _Frame(
        name: f.uri.pathSegments.last,
        sha12: sha,
        w: image.width,
        h: image.height,
        aHash: aHash,
        small: small,
      ),
    );
  }

  if (decoded.length < 2) {
    stdout.writeln('Only ${decoded.length} decodable frame(s). Nothing to compare.');
    exit(0);
  }

  stdout.writeln('Frames: ${decoded.length}');
  stdout.writeln('Dir: $dirPath');
  stdout.writeln('---');

  for (final fr in decoded) {
    stdout.writeln('${fr.name}  sha=${fr.sha12}  ${fr.w}x${fr.h}  aHash=${_hashToHex(fr.aHash)}');
  }

  stdout.writeln('---');
  stdout.writeln('Similarity (lower = more similar):');

  final first = decoded.first;
  final diffsToFirst = <double>[];
  for (final fr in decoded) {
    final d = _meanAbsDiff(first.small, fr.small);
    diffsToFirst.add(d);
  }

  final diffsConsecutive = <double>[];
  final diffsConsecutiveRgba = <double>[];
  final hammingConsecutive = <int>[];
  final bestShift = <({int dx, int dy, double diff})>[];
  for (var i = 1; i < decoded.length; i++) {
    diffsConsecutive.add(_meanAbsDiff(decoded[i - 1].small, decoded[i].small));
    diffsConsecutiveRgba.add(_meanAbsDiffRgbaPremultiplied(decoded[i - 1].small, decoded[i].small));
    hammingConsecutive.add(_hamming64(decoded[i - 1].aHash, decoded[i].aHash));
    bestShift.add(_bestTranslationMatch(decoded[i - 1].small, decoded[i].small, maxShift: 4));
  }

  for (var i = 0; i < decoded.length; i++) {
    final fr = decoded[i];
    final dFirst = diffsToFirst[i];
    final dPrev = i == 0 ? double.nan : diffsConsecutive[i - 1];
    final hPrev = i == 0 ? null : hammingConsecutive[i - 1];

    final dPrevRgba = i == 0 ? double.nan : diffsConsecutiveRgba[i - 1];
    final shift = i == 0 ? null : bestShift[i - 1];

    final prevText = i == 0
        ? 'prev=  -'
        : 'prev=${dPrev.toStringAsFixed(4)} rgb  ${dPrevRgba.toStringAsFixed(4)} rgba (aHash Δ=${hPrev.toString().padLeft(2)})';

    final shiftText = i == 0
        ? ''
        : '  bestShift=(${shift!.dx.toString().padLeft(2)},${shift.dy.toString().padLeft(2)}) diff=${shift.diff.toStringAsFixed(4)}';

    stdout.writeln(
      '${fr.name.padRight(14)} first=${dFirst.toStringAsFixed(4)}  $prevText$shiftText',
    );
  }

  stdout.writeln('---');
  final maxToFirst = diffsToFirst.reduce(math.max);
  final minToFirst = diffsToFirst.reduce(math.min);
  final avgToFirst = diffsToFirst.reduce((a, b) => a + b) / diffsToFirst.length;

  final maxPrev = diffsConsecutive.isEmpty ? 0.0 : diffsConsecutive.reduce(math.max);
  final minPrev = diffsConsecutive.isEmpty ? 0.0 : diffsConsecutive.reduce(math.min);
  final avgPrev = diffsConsecutive.isEmpty
      ? 0.0
      : diffsConsecutive.reduce((a, b) => a + b) / diffsConsecutive.length;

    final maxPrevRgba = diffsConsecutiveRgba.isEmpty ? 0.0 : diffsConsecutiveRgba.reduce(math.max);
    final minPrevRgba = diffsConsecutiveRgba.isEmpty ? 0.0 : diffsConsecutiveRgba.reduce(math.min);
    final avgPrevRgba = diffsConsecutiveRgba.isEmpty
      ? 0.0
      : diffsConsecutiveRgba.reduce((a, b) => a + b) / diffsConsecutiveRgba.length;

  stdout.writeln('Summary (mean abs diff @64x64, 0..1-ish):');
  stdout.writeln('  to first:  min=${minToFirst.toStringAsFixed(4)} avg=${avgToFirst.toStringAsFixed(4)} max=${maxToFirst.toStringAsFixed(4)}');
  stdout.writeln('  prev diff: min=${minPrev.toStringAsFixed(4)} avg=${avgPrev.toStringAsFixed(4)} max=${maxPrev.toStringAsFixed(4)}');
  stdout.writeln('  prev rgba: min=${minPrevRgba.toStringAsFixed(4)} avg=${avgPrevRgba.toStringAsFixed(4)} max=${maxPrevRgba.toStringAsFixed(4)}');

  if (bestShift.isNotEmpty) {
    final shiftMag = bestShift
        .map((s) => math.sqrt((s.dx * s.dx + s.dy * s.dy).toDouble()))
        .toList(growable: false);
    final avgShift = shiftMag.reduce((a, b) => a + b) / shiftMag.length;
    final maxShiftMag = shiftMag.reduce(math.max);
    stdout.writeln('  bestShift: avg=${avgShift.toStringAsFixed(2)}px max=${maxShiftMag.toStringAsFixed(2)}px (search ±4px)');
  }

  final maxH = hammingConsecutive.isEmpty ? 0 : hammingConsecutive.reduce(math.max);
  final minH = hammingConsecutive.isEmpty ? 0 : hammingConsecutive.reduce(math.min);
  final avgH = hammingConsecutive.isEmpty
      ? 0.0
      : hammingConsecutive.reduce((a, b) => a + b) / hammingConsecutive.length;

  stdout.writeln('  aHash Δ:   min=$minH avg=${avgH.toStringAsFixed(1)} max=$maxH (0..64)');

  // Heuristic guidance (very rough):
  // - If aHash deltas are ~0 and premultiplied RGBA diffs are tiny, frames are likely "same pose + noise".
  // - If bestShift is non-trivial AND shifted diff becomes tiny, motion is likely mostly translation.
  if (decoded.length >= 2) {
    final likelyStatic = avgH < 1.0 && avgPrevRgba < 0.030;

    var likelyMostlyTranslation = false;
    if (bestShift.isNotEmpty) {
      final avgShifted = bestShift.map((s) => s.diff).reduce((a, b) => a + b) / bestShift.length;
      final shiftMag = bestShift
          .map((s) => math.sqrt((s.dx * s.dx + s.dy * s.dy).toDouble()))
          .toList(growable: false);
      final avgShift = shiftMag.reduce((a, b) => a + b) / shiftMag.length;

      // If we can explain most changes by a small shift, shifted diff should be much lower.
      if (avgShift >= 0.75 && avgShifted <= (avgPrevRgba * 0.55)) {
        likelyMostlyTranslation = true;
      }
    }

    stdout.writeln('Assessment (heuristic):');
    if (likelyMostlyTranslation) {
      stdout.writeln('  - Motion risk: looks like mostly translation between frames.');
    } else if (likelyStatic) {
      stdout.writeln('  - Motion risk: frames likely too similar (pose change not visible).');
    } else {
      stdout.writeln('  - Looks more alive: variation is likely visible frame-to-frame.');
    }
  }
}

void _printHelp() {
  stdout.writeln('''
Audit animation frames for similarity.

Required:
  --dir <path>        Directory with PNG frames

Optional:
  --prefix <text>     Only include files whose name starts with prefix (e.g. idle_)

Example:
  dart run scripts/audit_animation_frames.dart --dir assets/images/characters/character_v2/idle --prefix idle_
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

class _Frame {
  _Frame({
    required this.name,
    required this.sha12,
    required this.w,
    required this.h,
    required this.aHash,
    required this.small,
  });

  final String name;
  final String sha12;
  final int w;
  final int h;
  final int aHash; // 64-bit packed
  final img.Image small;
}

int _averageHash(img.Image input, {required int size}) {
  final resized = img.copyResize(
    input,
    width: size,
    height: size,
    interpolation: img.Interpolation.average,
  );

  final values = <int>[];
  var sum = 0.0;
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final p = resized.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final v = ((r + g + b) / 3).round();
      values.add(v);
      sum += v;
    }
  }

  final avg = sum / values.length;

  var bits = 0;
  for (var i = 0; i < values.length; i++) {
    if (values[i] >= avg) {
      bits |= (1 << i);
    }
  }

  return bits;
}

int _hamming64(int a, int b) {
  var x = a ^ b;
  var count = 0;
  while (x != 0) {
    x &= (x - 1);
    count++;
  }
  return count;
}

String _hashToHex(int v) {
  // 64 bits => 16 hex chars.
  final u = v.toUnsigned(64);
  return u.toRadixString(16).padLeft(16, '0');
}

double _meanAbsDiff(img.Image a, img.Image b) {
  if (a.width != b.width || a.height != b.height) {
    throw StateError('Image sizes differ: ${a.width}x${a.height} vs ${b.width}x${b.height}');
  }

  var sum = 0.0;
  final n = a.width * a.height * 3;

  for (var y = 0; y < a.height; y++) {
    for (var x = 0; x < a.width; x++) {
      final pa = a.getPixel(x, y);
      final pb = b.getPixel(x, y);

      sum += (pa.r.toInt() - pb.r.toInt()).abs();
      sum += (pa.g.toInt() - pb.g.toInt()).abs();
      sum += (pa.b.toInt() - pb.b.toInt()).abs();
    }
  }

  // Normalize to roughly 0..1.
  return sum / (n * 255.0);
}

double _meanAbsDiffRgbaPremultiplied(img.Image a, img.Image b) {
  if (a.width != b.width || a.height != b.height) {
    throw StateError('Image sizes differ: ${a.width}x${a.height} vs ${b.width}x${b.height}');
  }

  var sum = 0.0;
  final n = a.width * a.height * 4;

  for (var y = 0; y < a.height; y++) {
    for (var x = 0; x < a.width; x++) {
      final pa = a.getPixel(x, y);
      final pb = b.getPixel(x, y);

      final aa = pa.a.toInt();
      final ab = pb.a.toInt();

      // Premultiply so transparent areas don't dominate.
      final ar = (pa.r.toInt() * aa) ~/ 255;
      final ag = (pa.g.toInt() * aa) ~/ 255;
      final ablu = (pa.b.toInt() * aa) ~/ 255;

      final br = (pb.r.toInt() * ab) ~/ 255;
      final bg = (pb.g.toInt() * ab) ~/ 255;
      final bblu = (pb.b.toInt() * ab) ~/ 255;

      sum += (ar - br).abs();
      sum += (ag - bg).abs();
      sum += (ablu - bblu).abs();
      sum += (aa - ab).abs();
    }
  }

  return sum / (n * 255.0);
}

({int dx, int dy, double diff}) _bestTranslationMatch(img.Image a, img.Image b, {required int maxShift}) {
  if (a.width != b.width || a.height != b.height) {
    throw StateError('Image sizes differ: ${a.width}x${a.height} vs ${b.width}x${b.height}');
  }

  var bestDx = 0;
  var bestDy = 0;
  var best = double.infinity;

  for (var dy = -maxShift; dy <= maxShift; dy++) {
    for (var dx = -maxShift; dx <= maxShift; dx++) {
      final d = _meanAbsDiffRgbaPremultipliedShifted(a, b, dx: dx, dy: dy);
      if (d < best) {
        best = d;
        bestDx = dx;
        bestDy = dy;
      }
    }
  }

  return (dx: bestDx, dy: bestDy, diff: best);
}

double _meanAbsDiffRgbaPremultipliedShifted(img.Image a, img.Image b, {required int dx, required int dy}) {
  // Compare a(x,y) with b(x+dx, y+dy). Out-of-bounds in b => transparent.
  var sum = 0.0;
  final n = a.width * a.height * 4;

  for (var y = 0; y < a.height; y++) {
    final by = y + dy;
    for (var x = 0; x < a.width; x++) {
      final bx = x + dx;

      final pa = a.getPixel(x, y);
      final aa = pa.a.toInt();
      final ar = (pa.r.toInt() * aa) ~/ 255;
      final ag = (pa.g.toInt() * aa) ~/ 255;
      final ablu = (pa.b.toInt() * aa) ~/ 255;

      int br;
      int bg;
      int bblu;
      int ab;

      if (bx < 0 || by < 0 || bx >= b.width || by >= b.height) {
        br = 0;
        bg = 0;
        bblu = 0;
        ab = 0;
      } else {
        final pb = b.getPixel(bx, by);
        ab = pb.a.toInt();
        br = (pb.r.toInt() * ab) ~/ 255;
        bg = (pb.g.toInt() * ab) ~/ 255;
        bblu = (pb.b.toInt() * ab) ~/ 255;
      }

      sum += (ar - br).abs();
      sum += (ag - bg).abs();
      sum += (ablu - bblu).abs();
      sum += (aa - ab).abs();
    }
  }

  return sum / (n * 255.0);
}
