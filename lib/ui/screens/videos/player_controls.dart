import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/models/submodels/video_info.dart';
import 'package:video_player/video_player.dart';
import '../../../helpers/video_player_helper.dart';

typedef OnCameraCallBack = void Function();

class PlayerControls extends StatefulWidget {
  final VideoInfo videoInfo;
  final OnCameraCallBack onCamera;

  const PlayerControls({Key key, @required this.videoInfo, this.onCamera}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  //video
  VideoPlayerController _videoController;
  Future<void> _initializeVideoPlayerFuture;
  bool playing = false;
  int actualPos = 0;

  @override
  void initState() {
    initializeVideo();
    _videoController.addListener(getActualPosition);
    super.initState();
  }

  void initializeVideo() {
    _videoController = VideoPlayerHelper.VideoPlayerControllerFromNetwork(
      widget.videoInfo.video.url,
    );
    _initializeVideoPlayerFuture = _videoController.initialize();
    _videoController.setLooping(true);
  }

  void getActualPosition() {
    setState(() {
      actualPos = _videoController.value.position.inMilliseconds;
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: <Widget>[
          Opacity(
              opacity: 1,
              child: Stack(children: [
                Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    bottom: 30,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: FutureBuilder(
                        future: _initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return AspectRatio(
                              aspectRatio: _videoController.value.aspectRatio,
                              child: VideoPlayer(_videoController),
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    )),
              ])),
          Container(
            padding: EdgeInsets.all(16.0),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Visibility(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Colors.black87),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                                Container(
                                    height: 40,
                                    child: Row(children: <Widget>[
                                      IconButton(
                                          color: Colors.white,
                                          icon: Icon(
                                            playing ? Icons.pause : Icons.play_arrow,
                                          ),
                                          onPressed: () async {
                                            if (_videoController.value.isPlaying) {
                                              await _videoController.pause();
                                              setState(() {
                                                playing = false;
                                              });
                                            } else {
                                              await _videoController.play();
                                              setState(() {
                                                playing = true;
                                              });
                                            }
                                          }),
                                      Expanded(
                                          child: SizedBox(
                                        child: sliderAdaptive(),
                                      ))
                                    ]))
                              ]))))))
        ]));
  }

  Widget sliderAdaptive() {
    return Slider.adaptive(
      activeColor: Colors.white,
      inactiveColor: Colors.teal.shade700,
      value: actualPos.toDouble(),
      max: getMaxValue().toDouble(),
      min: 0,
      onChanged: (val) async {
        await _videoController.seekTo(Duration(milliseconds: val.toInt()));
        setState(() {
          actualPos = val.toInt();
        });
      },
      /*onChangeEnd: (val) async {
      },*/
    );
  }

  num getMaxValue() {
    return _videoController != null && _videoController.value.duration != null
        ? _videoController.value.duration.inMilliseconds.toDouble()
        : 100;
  }
}
