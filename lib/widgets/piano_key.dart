import 'package:flutter/material.dart';

const double _pressedLightnessShift = 0.25;

class PianoKey extends StatelessWidget {
  final bool isBlack;
  final double width;
  final double height;
  final Color color;
  final bool showLabel;
  final String note;
  final bool pressed;
  final String? keyboardLabel;

  const PianoKey({
    super.key,
    required this.note,
    required this.isBlack,
    required this.width,
    required this.height,
    required this.color,
    required this.showLabel,
    required this.pressed,
    this.keyboardLabel,
  });

  Color get _displayColor {
    if (!pressed) return color;
    final hsl = HSLColor.fromColor(color);
    final newLightness = hsl.lightness < 0.5
        ? (hsl.lightness + _pressedLightnessShift).clamp(0.0, 1.0)
        : (hsl.lightness - _pressedLightnessShift).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _displayColor,
        border: Border.all(color: Colors.black87, width: isBlack ? 0.5 : 1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
        boxShadow: isBlack
            ? [const BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 3))]
            : null,
      ),
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (keyboardLabel != null)
            Text(
              keyboardLabel!,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isBlack ? Colors.amber : Colors.blue[700],
              ),
            ),
          if (showLabel)
            Text(
              note,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isBlack ? Colors.white70 : Colors.black54,
              ),
            ),
        ],
      ),
    );
  }
}
