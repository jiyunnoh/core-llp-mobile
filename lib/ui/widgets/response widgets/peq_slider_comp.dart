import 'package:flutter/material.dart';

class PeqSliderThumbShape extends SliderComponentShape {
  final double width;
  final double height;

  const PeqSliderThumbShape({
    this.width = 10.0,
    this.height = 20.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;

    final rect = Rect.fromCircle(center: center, radius: 1.0);
    final myRect = Rect.fromPoints(
        Offset(rect.left, rect.top + 20), Offset(rect.right, rect.bottom - 20));

    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRect(myRect, fillPaint);
    canvas.drawRect(myRect, borderPaint);
  }
}

class PeqSliderTrackShape extends SliderTrackShape {
  // SliderTrackShape.getPreferredRect' ('Rect Function({bool isDiscrete, bool isEnabled, Offset offset, required RenderBox parentBox, required SliderThemeData sliderTheme})')
  @override
  Rect getPreferredRect(
      {required RenderBox parentBox,
      Offset offset = Offset.zero,
      required SliderThemeData sliderTheme,
      bool isEnabled = true,
      bool isDiscrete = true}) {
    final double thumbWidth =
        sliderTheme.thumbShape!.getPreferredSize(true, isDiscrete).width;
    final double trackHeight = sliderTheme.trackHeight!;
    assert(thumbWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= thumbWidth);
    assert(parentBox.size.height >= trackHeight);

    final double trackLeft = offset.dx + thumbWidth / 2;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - thumbWidth;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset,
      {required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required Animation<double> enableAnimation,
      required Offset thumbCenter,
      Offset? secondaryOffset,
      bool isEnabled = true,
      bool isDiscrete = true,
      required TextDirection textDirection}) {
    if (sliderTheme.trackHeight == 0) {
      return;
    }
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint fillPaint = Paint()
      ..color = sliderTheme.activeTrackColor!
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final pathSegment = Path()
      ..moveTo(trackRect.left, trackRect.top + 20)
      ..lineTo(trackRect.left, trackRect.bottom - 20)
      ..moveTo(trackRect.left, trackRect.top)
      ..lineTo(trackRect.right, trackRect.top)
      ..moveTo(trackRect.right, trackRect.top + 20)
      ..lineTo(trackRect.right, trackRect.bottom - 20)
      ..moveTo(trackRect.right, trackRect.bottom)
      ..lineTo(trackRect.left, trackRect.bottom);

    context.canvas.drawPath(pathSegment, fillPaint);
    context.canvas.drawPath(pathSegment, borderPaint);
  }
}
