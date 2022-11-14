import "package:flutter/material.dart";

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    Key? key,
    required this.gradient,
    this.textAlign = TextAlign.left,
    this.style,
        this.overflow,
  });

  final String text;
  final TextAlign textAlign;
  final TextStyle? style;
  final Gradient gradient;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
      ),
    );
  }
}
