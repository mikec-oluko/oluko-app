import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/draw_point.dart';
import 'package:oluko_app/models/submodels/event.dart';
import 'package:oluko_app/models/submodels/video_info.dart';
import 'package:video_player/video_player.dart';
import '../../../helpers/video_player_helper.dart';
import 'draw.dart';

typedef OnCameraCallBack = void Function();

class PlayerDouble extends StatefulWidget {
  final User user;
  final VideoInfo parentVideoInfo;
  final VideoInfo videoInfo;
  final DocumentReference videoReference;
  final OnCameraCallBack onCamera;

  const PlayerDouble({Key key, this.user, @required this.parentVideoInfo, @required this.videoInfo, this.videoReference, this.onCamera}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerDoubleState();
}

class _PlayerDoubleState extends State<PlayerDouble> {
  //Drawing variables
  final canvasKey = GlobalKey<DrawState>();
  bool openCanvas = false;
  Draw canvasInstance;
  List<DrawingPoints> canvasPoints = [];
  List<DrawPoint> canvasPointsRecording = [];
  Timer playbackTimer;
  bool isFirstRecording = true;
  num listeners = 0;

  //video
  VideoPlayerController _parentVideoController;
  Future<void> _initializeParentVideoPlayerFuture;

  VideoPlayerController _videoController;
  Future<void> _initializeVideoPlayerFuture;

  int index = 0;
  bool videoParentPlaying = false;
  bool videoPlaying = false;
  //int lastPosition = 0;

  @override
  void initState() {
    initializeVideos();
    _videoController.addListener(performEvents);
    super.initState();

    if (widget.videoInfo.drawing.length > 0) {
      this.canvasPointsRecording = widget.videoInfo.drawing;
      this.isFirstRecording = false;
    }
  }

  //TODO: remove this from the view when ready
  void performEvents() {
    List<Event> events = widget.videoInfo.events;
    int controllerPos = _videoController.value.position.inMilliseconds;
    print('POSICION:   ' + controllerPos.toString());
    /*bool scrub =
        controllerPos > 0 && (controllerPos - lastPosition).abs() > 700;*/

    checkEventToPerform(events, controllerPos);

    if (_parentVideoController.value != null && _parentVideoController.value.duration != null && controllerPos >= 0 && controllerPos <= 700) {
      setState(() {
        index = 0;
      });
      _parentVideoController.seekTo(Duration.zero);
      clearPlaybackTimer();
      playBackCanvas();
    }
    /*else if (scrub) {
      Event event = findLastEvent(events, controllerPos);
      if (event == null) {
        _parentVideoController.seekTo(Duration.zero);
        setState(() {
          lastPosition = 0;
        });
      } else {
        if (event.eventType == EventType.play) {
          int newPos = controllerPos - event.position;
          _parentVideoController.seekTo(Duration(milliseconds: newPos));
        }
        playOrPauseParentVideo(event.eventType);
      }
    }

    setState(() {
      lastPosition = controllerPos;
    });*/
  }

  checkEventToPerform(List<Event> events, int position) {
    if (events.length > 0 && index < events.length && position > events[index].recordingPosition) {
      EventType eventType = events[index].eventType;
      playOrPauseParentVideo(eventType);
      setState(() {
        index++;
      });
    }
  }

  /*Event findLastEvent(List<Event> events, int position) {
    for (int i = 0; i < events.length; i++) {
      if (i == events.length - 1) {
        return events[i];
      }
      if (events[i].position > position) {
        if (i - 1 >= 0) {
          return events[i - 1];
        } else {
          return null;
        }
      }
    }
    return null;
  }*/

