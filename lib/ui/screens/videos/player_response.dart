import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/video_info_bloc.dart';
import 'package:oluko_app/models/submodels/draw_point.dart';
import 'package:oluko_app/models/submodels/video_info.dart';
import 'package:oluko_app/ui/screens/videos/aspect_ratio.dart';
import 'package:oluko_app/ui/screens/videos/loading.dart';
import 'package:oluko_app/ui/screens/videos/player_life_cycle.dart';
import 'package:video_player/video_player.dart';
import 'package:oluko_app/ui/screens/videos/draw.dart';

typedef OnCameraCallBack = void Function();

enum PlayerState { RUNNING, STOPPED, WAITING }

class PlayerResponse extends StatefulWidget {
  final DocumentReference videoReference;
  final VideoInfo parentVideoInfo;
  final VideoInfo videoInfo;
  final OnCameraCallBack onCamera;

  const PlayerResponse(
      {Key key,
      @required this.parentVideoInfo,
      this.videoInfo,
      this.videoReference,
      this.onCamera})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerResponseState();
}

class _PlayerResponseState extends State<PlayerResponse> {
  String _error;

  //Video controller variables
  VideoPlayerController videoParentController;
  VideoPlayerController videoController;
  Map<String, VideoPlayerController> contents = {};
  bool contentInitialized = false;

  //Player state variables
  bool _autoPlay = true;
  bool playing = false;
  bool ended = false;

  ///Last position of the contents. In milliseconds.
  num lastPosition = 0;

  //Drawing variables
  final canvasKey = GlobalKey<DrawState>();
  bool openCanvas = false;
  Draw canvasInstance;
  List<DrawingPoints> canvasPoints = [];
  List<DrawPoint> canvasPointsRecording = [];
  Timer playbackTimer;

  PlayerState playerState = PlayerState.STOPPED;

  //User's first video loop
  bool isFirstRecording = true;

  //Listener variables
  num listeners = 0;
  bool canvasListenerRunning = true;

  //Markers variables
  List<double> _markers = [];

  @override
  void initState() {
    super.initState();

    if (widget.videoInfo.drawing.length > 0) {
      this.canvasPointsRecording = widget.videoInfo.drawing;
      this.isFirstRecording = false;
    }
  }

