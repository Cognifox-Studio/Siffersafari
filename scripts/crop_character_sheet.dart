import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.containsKey('help') || parsed.containsKey('h') || args.isEmpty) {
    _printHelp();
    exit(0);
  }

  final inputPath = parsed['in'] ?? parsed['input'];
  final outputPath = parsed['out'] ?? parsed['output'];
  final side = (parsed['side'] ?? 'right').toLowerCase();
  final skipCenter = int.tryParse(parsed['skip-center'] ?? '10') ?? 10;
  final trimBg = (parsed['trim-bg'] ?? 'true').toLowerCase() != 'false';
  final bgTolerance = int.tryParse(parsed['bg-tolerance'] ?? '18') ?? 18;
  final margin = int.tryParse(parsed['margin'] ?? '8') ?? 8;
  final squareSize = int.tryParse(parsed['square'] ?? '0') ?? 0;

  if (inputPath == null || outputPath == null) {
    stderr.writeln('Missing required args: --in and --out');
    _printHelp();
    exit(2);
  }

  if (side != 'right' && side != 'left') {
    stderr.writeln('Invalid --side: $side (use left|right)');
    exit(2);
  }

  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Input not found: $inputPath');
    exit(2);
  }

  final bytes = inputFile.readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    stderr.writeln('Could not decode image: $inputPath');
    exit(2);
  }

  final image = _ensureRgba(decoded);

  stdout.writeln('---');
  stdout.writeln('Input: $inputPath');
  stdout.writeln(
    'Size: ${image.width}x${image.height} channels=${image.numChannels}',
  );

  final analysis = _analyzeByHalves(image, bgTolerance: bgTolerance);
  stdout.writeln('Analysis (bgTolerance=$bgTolerance):');
  stdout.writeln(
    '  left:  fg%=${analysis.leftFgPercent.toStringAsFixed(2)} bbox%=${analysis.leftBboxPercent.toStringAsFixed(2)} edgeNonBg=${analysis.leftEdgeNonBg}',
  );
  stdout.writeln(
    '  right: fg%=${analysis.rightFgPercent.toStringAsFixed(2)} bbox%=${analysis.rightBboxPercent.toStringAsFixed(2)} edgeNonBg=${analysis.rightEdgeNonBg}',
  );
  stdout.writeln('  seamNonBg@center±2: ${analysis.seamNonBg}');

  final w = image.width;
  final h = image.height;

  final half = w ~/ 2;
  final x0 = side == 'right' ? min(w - 1, half + skipCenter) : 0;
  final x1 = side == 'right' ? w : max(1, half - skipCenter);
  final cropW = max(1, x1 - x0);

  var cropped = img.copyCrop(image, x: x0, y: 0, width: cropW, height: h);

  if (trimBg) {
    final trimRect = _findForegroundTrimRect(
      cropped,
      tolerance: bgTolerance,
      margin: margin,
    );
    cropped = img.copyCrop(
      cropped,
      x: trimRect.x,
      y: trimRect.y,
      width: trimRect.w,
      height: trimRect.h,
    );
    stdout.writeln(
      'Trimmed to fg bbox (with margin=$margin): ${trimRect.x},${trimRect.y} ${trimRect.w}x${trimRect.h}',
    );
  }

  // Optional: pad to square and resize to a stable init size (e.g. 512x512).
  if (squareSize > 0) {
    cropped = _padToSquare(cropped);
    cropped = img.copyResize(
      cropped,
      width: squareSize,
      height: squareSize,
      interpolation: img.Interpolation.linear,
    );
    stdout.writeln('Squared+resized: ${cropped.width}x${cropped.height}');
  }

  final outFile = File(outputPath);
  outFile.parent.createSync(recursive: true);
  outFile.writeAsBytesSync(img.encodePng(cropped));
  stdout.writeln('Wrote: $outputPath');
}

img.Image _padToSquare(img.Image image) {
  final bg = _estimateBackgroundFill(image);
  final size = max(image.width, image.height);
  final out = img.Image(width: size, height: size, numChannels: 4);

  // Fill with background color (opaque) so ComfyUI gets a consistent init.
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      out.setPixelRgba(x, y, bg.r, bg.g, bg.b, 255);
    }
  }

  final ox = (size - image.width) ~/ 2;
  final oy = (size - image.height) ~/ 2;
  img.compositeImage(out, image, dstX: ox, dstY: oy);
  return out;
}

