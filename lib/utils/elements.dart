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
      Styles.primaryAccentColor,
      Styles.secondaryAccentColor,
    ],
  );
}

class ViewBoxContainer extends StatelessWidget {
  final Color color;
  final Widget child;
  const ViewBoxContainer(
      {Key? key, required this.child, this.color = Styles.boxBackgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: const Color(0x20000000),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 24,
              )
            ],
            borderRadius: BorderRadius.circular(15)),
        child: child);
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
