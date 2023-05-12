import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/styles.dart';

LinearGradient textGradient() {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Styles.purpleColor,
      Styles.primaryAccentColor,
    ],
  );
}

List<BoxShadow>? neumorphicShadow() {
  return [
    BoxShadow(
      color:
          HSLColor.fromAHSL(1, 256.3636363636, 0.379310344828, 0.843137254902)
              .toColor(),
      offset: Offset(10, 10),
      blurRadius: 20,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: HSLColor.fromAHSL(1, 256.3636363636, 0.379310344828, 1).toColor(),
      offset: Offset(-10, -10),
      blurRadius: 20,
      spreadRadius: -5,
    )
  ];
}

class ViewBoxContainer extends StatelessWidget {
  final Color color;
  final Widget child;
  final String imageUrl;

  const ViewBoxContainer(
      {Key? key,
      required this.child,
      this.color = Styles.boxBackgroundColor,
      this.imageUrl = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: this.imageUrl != '' ? 200 : null,
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: this.imageUrl != ''
                ? DecorationImage(
                    image: NetworkImage(imageUrl), fit: BoxFit.cover)
                : null,
            color: color,
            boxShadow: const [
              const BoxShadow(
                color: Color(0x12000000),
                offset: Offset(0, 3),
                blurRadius: 30,
              )
            ],
            borderRadius: BorderRadius.circular(15)),
        child: child);
  }
}

class ImageBoxContainer extends StatelessWidget {
  final Color color;
  final Widget child;
  final String imageUrl;

  const ImageBoxContainer(
      {Key? key,
      required this.child,
      this.color = Styles.primaryAccentColor,
      this.imageUrl = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (this.imageUrl == '')
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: color,
            boxShadow: const [
              const BoxShadow(
                color: Color(0x12000000),
                offset: Offset(0, 3),
                blurRadius: 30,
              )
            ],
            borderRadius: new BorderRadius.vertical(
              top: new Radius.circular(15.0),
              //right: new Radius.circular(20.0),
            ),
            // borderRadius: BorderRadius.circular(15)
          ),
          child: Center(
            child: CircularProgressIndicator(color: Styles.whiteColor),
          ),
        ),
      if (this.imageUrl != '')
        Container(
            width: double.infinity,
            height: this.imageUrl != '' ? 150 : null,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              image: DecorationImage(
                  image: NetworkImage(imageUrl), fit: BoxFit.cover),

              color: color,
              boxShadow: const [
                const BoxShadow(
                  color: Color(0x12000000),
                  offset: Offset(0, 3),
                  blurRadius: 30,
                )
              ],
              borderRadius: new BorderRadius.vertical(
                top: new Radius.circular(15.0),
                //right: new Radius.circular(20.0),
              ),
              // borderRadius: BorderRadius.circular(15)
            )),
      Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: new BorderRadius.vertical(
                bottom: new Radius.circular(15.0),
              )),
          child: child)
    ]);
  }
}

class DottedBox extends StatelessWidget {
  const DottedBox(
      {Key? key,
      required this.value,
      required this.title,
      this.color = Colors.transparent})
      : super(key: key);

  final double value;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            color: Colors.black12,
            padding: const EdgeInsets.all(6),
            child: Center(
                child: (color == Colors.transparent)
                    ? GradientText(
                        value.toStringAsFixed(2),
                        gradient: textGradient(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : Text(
                        value.toStringAsFixed(2),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          color: color,
                          fontWeight: FontWeight.w900,
                        ),
                      )),
          ),
          Positioned.fill(
              top: -8,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  color: Styles.boxBackgroundColor,
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.black26,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class GradientRectSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  //https://www.youtube.com/watch?v=Wl4F5V6BoJw
  /// Create a slider track that draws two rectangles with rounded outer edges.
  final LinearGradient gradient;
  final bool darkenInactive;
  const GradientRectSliderTrackShape(
      {this.gradient:
          const LinearGradient(colors: [Colors.lightBlue, Colors.blue]),
      this.darkenInactive: true});

  @override
  void paint(PaintingContext context, Offset offset,
      {required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required Animation<double> enableAnimation,
      required Offset thumbCenter,
      Offset? secondaryOffset,
      bool isEnabled = false,
      bool isDiscrete = false,
      required TextDirection textDirection}) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting  can be a no-op.
    if (sliderTheme.trackHeight! <= 0) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = darkenInactive
        ? ColorTween(
            begin: sliderTheme.disabledInactiveTrackColor,
            end: sliderTheme.inactiveTrackColor)
        : activeTrackColorTween;
    final Paint activePaint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    Paint leftTrackPaint;
    Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }
    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular(trackRect.height / 2 + 1);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        (textDirection == TextDirection.ltr)
            ? trackRect.top // - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        thumbCenter.dx,
        (textDirection == TextDirection.ltr)
            ? trackRect.bottom // + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
        bottomLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
      ),
      leftTrackPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        (textDirection == TextDirection.rtl)
            ? trackRect.top // - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        trackRect.right,
        (textDirection == TextDirection.rtl)
            ? trackRect.bottom // + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
        bottomRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
      ),
      rightTrackPaint,
    );
  }
}

class ThumbShape extends RoundSliderThumbShape {
  final _indicatorShape = const PaddleSliderValueIndicatorShape();

  const ThumbShape();
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
    super.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      sliderTheme: sliderTheme,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      textDirection: textDirection,
    );
    _indicatorShape.paint(
      context,
      center,
      activationAnimation: const AlwaysStoppedAnimation(1),
      enableAnimation: enableAnimation,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      value: value,
      textScaleFactor: 0.8,
      sizeWithOverflow: sizeWithOverflow,
      isDiscrete: isDiscrete,
      textDirection: textDirection,
    );
  }
}