  playOrPauseParentVideo(EventType eventType) {
    if (eventType == EventType.play) {
      _parentVideoController.play();
      setState(() {
        videoParentPlaying = true;
      });
    } else if (eventType == EventType.pause) {
      _parentVideoController.pause();
      setState(() {
        videoParentPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    _parentVideoController.dispose();
    _videoController.dispose();

    if (playbackTimer != null) {
      playbackTimer.cancel();
    }

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
                      future: _initializeParentVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return AspectRatio(
                            aspectRatio: _parentVideoController.value.aspectRatio,
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
                Opacity(opacity: 1, child: setCanvas())
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
                                      videoPlaying ? Icons.pause : Icons.play_arrow,
                                    ),
                                    onPressed: () async {
                                      if (_videoController.value.isPlaying) {
                                        await _videoController.pause();
                                        setState(() {
                                          videoPlaying = false;
                                        });
                                        await _parentVideoController.pause();
                                        clearPlaybackTimer();
                                      } else {
                                        await _videoController.play();
                                        playBackCanvas();
                                        setState(() {
                                          videoPlaying = true;
                                        });
                                        if (videoParentPlaying) {
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
    _parentVideoController = VideoPlayerHelper.videoPlayerControllerFromNetwork(
      widget.parentVideoInfo.video.url,
    );
    _initializeParentVideoPlayerFuture = _parentVideoController.initialize();
    _parentVideoController.setLooping(true);

    //video
    _videoController = VideoPlayerHelper.videoPlayerControllerFromNetwork(
      widget.videoInfo.video.url,
    );
    _initializeVideoPlayerFuture = _videoController.initialize();
    _videoController.setLooping(true);
  }

  Widget buildIndicator() => VideoProgressIndicator(
        _videoController,
        allowScrubbing: true,
        colors: VideoProgressColors(playedColor: Color.fromRGBO(255, 100, 0, 0.7)),
      );

  //DRAWING FUNCTIONS

  playBackCanvas() async {
    List<DrawPoint> drawingsUntilTimeStamp =
        getDrawingsUntilTimestamp(this._videoController.value.position.inMilliseconds, List.from(this.canvasPointsRecording));
    List<DrawPoint> drawingsAfterTimeStamp =
        getDrawingsAfterTimestamp(this._videoController.value.position.inMilliseconds, List.from(this.canvasPointsRecording));

    List<DrawingPoints> pointsToSet = [];
    if (_videoController != null && _videoController.value.position.inMilliseconds == 0) {
      pointsToSet = [];
    } else {
      pointsToSet = drawingsUntilTimeStamp.map((e) => e.point).toList();
    }

    this.canvasKey.currentState.setPoints(pointsToSet);
    List<DrawPoint> recPoints = drawingsAfterTimeStamp;

    this.playbackTimer = Timer.periodic(new Duration(milliseconds: 10), (timer) {
      if (recPoints.length == 0) {
        return;
      }
      bool isAheadOfTime = recPoints[0].miliseconds > this._videoController.value.position.inMilliseconds;
      if (isAheadOfTime) {
        return;
      }
      DrawPoint recPointToSend = recPoints.removeAt(0);

      this.canvasKey.currentState.addPoints(recPointToSend.point);
    });
  }

  List<DrawPoint> getPointsUntilTimestamp(
      //se tendria que usar en el onChangeEnd
      num miliseconds,
      List<DrawPoint> canvasPoints) {
    for (var i = 0; i < canvasPoints.length; i++) {
      if (canvasPoints[i].miliseconds > (miliseconds as int)) {
        return canvasPoints.getRange(0, i).toList();
      }
    }
    return [];
  }

  List<DrawPoint> getDrawingsUntilTimestamp(num timeStamp, List<DrawPoint> canvasPoints) {
    if (this.canvasKey.currentState.points.length == 0) {
      return [];
    }
    for (var i = 0; i < canvasPoints.length; i++) {
      if (this.canvasKey.currentState.points.last == canvasPoints[i].point) {
        return canvasPoints.getRange(0, i).toList();
      }
    }
    return canvasPoints;
  }

  List<DrawPoint> getDrawingsAfterTimestamp(num timeStamp, List<DrawPoint> canvasPoints) {
    if (this.canvasKey.currentState.points.length == 0) {
      return canvasPoints;
    }
    for (var i = 0; i < canvasPoints.length; i++) {
      if (this.canvasKey.currentState.points.last == canvasPoints[i].point) {
        return canvasPoints.getRange(i, canvasPoints.length - 1).toList();
      }
    }
    return canvasPoints;
  }

  clearPlaybackTimer() {
    if (this.playbackTimer != null) {
      this.playbackTimer.cancel();
      this.playbackTimer = null;
    }
  }

  Widget setCanvas() {
    canvasInstance = Draw(
      key: canvasKey,
      onClose: () => setState(() => openCanvas = false),
    );
    return canvasInstance;
  }
}
