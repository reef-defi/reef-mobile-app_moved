import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:video_player/video_player.dart';

class NFTsVideoPlayer extends StatefulWidget {
  final String url;
  final Widget child;
  NFTsVideoPlayer(this.url, this.child);

  @override
  State<NFTsVideoPlayer> createState() => _NFTsVideoPlayerState();
}

class _NFTsVideoPlayerState extends State<NFTsVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);

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
    return Column(children: [
      Container(
          width: double.infinity,
          height: widget.url != '' ? 150 : null,
          child: Container(
  child: ClipRRect(
    borderRadius: BorderRadius.vertical(
      top: new Radius.circular(15.0),
    ),
    child: VideoPlayer(_controller),
  ),
),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
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
          child: SizedBox(
            width: double.infinity,
            height: 150,
            child: widget.child,
          ))
    ]);
  }
}
