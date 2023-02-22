import 'package:flutter/material.dart';
import 'package:reef_mobile_app/utils/liquid_edge/liquid_carousel.dart';

import 'content_card.dart';

class GooeyEdgeDemo extends StatefulWidget {
  const GooeyEdgeDemo({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _GooeyEdgeDemoState createState() => _GooeyEdgeDemoState();
}

class _GooeyEdgeDemoState extends State<GooeyEdgeDemo> {
  @override
  Widget build(BuildContext context) {
    //? Use a key to interact with the carousel from another widget (for triggering swipeToNext or swipeToPrevious from a button for example)
    final carouselKey = GlobalKey<LiquidCarouselState>();
    return Scaffold(
      body: LiquidCarousel(
        parentContext: context,
        key: carouselKey,
        children: <Widget>[
          ContentCard(
            liquidCarouselKey: carouselKey,
            color: Colors.black,
            title: "First View",
          ),
          ContentCard(
            liquidCarouselKey: carouselKey,
            color: Colors.blue,
            title: "Second View",
          ),
          ContentCard(
            liquidCarouselKey: carouselKey,
            color: Colors.brown,
            title: "Third View",
          ),
        ],
      ),
    );
  }
}