  @override
  void dispose() {
    if (playbackTimer != null) {
      playbackTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          double markerPosition = getCurrentVideoPosition();
          BlocProvider.of<VideoInfoBloc>(context)
            ..addMarkerToVideoInfo(markerPosition, this.widget.videoReference);
          setState(() {
            _markers.add(markerPosition);
          });
        },
        child: const Icon(Icons.add_location_rounded),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Stack(
        children: <Widget>[
          !contentInitialized ? LoadingScreen() : Container(),
          _error == null
              ? Opacity(
                  opacity: contentInitialized ? 1 : 0,
                  child: Stack(children: [
                    Positioned(
                        top: 0,
                        right: 0,
                        left: 0,
                        bottom: 30,
                        child: Container(
                            height: MediaQuery.of(context).size.height,
                            child: NetworkPlayerLifeCycle(
                              widget.parentVideoInfo.video.url,
                              (BuildContext context,
                                  VideoPlayerController controller) {
                                this.videoParentController = controller;
                                this.contents['videoParentController'] =
                                    controller;
                                //addVideoControllerListener(controller);
                                return AspectRatioVideo(controller);
                              },
                            ))),
                    Positioned(
                        bottom: this.videoController != null &&
                                this.videoController.value.aspectRatio < 1
                            ? 110
                            : 60,
                        right: this.videoController != null &&
                                this.videoController.value.aspectRatio < 1
                            ? -100
                            : 0,
                        child: Container(
                            height: MediaQuery.of(context).size.height / 3,
                            width: MediaQuery.of(context).size.width,
                            child: NetworkPlayerLifeCycle(
                                widget.videoInfo.video.url,
                                (BuildContext context,
                                    VideoPlayerController controller) {
                              this.videoController = controller;
                              this.contents['videoController'] = controller;
                              this.videoController.value.aspectRatio;
                              this.videoParentController.value.aspectRatio;
                              addVideoControllerListener(controller);
                              return AspectRatioVideo(controller);
                            }))),
                    Opacity(opacity: 1, child: setCanvas())
                  ]))
              : Center(
                  child: Text(_error),
                ),
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
                  visible: !openCanvas,
                  child: Padding(
                    padding: openCanvas
                        ? EdgeInsets.only(
                            top: 8, left: 8, right: 8, bottom: 200.0)
                        : EdgeInsets.all(8.0),
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
                                    alignment:
                                        AlignmentDirectional.bottomCenter,
                                    children: <Widget>[
                                      Container(
                                        height: 25,
                                        child: Slider.adaptive(
                                          activeColor:
                                              Colors.lightGreen.shade200,
                                          inactiveColor: Colors.teal.shade700,
                                          value: getCurrentVideoPosition(),
                                          max: getSliderMac().toDouble(),
                                          min: 0.0,
                                          onChanged: (val) async {
                                            await Future.wait([
                                              videoParentController.seekTo(
                                                  Duration(
                                                      milliseconds:
                                                          val.toInt())),
                                              videoController.seekTo(Duration(
                                                  milliseconds: val.toInt()))
                                            ]);
                                            // await pauseContents();
                                            setState(() {});
                                          },
                                          onChangeEnd: (val) async {
                                            // await Future.wait([
                                            //   videoParentController.seekTo(Duration(
                                            //       milliseconds: val.toInt())),
                                            //   videoController.seekTo(
                                            //       Duration(milliseconds: val.toInt()))
                                            // ]);
                                            // await pauseContents();
                                            this.ended = contentsEnded();
                                            this.lastPosition = val.toInt();
                                            List<DrawPoint>
                                                pointsUntilTimeStamp =
                                                getPointsUntilTimestamp(
                                                    this
                                                        .videoParentController
                                                        .value
                                                        .position
                                                        .inMilliseconds,
                                                    this.canvasPointsRecording);
                                            List<DrawingPoints>
                                                drawingPointsUntilTimestamp =
                                                [];
                                            pointsUntilTimeStamp
                                                .forEach((element) {
                                              drawingPointsUntilTimestamp
                                                  .add(element.point);
                                            });
                                            this
                                                .canvasKey
                                                .currentState
                                                .setPoints(
                                                    drawingPointsUntilTimestamp);
                                            this._autoPlay = true;

                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Container(
                                          height: 55,
                                          child: _markersStack(
                                              widget.videoInfo.markers)),
                                    ]),
                              ),
                              Container(
                                  height: 40,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      IconButton(
                                          color: Colors.white,
                                          icon: Icon(Icons.arrow_back),
                                          onPressed: () {
                                            setState(
                                                () => Navigator.pop(context));
                                          }),
                                      IconButton(
                                          color: Colors.white,
                                          icon: Icon(this.playing
                                              ? Icons.stop
                                              : ended
                                                  ? Icons.replay
                                                  : Icons.play_arrow),
                                          onPressed: () {
                                            setState(() {
                                              playing
                                                  ? pauseContents()
                                                  : this.ended
                                                      ? resetContents()
                                                      : playContents();
                                            });
                                          }),
                                      IconButton(
                                          color: Colors.white,
                                          icon: Icon(Icons.camera),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            widget.onCamera();
                                          }),
                                      IconButton(
                                          color: Colors.white,
                                          icon: Icon(Icons.save),
                                          onPressed: () {
                                            BlocProvider.of<VideoInfoBloc>(
                                                context)
                                              ..addDrawingToVideoInfo(
                                                  this.canvasPointsRecording,
                                                  widget.videoReference);
                                            widget.videoInfo.drawing =
                                                this.canvasPointsRecording;
                                          }),
                                      // IconButton(
                                      //     icon: Icon(Icons.color_lens),
                                      //     onPressed: () {
                                      //       setState(() => openCanvas = true);
                                      //     }),
                                    ],
                                  )),
                            ],
                          ),
                        )),
                  )))
        ],
      ),
    );
  }

  Widget _markersStack(List<double> markers) {
    _markers = markers;
    List<Widget> markerWidgets = [];
    _markers.forEach((marker) {
      markerWidgets.add(buildMarkerTag(marker,
          icon: Icons.add_location_rounded, color: Colors.yellow));
    });
    return Stack(children: markerWidgets);
  }

  double getCurrentVideoPosition() {
    double position = 0;
    if (videoParentController != null &&
        videoParentController.value.position != null) {
      if (videoParentController.value.duration != null &&
          videoParentController.value.duration <
              videoParentController.value.position) {
        position =
            videoParentController.value.duration.inMilliseconds.toDouble();
      } else {
        position =
            videoParentController.value.position.inMilliseconds.toDouble();
      }
    }
    return position;
  }

  //Player state functions
  Future<void> playContents() async {
    if (!this.isFirstRecording) {
      //Plays the recorded drawings on screen
      playBackCanvas();
    }
    await Future.wait(
        [this.videoController.play(), this.videoParentController.play()]);
  }

  Future<void> pauseContents() async {
    this.contents.forEach((String key, VideoPlayerController controller) {
      controller.pause();
    });
    clearPlaybackTimer();
    this.playing = false;
    setState(() {});
  }

  Future<void> resetContents() async {
    this.ended = false;
    await Future.wait([
      this.videoParentController.seekTo(Duration(milliseconds: 0)),
      this.videoController.seekTo(Duration(milliseconds: 0))
    ]);
    this.canvasKey.currentState.setPoints([]);
    this.contentInitialized = false;
    this.lastPosition = 0;
    this._autoPlay = true;
    setState(() {});
  }

  bool contentsEnded() {
    bool allContentsEnded = true;
    this.contents.forEach((String key, VideoPlayerController controller) {
      allContentsEnded = allContentsEnded && videoControllerEnded(controller);
    });
    if (allContentsEnded) {
      this.isFirstRecording = false;
    }
    return allContentsEnded;
  }

  videoControllerEnded(videoController) {
    if (videoController == null ||
        videoController.value.position == null ||
        videoController.value.duration == null) {
      return false;
    }
    int controllerPosition =
        roundedTimestamp(videoController.value.position.inMilliseconds);
    int controllerDuration =
        roundedTimestamp(videoController.value.duration.inMilliseconds);

    bool ended = controllerPosition >= controllerDuration;
    return ended;
  }

  allContentsReady() {
    bool created = allContentsCreated();
    bool initialized = allVideosInitialized();
    bool buffered = true;
    //allVideosBuffered();
    bool stopped = !videoParentController.value.isPlaying &&
        !videoController.value.isPlaying;
    bool contentsReady = created && initialized && buffered && stopped;
    return contentsReady;
  }

  addVideoControllerListener(VideoPlayerController controller) {
    if (this.listeners >= 1) {
      return;
    }
    this.listeners++;

    Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (contentsEnded() && this.ended == false) {
        this.ended = true;
        pauseContents();
      }
      this.playing = allContentIsPlaying();

      num con1PositionMs = videoParentController.value.position.inMilliseconds;
      num con2PositionMs = videoController.value.position.inMilliseconds;
      bool isDesync = ((con1PositionMs == this.lastPosition &&
              con2PositionMs > this.lastPosition) ||
          (con1PositionMs > this.lastPosition &&
              con2PositionMs == this.lastPosition));
      if (isDesync) {
        print('<==== FIXING DESYNC ====>');
        if (playerState != PlayerState.WAITING) {
          playerState = PlayerState.WAITING;
          if (con1PositionMs > this.lastPosition) {
            videoParentController.pause();
            print('[WAITING] Pausing video 1');
          } else if (con2PositionMs > this.lastPosition) {
            videoController.pause();
            print('[WAITING] Pausing video 2');
          }
          return;
        }
      }

      if (playerState == PlayerState.WAITING &&
          this.ended == false &&
          con1PositionMs > this.lastPosition &&
          con2PositionMs > this.lastPosition) {
        print('[START] Started after buffering...');
        playerState = PlayerState.RUNNING;
        if (videoParentController.value.isPlaying &&
            videoController.value.isPlaying) {
          await Future.wait(
              [this.videoParentController.play(), this.videoController.play()]);
        } else if (!videoParentController.value.isPlaying &&
            videoController.value.isPlaying) {
          await videoParentController.play();
        } else {
          await videoController.play();
        }
        return;
      }

      if (this._autoPlay == true && allContentsReady()) {
        this._autoPlay = false;
        await this.playContents();
        playerState = PlayerState.RUNNING;
        print('[AUTOPLAY] Autoplay start');
        this.contentInitialized = true;
        setState(() {});
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  //Drawing Functions
  controllerCanvasListener() {
    if (this.videoParentController.value.position == null ||
        canvasListenerRunning == false) return;
    DrawPoint canvasObj = DrawPoint(
        point: this.canvasPoints[this.canvasPoints.length - 1],
        timeStamp: this.videoParentController.value.position.inMilliseconds);
    canvasPointsRecording.add(canvasObj);
  }

  playBackCanvas() async {
    this.canvasListenerRunning = false;

    List<DrawPoint> drawingsUntilTimeStamp = getDrawingsUntilTimestamp(
        this.videoParentController.value.position.inMilliseconds,
        List.from(this.canvasPointsRecording));
    List<DrawPoint> drawingsAfterTimeStamp = getDrawingsAfterTimestamp(
        this.videoParentController.value.position.inMilliseconds,
        List.from(this.canvasPointsRecording));

    List<DrawingPoints> pointsToSet = [];
    if (videoParentController != null &&
        videoParentController.value.position.inMilliseconds == 0) {
      pointsToSet = [];
    } else {
      pointsToSet = drawingsUntilTimeStamp.map((e) => e.point).toList();
    }

    this.canvasKey.currentState.setPoints(pointsToSet);
    List<DrawPoint> recPoints = drawingsAfterTimeStamp;

    this.playbackTimer =
        Timer.periodic(new Duration(milliseconds: 10), (timer) {
      if (recPoints.length == 0) {
        return;
      }
      bool isAheadOfTime = recPoints[0].timeStamp >
          this.videoParentController.value.position.inMilliseconds;
      if (isAheadOfTime) {
        return;
      }
      DrawPoint recPointToSend = recPoints.removeAt(0);

      this.canvasKey.currentState.addPoints(recPointToSend.point);
    });
  }

  List<DrawPoint> getPointsUntilTimestamp(
      num timeStamp, List<DrawPoint> canvasPoints) {
    for (var i = 0; i < canvasPoints.length; i++) {
      if (canvasPoints[i].timeStamp > timeStamp) {
        return canvasPoints.getRange(0, i).toList();
      }
    }
    return [];
  }

  List<DrawPoint> getDrawingsUntilTimestamp(
      num timeStamp, List<DrawPoint> canvasPoints) {
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

  List<DrawPoint> getDrawingsAfterTimestamp(
      num timeStamp, List<DrawPoint> canvasPoints) {
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

  setCanvas() {
    canvasInstance = Draw(
      key: canvasKey,
      onChanges: (DrawingPoints point) {
        if (canvasListenerRunning == true) {
          this.canvasPoints.add(point);
          controllerCanvasListener();
        }
      },
      onClose: () => setState(() => openCanvas = false),
    );
    return canvasInstance;
  }

  //Video controller check functions
  allContentIsPlaying() {
    return this.videoParentController.value.isPlaying ||
        this.videoController.value.isPlaying;
  }

  allContentsCreated() {
    return videoParentController != null && videoController != null;
  }

  allVideosInitialized() {
    return videoParentController.value.initialized &&
        videoController.value.initialized;
  }

  allVideosBuffered() {
    return this.videoParentController.value.buffered.length > 0 &&
        this.videoParentController.value.buffered.last.end >=
            Duration(milliseconds: 1) &&
        this.videoController.value.buffered.length > 0 &&
        this.videoController.value.buffered.last.end >=
            Duration(milliseconds: 1);
  }

  //Other functions
  num roundedTimestamp(num timeStamp) {
    const num division = 20;
    return (timeStamp / division).ceil();
  }

  num getSliderMac() {
    return videoParentController != null &&
            videoParentController.value.duration != null
        ? videoParentController.value.duration.inMilliseconds.toDouble()
        : 100;
  }

  Container buildMarkerTag(num markerValue,
      {IconData icon = Icons.location_on, Color color = Colors.black}) {
    return Container(
      child: Align(
          alignment: FractionalOffset(markerValue / getSliderMac(), 0),
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: IconButton(
              icon: Icon(
                icon,
                size: 30.0,
                color: color,
              ),
              iconSize: 20,
              focusColor: Colors.white,
              onPressed: () async {
                await Future.wait([
                  videoParentController
                      .seekTo(Duration(milliseconds: markerValue.round())),
                  videoController
                      .seekTo(Duration(milliseconds: markerValue.round()))
                ]);
                this.playBackCanvas();
              },
              padding: EdgeInsets.only(bottom: 0),
              alignment: Alignment.topCenter,
            ),
          )),
    );
  }
}