({int r, int g, int b}) _estimateBackgroundFill(img.Image image) {
  final corners = _estimateCornerBackgrounds(image);
  var rSum = 0;
  var gSum = 0;
  var bSum = 0;
  for (final c in corners) {
    rSum += c.r;
    gSum += c.g;
    bSum += c.b;
  }
  final n = corners.isEmpty ? 1 : corners.length;
  return (
    r: (rSum / n).round().clamp(0, 255),
    g: (gSum / n).round().clamp(0, 255),
    b: (bSum / n).round().clamp(0, 255),
  );
}

typedef _Rect = ({int x, int y, int w, int h});

class _HalfAnalysis {
  _HalfAnalysis({
    required this.leftFgPercent,
    required this.rightFgPercent,
    required this.leftBboxPercent,
    required this.rightBboxPercent,
    required this.leftEdgeNonBg,
    required this.rightEdgeNonBg,
    required this.seamNonBg,
  });

  final double leftFgPercent;
  final double rightFgPercent;
  final double leftBboxPercent;
  final double rightBboxPercent;
  final int leftEdgeNonBg;
  final int rightEdgeNonBg;
  final int seamNonBg;
}

_HalfAnalysis _analyzeByHalves(img.Image image, {required int bgTolerance}) {
  final w = image.width;
  final h = image.height;
  final half = w ~/ 2;

  bool isBg(img.Pixel p, List<({int r, int g, int b})> bgs) {
    for (final bg in bgs) {
      final dr = (p.r.toInt() - bg.r).abs();
      final dg = (p.g.toInt() - bg.g).abs();
      final db = (p.b.toInt() - bg.b).abs();
      if ((dr + dg + db) <= bgTolerance) return true;
    }
    return false;
  }

  final bgs = _estimateCornerBackgrounds(image);

  _Rect bboxForRange(int xStart, int xEnd) {
    var minX = xEnd;
    var minY = h;
    var maxX = -1;
    var maxY = -1;

    var fg = 0;
    for (var y = 0; y < h; y++) {
      for (var x = xStart; x < xEnd; x++) {
        final p = image.getPixel(x, y);
        if (p.a.toInt() == 0) continue;
        if (isBg(p, bgs)) continue;
        fg++;
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }

    if (fg == 0) {
      return (x: xStart, y: 0, w: max(1, xEnd - xStart), h: h);
    }

    return (
      x: minX,
      y: minY,
      w: max(1, maxX - minX + 1),
      h: max(1, maxY - minY + 1),
    );
  }

  int edgeNonBgForRange(int xStart, int xEnd) {
    var count = 0;
    for (var x = xStart; x < xEnd; x++) {
      final top = image.getPixel(x, 0);
      final bottom = image.getPixel(x, h - 1);
      if (top.a.toInt() != 0 && !isBg(top, bgs)) count++;
      if (bottom.a.toInt() != 0 && !isBg(bottom, bgs)) count++;
    }
    for (var y = 0; y < h; y++) {
      final left = image.getPixel(xStart, y);
      final right = image.getPixel(xEnd - 1, y);
      if (left.a.toInt() != 0 && !isBg(left, bgs)) count++;
      if (right.a.toInt() != 0 && !isBg(right, bgs)) count++;
    }
    return count;
  }

  double fgPercentForRange(int xStart, int xEnd) {
    var fg = 0;
    final total = (xEnd - xStart) * h;
    for (var y = 0; y < h; y++) {
      for (var x = xStart; x < xEnd; x++) {
        final p = image.getPixel(x, y);
        if (p.a.toInt() == 0) continue;
        if (isBg(p, bgs)) continue;
        fg++;
      }
    }
    return (fg / total) * 100.0;
  }

  final leftBbox = bboxForRange(0, half);
  final rightBbox = bboxForRange(half, w);

  final leftArea = (leftBbox.w * leftBbox.h) / (half * h) * 100.0;
  final rightArea = (rightBbox.w * rightBbox.h) / ((w - half) * h) * 100.0;

  // seam check: count non-bg pixels in center +/- 2 columns
  final seamX0 = max(0, half - 2);
  final seamX1 = min(w, half + 3);
  var seamNonBg = 0;
  for (var y = 0; y < h; y++) {
    for (var x = seamX0; x < seamX1; x++) {
      final p = image.getPixel(x, y);
      if (p.a.toInt() != 0 && !isBg(p, bgs)) seamNonBg++;
    }
  }

  return _HalfAnalysis(
    leftFgPercent: fgPercentForRange(0, half),
    rightFgPercent: fgPercentForRange(half, w),
    leftBboxPercent: leftArea,
    rightBboxPercent: rightArea,
    leftEdgeNonBg: edgeNonBgForRange(0, half),
    rightEdgeNonBg: edgeNonBgForRange(half, w),
    seamNonBg: seamNonBg,
  );
}

_Rect _findForegroundTrimRect(
  img.Image image, {
  required int tolerance,
  required int margin,
}) {
  final w = image.width;
  final h = image.height;
  final bgs = _estimateCornerBackgrounds(image);

  bool isBg(img.Pixel p) {
    for (final bg in bgs) {
      final dr = (p.r.toInt() - bg.r).abs();
      final dg = (p.g.toInt() - bg.g).abs();
      final db = (p.b.toInt() - bg.b).abs();
      if ((dr + dg + db) <= tolerance) return true;
    }
    return false;
  }

  var minX = w;
  var minY = h;
  var maxX = -1;
  var maxY = -1;

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = image.getPixel(x, y);
      if (p.a.toInt() == 0) continue;
      if (isBg(p)) continue;

      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }

  if (maxX < 0 || maxY < 0) {
    return (x: 0, y: 0, w: w, h: h);
  }

  minX = max(0, minX - margin);
  minY = max(0, minY - margin);
  maxX = min(w - 1, maxX + margin);
  maxY = min(h - 1, maxY + margin);

  return (
    x: minX,
    y: minY,
    w: max(1, maxX - minX + 1),
    h: max(1, maxY - minY + 1),
  );
}

