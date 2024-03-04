import 'dart:math';
import 'package:flutter/material.dart';

import 'color_picker_configs.dart';

/// A padding used to calculate bar height(thumbRadius * 2 - kBarPadding).
const _kBarPadding = 4;

/// A widget that allows users to pick colors from a gradient bar.
///
/// The `BarColorPicker` widget provides a horizontal or vertical bar with a thumb that users can drag to select a color from a gradient.
///
/// Example Usage:
/// ```dart
/// BarColorPicker(
///   pickMode: PickMode.color,
///   length: 200,
///   initialColor: Color(0xffff0000),
///   thumbColor: Colors.black,
///   colorListener: (colorValue) {
///     // Handle the selected color change here
///   },
/// )
/// ```
class BarColorPicker extends StatefulWidget {
  /// The pick mode, which determines the available color options.
  final PickMode pickMode;

  /// The width of the bar if it is horizontal, or the height if it is vertical.
  final double length;

  /// A listener that receives color pick events.
  final Function(int value) colorListener;

  /// The corner radius of the picker bar for each corner.
  final double cornerRadius;

  /// Specifies whether the bar is horizontal (`true`) or vertical (`false`).
  final bool horizontal;

  /// The fill color of the thumb.
  final Color thumbColor;

  /// The radius of the thumb.
  final double thumbRadius;

  /// The initial color to be displayed.
  final Color initialColor;

  /// Callback function that is called when the thumb position changes.
  final ValueChanged? onPositionChange;

  /// The initial position of the thumb in the bar. If not provided, it will be estimated based on the gradient and an initial color.
  final double? initPosition;

  const BarColorPicker({
    super.key,
    this.pickMode = PickMode.color,
    this.horizontal = true,
    this.length = 200,
    this.cornerRadius = 0.0,
    this.thumbRadius = 6,
    this.initialColor = const Color(0xffff0000),
    this.thumbColor = Colors.black,
    this.onPositionChange,
    this.initPosition,
    required this.colorListener,
  });

  @override
  createState() => _BarColorPickerState();
}

class _BarColorPickerState extends State<BarColorPicker> {
  /// The current percentage position in the gradient.
  double percent = 0.0;

  /// List of colors used in the gradient.
  late List<Color> colors;

  /// Width of the color bar.
  late double barWidth;

  /// Height of the color bar.
  late double barHeight;

  @override
  void initState() {
    super.initState();
    // Initialize the 'colors' list and 'percent' based on 'pickMode'.
    switch (widget.pickMode) {
      case PickMode.color:
        colors = const [
          Color(0xff000000),
          Color(0xffffffff),
          Color(0xffff0000),
          Color(0xffffff00),
          Color(0xff00ff00),
          Color(0xff00ffff),
          Color(0xff0000ff),
          Color(0xffff00ff),
          Color(0xffff0000),
        ];
        break;
      case PickMode.grey:
        colors = const [Color(0xff000000), Color(0xffffffff)];
        break;
    }

    // Initialize 'percent' based on 'initPosition' or target 'initialColor'.
    percent = widget.initPosition ??
        _estimateColorPositionInGradient(colors, widget.initialColor);
  }

  /// Estimates the position of a color within the gradient.
  double _estimateColorPositionInGradient(
      List<Color> gradientColors, Color targetColor) {
    double minDistance = double.infinity;
    double estimatedPosition = 0.0;

    for (int i = 0; i < gradientColors.length - 1; i++) {
      Color color1 = gradientColors[i];
      Color color2 = gradientColors[i + 1];

      // Linear interpolation factor (t) that brings color1 towards color2
      double t = _findBestInterpolation(color1, color2, targetColor);

      // Interpolated color at position t
      Color interpolatedColor = Color.lerp(color1, color2, t)!;

      // Calculate distance from interpolated color to target color
      double distance = _calculateColorDistance(interpolatedColor, targetColor);

      if (distance < minDistance) {
        minDistance = distance;
        estimatedPosition = (i + t) / (gradientColors.length - 1);
      }
    }

    return estimatedPosition;
  }

  /// Finds the best interpolation factor to approximate a target color.
  double _findBestInterpolation(Color a, Color b, Color target) {
    // This function should return a value between 0 and 1, which is the best
    // interpolation factor (t) that brings color 'a' towards color 'b' to
    // approximate the target color. This can be a complex task depending on
    // how accurate you want it to be. A simple approach would be to try several
    // values of t and choose the one that results in a color closest to the target.
    // For more accuracy, more sophisticated methods may be used.

    double bestT = 0;
    double minDistance = double.infinity;

    for (double t = 0; t <= 1; t += 0.01) {
      Color interpolated = Color.lerp(a, b, t)!;
      double distance = _calculateColorDistance(interpolated, target);
      if (distance < minDistance) {
        minDistance = distance;
        bestT = t;
      }
    }

    return bestT;
  }

