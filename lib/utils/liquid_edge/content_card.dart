import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:reef_mobile_app/utils/liquid_edge/liquid_carousel.dart';

class ContentCard extends StatefulWidget {
  final GlobalKey<LiquidCarouselState> liquidCarouselKey;
  final Color color;
  final String title;

  const ContentCard(
      {Key? key,
      this.title = "",
      required this.liquidCarouselKey,
      required this.color})
      : super(key: key);

  @override
  _ContentCardState createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      child: Center(child: _buildBottomContent()),
    );
  }

  Widget _buildBottomContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              height: 1.2,
              fontSize: 40.0,
              color: Colors.white,
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: MaterialButton(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                color: widget.color,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Previous',
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: .8,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ),
                onPressed: () {
                  widget.liquidCarouselKey.currentState?.swipeXPrevious(x: 1);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: MaterialButton(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                color: widget.color,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Next',
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: .8,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ),
                onPressed: () {
                  widget.liquidCarouselKey.currentState?.swipeXNext(x: 1);
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
