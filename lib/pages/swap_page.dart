import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/app_bar.dart';

class SwapPage extends StatefulWidget {
  const SwapPage({Key? key}) : super(key: key);

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Text(
            "Swap Page",
            style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w700, fontSize: 24),
          ),
        ),
      ],
    );
  }
}