  /// Calculates the Euclidean distance between two colors.
  double _calculateColorDistance(Color color1, Color color2) {
    num r = color1.red - color2.red;
    num g = color1.green - color2.green;
    num b = color1.blue - color2.blue;

    return sqrt(r * r + g * g + b * b);
  }

  /// Gets the color at a specific position within the gradient.
  Color _getColorAtPosition(Gradient gradient, double position) {
    // Ensure the position is within the valid range
    widget.onPositionChange?.call(position);
    position = position.clamp(0.0, 1.0);

    if (position < 0) {
      return colors.first;
    } else if (position >= 1) {
      return colors.last;
    }

    if (colors.isEmpty) {
      throw ArgumentError("The colors list must not be empty.");
    } else if (colors.length == 1) {
      return colors.first;
    }

    final int segmentCount = colors.length - 1;
    final double segmentWidth = 1.0 / segmentCount;

    final int startIndex = (position / segmentWidth).floor();
    final int endIndex = startIndex + 1;

    final double t = (position - startIndex * segmentWidth) / segmentWidth;

    return Color.lerp(colors[startIndex], colors[endIndex], t)!;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.horizontal) {
      barWidth = widget.length;
      barHeight = widget.thumbRadius * 2 - _kBarPadding;
    } else {
      barWidth = widget.thumbRadius * 2 - _kBarPadding;
      barHeight = widget.length;
    }
    final thumbRadius = widget.thumbRadius;
    final horizontal = widget.horizontal;

    double? thumbLeft, thumbTop;
    if (horizontal) {
      thumbLeft = barWidth * percent;
    } else {
      thumbTop = barHeight * percent;
    }
    // build thumb
    var thumb = Positioned(
      left: thumbLeft,
      top: thumbTop,
      child: Container(
        padding: EdgeInsets.zero,
        width: thumbRadius * 2,
        height: thumbRadius * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(thumbRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x45000000),
              spreadRadius: 2,
              blurRadius: 3,
            )
          ],
          color: widget.thumbColor,
        ),
      ),
    );

    // build frame
    double frameWidth, frameHeight;
    if (horizontal) {
      frameWidth = barWidth + thumbRadius * 2;
      frameHeight = thumbRadius * 2;
    } else {
      frameWidth = thumbRadius * 2;
      frameHeight = barHeight + thumbRadius * 2;
    }
    Widget frame = SizedBox(width: frameWidth, height: frameHeight);

    // build content
    Gradient gradient;
    double left, top;
    if (horizontal) {
      gradient = LinearGradient(colors: colors);
      left = thumbRadius;
      top = (thumbRadius * 2 - barHeight) / 2;
    } else {
      gradient = LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter);
      left = (thumbRadius * 2 - barWidth) / 2;
      top = thumbRadius;
    }
    var content = Positioned(
      left: left,
      top: top,
      child: Container(
        padding: EdgeInsets.zero,
        width: barWidth,
        height: barHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          gradient: gradient,
        ),
        child: const Text(''),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanDown: (details) =>
          handleTouch(details.globalPosition, context, gradient),
      onPanStart: (details) =>
          handleTouch(details.globalPosition, context, gradient),
      onPanUpdate: (details) =>
          handleTouch(details.globalPosition, context, gradient),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 5),
        child: Stack(
          children: [frame, content, thumb],
        ),
      ),
    );
  }

  /// calculate colors picked from palette and update our states.
  void handleTouch(
      Offset globalPosition, BuildContext context, Gradient gradient) {
    var box = context.findRenderObject() as RenderBox;
    var localPosition = box.globalToLocal(globalPosition);
    double percent;
    if (widget.horizontal) {
      percent = (localPosition.dx - widget.thumbRadius) / barWidth;
    } else {
      percent = (localPosition.dy - widget.thumbRadius) / barHeight;
    }
    percent = min(max(0.0, percent), 1.0);
    setState(() {
      this.percent = percent;
    });
    switch (widget.pickMode) {
      case PickMode.color:
        final Color colorAtPosition = _getColorAtPosition(gradient, percent);
        widget.colorListener(colorAtPosition.value);
        break;
      case PickMode.grey:
        final channel = (0xff * percent).toInt();
        widget.colorListener(
            Color.fromARGB(0xff, channel, channel, channel).value);
        break;
    }
  }
}
