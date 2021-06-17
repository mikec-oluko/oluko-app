import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/video_info_bloc.dart';
import 'package:oluko_app/models/event.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/models/video_info.dart';
import 'package:video_player/video_player.dart';

typedef OnCameraCallBack = void Function();

class PlayerDouble extends StatefulWidget {
  final User user;
  final VideoInfo parentVideoInfo;
  final VideoInfo videoInfo;
  final DocumentReference videoReference;
  final OnCameraCallBack onCamera;

  const PlayerDouble(
      {Key key,
      this.user,
      @required this.parentVideoInfo,
      @required this.videoInfo,
      this.videoReference,
      this.onCamera})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerDoubleState();
}

class _PlayerDoubleState extends State<PlayerDouble> {
  //video
  VideoPlayerController _parentVideoController;
  Future<void> _initializeParentVideoPlayerFuture;

  VideoPlayerController _videoController;
  Future<void> _initializeVideoPlayerFuture;

  int index = 0;
  bool playing = false;

  @override
  void initState() {
    initializeVideos();
    _videoController.addListener(performEvents);
    super.initState();
  }

  void performEvents() {
    List<Event> events = widget.videoInfo.events;
    int controllerPos = _videoController.value.position.inMilliseconds;

    if (events.length > 0 &&
        index < events.length &&
        controllerPos > events[index].position) {
      EventType eventType = events[index].eventType;
      if (eventType == EventType.play) {
        print("PLAY");
        _parentVideoController.play();
        setState(() {
          playing = true;
        });
      } else if (eventType == EventType.pause) {
        print("PAUSE");
        _parentVideoController.pause();
        setState(() {
          playing = false;
        });
      }
      print('EVENT DETECTED:   ' + events[index].position.toString());
      print("POSITION:   " + controllerPos.toString());
      print('EL VALOR DE i:  ' + index.toString());
      print('--------------------------');
      setState(() {
        index++;
      });
    }

    if (controllerPos > 0 && controllerPos <= 500) {
      setState(() {
        index = 0;
      });
      _parentVideoController.seekTo(Duration(seconds: 0));
      print('REINICIA');
      print('--------------------------');
    }
  }

  @override
  void dispose() {
    _parentVideoController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                      future: _initializeParentVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return AspectRatio(
                            aspectRatio:
                                _parentVideoController.value.aspectRatio,
                            child: VideoPlayer(_parentVideoController),
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 118,
                  right: 8,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.width / 2,
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
                  ),
                ),
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
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.green),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Visibility(
                            visible: true,
                            child: Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              children: <Widget>[
                                Container(
                                  height: 25,
                                  child: buildIndicator(),
                                ),
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
                                      _videoController.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    onPressed: () async {
                                      if (_videoController.value.isPlaying) {
                                        await _videoController.pause();
                                        await _parentVideoController.pause();
                                      } else {
                                        await _videoController.play();
                                        if (playing) {
                                          await _parentVideoController.play();
                                        }
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

  initializeVideos() {
    //parentVideo
    _parentVideoController = VideoPlayerController.network(
      widget.parentVideoInfo.video.url,
    );
    _initializeParentVideoPlayerFuture = _parentVideoController.initialize();
    _parentVideoController.setLooping(true);

    //video
    _videoController = VideoPlayerController.network(
      widget.videoInfo.video.url,
    );
    _initializeVideoPlayerFuture = _videoController.initialize();
    _videoController.setLooping(true);
  }

  Widget buildIndicator() => VideoProgressIndicator(
        _videoController,
        allowScrubbing: true,
        colors:
            VideoProgressColors(playedColor: Color.fromRGBO(255, 100, 0, 0.7)),
      );
}
