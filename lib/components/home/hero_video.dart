import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _buildVideoController;
  late VideoPlayerController _loopVideoController;
  bool _isPlayingBuild = true;
  late Future<void> _initializeVideoPlayerFuture;
  late Future<void> _loopVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _buildVideoController = VideoPlayerController.asset(
      'assets/video/integrations-build-on.mp4',
    );

    _loopVideoController = VideoPlayerController.asset(
      'assets/video/integrations-loop.mp4',
    );

    _loopVideoPlayerFuture = _loopVideoController.initialize();

    _loopVideoController.setLooping(true);

    _initializeVideoPlayerFuture =
        _buildVideoController.initialize().then((value) => {
              _buildVideoController.addListener(() {
                // debugPrint(
                //     "Duration: ${_buildVideoController.value.duration} | Position: ${_buildVideoController.value.position} | Compare: ${_buildVideoController.value.duration - _buildVideoController.value.position}");
                setState(() {
                  if (!_buildVideoController.value.isPlaying &&
                      _buildVideoController.value.isInitialized &&
                      ((_buildVideoController.value.duration -
                              _buildVideoController.value.position) <
                          const Duration(milliseconds: 100))) {
                    setState(() {
                      _loopVideoController.play();
                    });
                  }
                  if (!_buildVideoController.value.isPlaying &&
                      _buildVideoController.value.isInitialized &&
                      ((_buildVideoController.value.duration ==
                          _buildVideoController.value.position))) {
                    setState(() {
                      _isPlayingBuild = false;
                    });
                  }
                });
              })
            });

    _buildVideoController.setLooping(false);

    _buildVideoController.play();
  }

  @override
  void dispose() {
    _buildVideoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          ClipOval(
            child: FutureBuilder(
                future: _loopVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                        aspectRatio: _loopVideoController.value.aspectRatio,
                        child: VideoPlayer(_loopVideoController));
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
          Opacity(
            opacity: _isPlayingBuild ? 1 : 0,
            child: ClipOval(
              child: FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                          aspectRatio: _buildVideoController.value.aspectRatio,
                          child: VideoPlayer(_buildVideoController));
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),
          ),
          FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              strokeAlign: StrokeAlign.center,
                              width: 15,
                              color: const Color(0xff2c024d))),
                      child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black12,
                              border: Border.all(
                                  strokeAlign: StrokeAlign.center,
                                  width: 10,
                                  color: const Color(0xff340451))),
                          child: AspectRatio(
                            aspectRatio:
                                _buildVideoController.value.aspectRatio,
                          )));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ],
      ),
    );
  }
}

// class VideoPlayerScreen extends StatefulWidget {
//   const VideoPlayerScreen({super.key});
//
//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }
//
// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late VideoPlayerController _controller;
//   late Future<void> _initializeVideoPlayerFuture;
//   late int _playBackTime;
//
//   //The values that are passed when changing quality
//   late Duration newCurrentPosition;
//
//   String defaultStream = 'assets/video/integrations-build-on.mp4';
//   String stream2 = 'assets/video/integrations-loop.mp4';
//
//   @override
//   void initState() {
//     _controller = VideoPlayerController.asset(defaultStream);
//     _controller.addListener(() {
//       setState(() {
//         _playBackTime = _controller.value.position.inSeconds;
//         if (_controller.value.position ==
//             Duration(seconds: 0, minutes: 0, hours: 0)) {
//           print('video Started');
//         }
//
//         if (_controller.value.position == _controller.value.duration) {
//           print('video Ended');
//           _getValuesAndPlay(stream2);
//         }
//       });
//     });
//     _initializeVideoPlayerFuture = _controller.initialize();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _controller?.pause()?.then((_) {
//       _controller.dispose();
//     });
//     super.dispose();
//   }
//
//   Future<bool> _clearPrevious() async {
//     await _controller?.pause();
//     return true;
//   }
//
//   Future<void> _initializePlay(String videoPath) async {
//     _controller = VideoPlayerController.asset(videoPath);
//     _controller.addListener(() {
//       setState(() {
//         _playBackTime = _controller.value.position.inSeconds;
//       });
//     });
//     _initializeVideoPlayerFuture = _controller.initialize().then((_) {
//       _controller.seekTo(newCurrentPosition);
//       _controller.play();
//     });
//   }
//
//   void _getValuesAndPlay(String videoPath) {
//     newCurrentPosition = _controller.value.position;
//     _startPlay(videoPath);
//     print(newCurrentPosition.toString());
//   }
//
//   Future<void> _startPlay(String videoPath) async {
//     _clearPrevious().then((_) {
//       _initializePlay(videoPath);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _initializeVideoPlayerFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return Stack(
//             children: <Widget>[
//               Center(
//                 child: AspectRatio(
//                   aspectRatio: _controller.value.aspectRatio,
//                   // Use the VideoPlayer widget to display the video.
//                   child: VideoPlayer(_controller),
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Container(
//                   color: Colors.black54,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: <Widget>[
//                       Container(
//                         child: FloatingActionButton(
//                           onPressed: () {
//                             // Wrap the play or pause in a call to `setState`. This ensures the
//                             // correct icon is shown.
//                             setState(() {
//                               // If the video is playing, pause it.
//                               if (_controller.value.isPlaying) {
//                                 _controller.pause();
//                               } else {
//                                 // If the video is paused, play it.
//                                 _controller.play();
//                               }
//                             });
//                           },
//                           // Display the correct icon depending on the state of the player.
//                           child: Icon(
//                             _controller.value.isPlaying
//                                 ? Icons.pause
//                                 : Icons.play_arrow,
//                           ),
//                         ),
//                       ),
//                       Container(
//                         child: Text(
//                           _controller.value.position
//                               .toString()
//                               .split('.')
//                               .first
//                               .padLeft(8, "0"),
//                         ),
//                       ),
//                       Container(
//                         child: TextButton(
//                           onPressed: () {
//                             _getValuesAndPlay(defaultStream);
//                           },
//                           child: Text('1'),
//                         ),
//                       ),
//                       Container(
//                         child: TextButton(
//                           onPressed: () {
//                             _getValuesAndPlay(stream2);
//                           },
//                           child: Text('2'),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         } else {
//           // If the VideoPlayerController is still initializing, show a
//           // loading spinner.
//           return Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }
