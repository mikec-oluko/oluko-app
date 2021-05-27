import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/ui/services/snackbar_service.dart';
import 'package:oluko_app/repositories/firestore_data.dart';
import 'package:oluko_app/models/draw_point.dart';
import 'package:video_player/video_player.dart';
import 'package:oluko_app/ui/draw.dart';

typedef OnCameraCallBack = void Function();

class PlayerSingle extends StatefulWidget {
  final Video video;
  final OnCameraCallBack onCamera;

  const PlayerSingle(
      {Key key, @required this.video, this.onCamera})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerSingleState();
}

class _PlayerSingleState extends State<PlayerSingle> {
  String _error;
  final canvasKey = GlobalKey<DrawState>();
  VideoPlayerController controller1;
  List<dynamic> contents;
  bool contentInitialized = false;
  bool openCanvas = false;
  bool _autoPlay = true;
  bool playing = false;
  bool ended = false;
  Draw canvasInstance;
  List<DrawingPoints> canvasPoints = [];
  List<DrawPoint> canvasPointsRecording = [];
  var lastCanvasTimeStamp = 0;
  var closestFrame = 0;
  bool canvasListenerRunning = true;
  Timer playbackTimer;
  //User's first video loop
  bool isFirstRecording = true;
  num listeners = 0;
  FirestoreProvider videoTrackingProvider =
      FirestoreProvider(collection: 'videoTracking');

  bool showAlertOnce = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                              widget.video.videoUrl,
                              (BuildContext context,
                                  VideoPlayerController controller) {
                                this.controller1 = controller;
                                addVideoControllerListener(controller);
                                return AspectRatioVideo(controller);
                              },
                            ))),
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
                                  alignment: AlignmentDirectional.bottomCenter,
                                  children: <Widget>[
                                    Container(
                                        height: 25,
                                        child: Slider.adaptive(
                                          activeColor:
                                              Colors.lightGreen.shade300,
                                          inactiveColor: Colors.teal.shade700,
                                          value: getCurrentVideoPosition(),
                                          max: getSliderMac().toDouble(),
                                          min: 0,
                                          onChanged: (val) async {
                                            await Future.wait([
                                              controller1.seekTo(Duration(
                                                  milliseconds: val.toInt())),
                                            ]);
                                            setState(() {});
                                          },
                                          onChangeEnd: (val) async {
                                            this.ended = contentsEnded();

                                            this._autoPlay = true;

                                            setState(() {});
                                          },
                                        )),
                                    Container(
                                      height: 55,
                                    )
                                  ],
                                ),
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
                                            : contentsEnded()
                                                ? Icons.replay
                                                : Icons.play_arrow),
                                        onPressed: () {
                                          setState(() {
                                            playing
                                                ? pauseContents()
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
                                          setState(() => saveVideoTrackData());
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

  double getCurrentVideoPosition() {
    double position = 0;
    if (controller1 != null && controller1.value.position != null) {
      if (controller1.value.duration != null &&
          controller1.value.duration < controller1.value.position) {
        position = controller1.value.duration.inMilliseconds.toDouble();
      } else {
        position = controller1.value.position.inMilliseconds.toDouble();
      }
    }
    return position;
  }

  playContents() async {
    var position = this.controller1.value.position;
    var duration = this.controller1.value.duration;

    if (position.inSeconds == duration.inSeconds) {
      resetContents();
    } else if (position.inSeconds < duration.inSeconds) {
      if (!isFirstRecording) {
        playBackCanvas();
      }
      await Future.wait([this.controller1.play()]);
    }
  }

  saveVideoTrackData() {
    videoTrackingProvider.set(id: widget.video.id, entity: {
      "videoId": widget.video.id,
      "drawPoints": jsonEncode(this.canvasPointsRecording.map((e) {
        if (e.point == null) {
          return {"x": null, "y": null, "timeStamp": e.timeStamp};
        }
        return {
          "x": e.point.points.dx,
          "y": e.point.points.dy,
          "timeStamp": e.timeStamp
        };
      }).toList()),
    });

    SnackBarService.showSnackBar(context, 'Video Saved!');
  }

  Future<Map<String, dynamic>> retrieveVideoTrackData() async {
    DocumentSnapshot document =
        await videoTrackingProvider.get(widget.video.id);
    if (!document.exists) {
      return null;
    }
    var documentData = document.data;
    return documentData;
  }

  convertTrackDataToCanvasPoints(Map<String, dynamic> trackData) {
    List<dynamic> drawPoints = trackData["drawPoints"];
    List<DrawPoint> cnvPoints = [];
    drawPoints.forEach((element) {
      DrawingPoints drawingPoint = element["x"] == null
          ? null
          : this
              .canvasKey
              .currentState
              .createDrawingPoint(Offset(element["x"], element["y"]));
      DrawPoint canvasPoint =
          DrawPoint(point: drawingPoint, timeStamp: element["timeStamp"]);
      cnvPoints.add(canvasPoint);
    });
    return cnvPoints;
  }

  resetContents() async {
    this.ended = false;
    this.contentInitialized = false;
    this._autoPlay = true;
    await Future.wait([
      this.controller1.seekTo(Duration(milliseconds: 0)),
    ]);
    this.playBackCanvas();
  }

  controllerCanvasListener() {
    if (this.controller1.value.position == null ||
        canvasListenerRunning == false) return;
    DrawPoint canvasObj = DrawPoint(
        point: this.canvasPoints[this.canvasPoints.length - 1],
        timeStamp: this.controller1.value.position.inMilliseconds);
    canvasPointsRecording.add(canvasObj);
  }

  playBackCanvas() async {
    this.canvasListenerRunning = false;

    List<DrawPoint> drawingsUntilTimeStamp = getDrawingsUntilTimestamp(
        this.controller1.value.position.inMilliseconds,
        List.from(this.canvasPointsRecording));
    List<DrawPoint> drawingsAfterTimeStamp = getDrawingsAfterTimestamp(
        this.controller1.value.position.inMilliseconds,
        List.from(this.canvasPointsRecording));

    List<DrawingPoints> pointsToSet = [];
    if (controller1 != null && controller1.value.position.inMilliseconds == 0) {
      pointsToSet = [];
    } else {
      pointsToSet = drawingsUntilTimeStamp.map((e) => e.point).toList();
    }

    this.canvasKey.currentState.setPoints(pointsToSet);
    List<DrawPoint> recPoints = drawingsAfterTimeStamp;

    this.playbackTimer =
        Timer.periodic(new Duration(milliseconds: 10), (timer) {
      List<DrawingPoints> pointsToSend = [];
      if (recPoints.length == 0) {
        return;
      }
      bool isAheadOfTime = recPoints[0].timeStamp >
          this.controller1.value.position.inMilliseconds;
      if (isAheadOfTime) {
        return;
      }
      DrawPoint recPointToSend = recPoints.removeAt(0);

      this.canvasKey.currentState.addPoints(recPointToSend.point);
    });
  }

  List<DrawPoint> getDrawingsUntilTimestamp(
      num timeStamp, List<DrawPoint> canvasPoints) {
    List<DrawingPoints> pointsUntilTimeStamp = [];
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
    List<DrawingPoints> pointsUntilTimeStamp = [];
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

  pauseContents() async {
    await this.controller1.pause();

    if (this.playbackTimer != null) {
      this.playbackTimer.cancel();
      this.playbackTimer = null;
    }
    //this.canvasKey.currentState.addPoints(null);
    setState(() {
      this.playing = false;
    });
  }

  bool contentsEnded() {
    bool endedController1 = videoControllerEnded(this.controller1);
    if (endedController1) {
      this.isFirstRecording = false;
    }
    bool ended = endedController1;
    return ended;
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

    bool ended = controllerPosition == controllerDuration;
    return ended;
  }

  num roundedTimestamp(num timeStamp) {
    const num division = 20;
    return (timeStamp / division).ceil();
  }

  addVideoControllerListener(VideoPlayerController controller) {
    this.listeners++;
    controller.addListener(() {
      if (contentsEnded() && allContentIsPlaying()) {
        pauseContents();
        this.ended = true;
      } else if (contentsEnded() && this.ended == false) {
        this.ended = true;
        this.playing = false;
      }
      if (allContentIsPlaying()) {
        this.playing = true;
      } else {
        this.playing = false;
      }
      if (allContentsReady() && this._autoPlay == true) {
        this.playContents();
        this._autoPlay = false;
        this.contentInitialized = true;
      }
      setState(() {});
    });
  }

  allContentsReady() {
    bool created = allContentsCreated();
    bool initialized = allVideosInitialized();
    bool buffered = allVideosBuffered();
    bool stopped = !controller1.value.isPlaying;

    return created && initialized && buffered && stopped && !contentInitialized;
  }

  allContentIsPlaying() {
    return this.controller1.value.isPlaying;
  }

  allContentsCreated() {
    return controller1 != null;
  }

  allVideosInitialized() {
    return controller1.value.initialized;
  }

  allVideosBuffered() {
    return !controller1.value.isBuffering;
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

  num getSliderMac() {
    return controller1 != null && controller1.value.duration != null
        ? controller1.value.duration.inMilliseconds.toDouble()
        : 100;
  }

  Container buildMarkerTag(num markerValue,
      {IconData icon = Icons.location_on, Color color = Colors.white}) {
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
              onPressed: () async {
                await Future.wait([
                  controller1
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

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 0,
        top: 0,
        left: 0,
        right: 0,
        child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                ))));
  }
}

class VideoPlayPause extends StatefulWidget {
  VideoPlayPause(this.controller);

  final VideoPlayerController controller;

  @override
  State createState() {
    return _VideoPlayPauseState();
  }
}

class _VideoPlayPauseState extends State<VideoPlayPause> {
  _VideoPlayPauseState() {
    listener = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  FadeAnimation imageFadeAnim =
      FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
  VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    //controller.addListener(listener);
    controller.setVolume(1.0);
    //controller.play();
  }

  @override
  void deactivate() {
    controller.setVolume(0.0);
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      GestureDetector(
        child: VideoPlayer(controller),
        onTap: () {
          // if (!controller.value.initialized) {
          //   return;
          // }
          // if (controller.value.isPlaying) {
          //   imageFadeAnim =
          //       FadeAnimation(child: const Icon(Icons.pause, size: 100.0));
          //   controller.pause();
          // } else {
          //   imageFadeAnim =
          //       FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
          //   controller.play();
          // }
        },
      ),
      // Align(
      //   alignment: Alignment.bottomCenter,
      //   child: VideoProgressIndicator(
      //     controller,
      //     allowScrubbing: true,
      //   ),
      // ),
      Center(child: imageFadeAnim),
      Center(
          child: controller.value.isBuffering
              ? const CircularProgressIndicator()
              : null),
    ];

    return Stack(
      fit: StackFit.passthrough,
      children: children,
    );
  }
}

class FadeAnimation extends StatefulWidget {
  FadeAnimation(
      {this.child, this.duration = const Duration(milliseconds: 500)});

  final Widget child;
  final Duration duration;

  @override
  _FadeAnimationState createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: widget.duration, vsync: this);
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();
    super.deactivate();
  }

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    if (animationController != null) animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return animationController.isAnimating
        ? Opacity(
            opacity: 1.0 - animationController.value,
            child: widget.child,
          )
        : Container();
  }
}

