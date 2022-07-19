import "package:flutter/material.dart";
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar appBar(
    {required String title, required BuildContext context, showBack = true}) {
  return AppBar(
    leading: showBack
        ? Transform.scale(
            scale: 0.7,
            child: IconButton(
              icon: Icon(Icons.keyboard_backspace_rounded,
                  size: 33, color: Styles.whiteColor),
              onPressed: () => Navigator.pop(context),
            ))
        : const SizedBox(),
    centerTitle: true,
    title: Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
