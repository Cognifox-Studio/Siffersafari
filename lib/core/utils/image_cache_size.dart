import 'package:flutter/widgets.dart';

int imageCacheExtent(BuildContext context, double logicalPixels) {
  final scaledPixels =
      (logicalPixels * MediaQuery.devicePixelRatioOf(context)).round();
  return scaledPixels < 1 ? 1 : scaledPixels;
}
