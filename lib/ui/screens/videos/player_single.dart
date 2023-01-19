import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/video_info.dart';
import 'package:video_player/video_player.dart';
import '../../../helpers/video_player_helper.dart';

typedef OnCameraCallBack = void Function();

class PlayerSingle extends StatefulWidget {
  final VideoInfo videoInfo;
  final OnCameraCallBack onCamera;

  const PlayerSingle({Key key, @required this.videoInfo, this.onCamera}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerSingleState();
}

class _PlayerSingleState extends State<PlayerSingle> {
  //video
  VideoPlayerController _videoController;
  Future<void> _initializeVideoPlayerFuture;
  bool playing = false;

  @override
  void initState() {
    _videoController = VideoPlayerHelper.videoPlayerControllerFromNetwork(
      widget.videoInfo.video.url,
    );
    _initializeVideoPlayerFuture = _videoController.initialize();
    _videoController.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OlukoColors.black,
      body: Stack(
        children: <Widget>[
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
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Colors.green),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Visibility(
                            visible: true,
                            child: Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              children: <Widget>[
                                Container(height: 25, child: buildIndicator()),
                                Container(
                                  height: 55,
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                IconButton(
                                    color: Colors.white,
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      setState(() => Navigator.pop(context));
                                    }),
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
                                IconButton(
                                    color: Colors.white,
                                    icon: Icon(Icons.camera),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      widget.onCamera();
                                    }),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
              )))
        ],
      ),
    );
  }

  Widget buildIndicator() => VideoProgressIndicator(
        _videoController,
        allowScrubbing: true,
        colors: VideoProgressColors(playedColor: Color.fromRGBO(255, 100, 0, 0.7)),
      );
}
