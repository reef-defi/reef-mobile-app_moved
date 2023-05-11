import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NFTsVideoPlayer extends StatefulWidget {
  final String url;
  final Widget child;
  NFTsVideoPlayer(this.url, this.child);

  @override
  State<NFTsVideoPlayer> createState() => _NFTsVideoPlayerState();
}

class _NFTsVideoPlayerState extends State<NFTsVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _isVideoPlaying = false;
  bool _isFirstTap = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          width: double.infinity,
          height: widget.url != '' ? 150 : null,
          child: GestureDetector(
            onTap: () {
              if (_isFirstTap) {
                setState(() {
                  _isFirstTap = false;
                });
              }
              if (_isVideoPlaying && _controller != null) {
                _controller?.pause();
                setState(() {
                  _isVideoPlaying = false;
                });
              } else {
                _controller?.play();
                setState(() {
                  _controller != null ? _isVideoPlaying = true : null;
                });
              }

              if (_controller == null) {
                _controller = VideoPlayerController.network(widget.url);
                _controller?.addListener(() {
                  setState(() {});
                });
                _controller?.setLooping(true);
                _controller?.initialize().then((_) => setState(() {
                      _isLoading = false;
                      _isVideoPlaying = true;
                      _controller?.play();
                    }));
              }
            },
            child: Container(
              child: _isLoading
                  ? Container(
                      decoration: BoxDecoration(
                          color: Styles.primaryAccentColor,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(15))),
                      child: Center(
                        child: _isFirstTap
                            ? Image.asset(
                                'assets/images/video_icon_white.png',
                                width: 30,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Styles.whiteColor,
                                  ),
                                  Gap(16),
                                  Text(
                                    "${AppLocalizations.of(context)!.approve_metadata} ...",
                                    style: TextStyle(
                                        color: Styles.whiteColor, fontSize: 12),
                                  )
                                ],
                              ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: new Radius.circular(15.0),
                      ),
                      child: AspectRatio(
                        aspectRatio: _controller?.value?.aspectRatio ?? 1,
                        child: Stack(children: [
                          VideoPlayer(_controller!),
                          if (!_isVideoPlaying)
                            Center(
                              child: Image.asset(
                                'assets/images/video_icon_white.png',
                                width: 30,
                              ),
                            ),
                          if (_isVideoPlaying)
                            Positioned(
                                bottom: 3,
                                right: 3,
                                child: Icon(
                                  Icons.pause_circle,
                                  color: Styles.whiteColor,
                                  size: 25,
                                )),
                        ]),
                      ),
                    ),
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
            ),
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
