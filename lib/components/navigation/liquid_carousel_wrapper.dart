import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LiquidCarouselWrapper extends StatefulWidget {
  const LiquidCarouselWrapper({super.key});

  @override
  State<LiquidCarouselWrapper> createState() => _LiquidCarouselWrapperState();
}

class _LiquidCarouselWrapperState extends State<LiquidCarouselWrapper> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.network('https://reef.io/videos/reef-loop.mp4');

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        //FURTHER IMPLEMENTATION
      ],
    );
  }
}