typedef Widget VideoWidgetBuilder(
    BuildContext context, VideoPlayerController controller);

abstract class PlayerLifeCycle extends StatefulWidget {
  PlayerLifeCycle(this.dataSource, this.childBuilder);

  final VideoWidgetBuilder childBuilder;
  final String dataSource;
}

/// A widget connecting its life cycle to a [VideoPlayerController] using
/// a data source from the network.
class NetworkPlayerLifeCycle extends PlayerLifeCycle {
  NetworkPlayerLifeCycle(String dataSource, VideoWidgetBuilder childBuilder)
      : super(dataSource, childBuilder);

  @override
  _NetworkPlayerLifeCycleState createState() => _NetworkPlayerLifeCycleState();
}

abstract class _PlayerLifeCycleState extends State<PlayerLifeCycle> {
  VideoPlayerController controller;

  @override

  /// Subclasses should implement [createVideoPlayerController], which is used
  /// by this method.
  void initState() {
    super.initState();
    controller = createVideoPlayerController();
    controller.addListener(() {
      if (controller.value.hasError) {
        setState(() {});
      }
    });
    controller.initialize();
    controller.setLooping(false);
    //controller.play();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    if (controller != null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context, controller);
  }

  VideoPlayerController createVideoPlayerController();
}

class _NetworkPlayerLifeCycleState extends _PlayerLifeCycleState {
  @override
  VideoPlayerController createVideoPlayerController() {
    return VideoPlayerController.network(widget.dataSource);
  }
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }
      if (initialized != controller.value.initialized) {
        initialized = controller.value.initialized;
        if (mounted) {
          setState(() {});
        }
      }
    };
    controller.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (controller.value.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(controller.value.errorDescription,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayPause(controller),
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