img.Image _ensureRgba(img.Image source) {
  if (source.numChannels == 4) return source;

  final out = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 4,
  );

  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final p = source.getPixel(x, y);
      out.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), 255);
    }
  }

  return out;
}

List<({int r, int g, int b})> _estimateCornerBackgrounds(img.Image image) {
  const sample = 6;
  final points = <(int x0, int y0)>[
    (0, 0),
    (image.width - sample, 0),
    (0, image.height - sample),
    (image.width - sample, image.height - sample),
  ];

  final out = <({int r, int g, int b})>[];
  for (final (x0, y0) in points) {
    var rSum = 0;
    var gSum = 0;
    var bSum = 0;
    var n = 0;
    for (var y = y0; y < y0 + sample; y++) {
      for (var x = x0; x < x0 + sample; x++) {
        final p = image.getPixel(x, y);
        rSum += p.r.toInt();
        gSum += p.g.toInt();
        bSum += p.b.toInt();
        n++;
      }
    }
    out.add(
      (r: (rSum / n).round(), g: (gSum / n).round(), b: (bSum / n).round()),
    );
  }
  return out;
}

void _printHelp() {
  stdout.writeln('''
Crop away one side of a "character sheet" (two panels side-by-side).
Also prints a simple per-half foreground analysis to verify if the image
contains 2 subjects and whether the center seam is non-background.

Required:
  --in <path>         Input PNG/JPG
  --out <path>        Output PNG

Optional:
  --side <left|right> Which half to keep (default right)
  --skip-center <px>  Skip pixels around center seam (default 10)
  --trim-bg <bool>    Trim background around subject (default true)
  --bg-tolerance <n>  Background distance tolerance (default 18)
  --margin <px>       Margin around trimmed bbox (default 8)
  --square <n>         If set (>0), pad to square and resize to n x n (e.g. 512)

Example:
  dart run scripts/crop_character_sheet.dart --in in.png --out out.png --side right --square 512
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
