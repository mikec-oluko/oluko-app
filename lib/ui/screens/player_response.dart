import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/marker_bloc.dart';
import 'package:oluko_app/models/video_tracking.dart';
import 'package:oluko_app/repositories/video_tracking_repository.dart';
import 'package:oluko_app/ui/services/snackbar_service.dart';
import 'package:oluko_app/models/marker.dart';
import 'package:oluko_app/models/draw_point.dart';
import 'package:video_player/video_player.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/ui/draw.dart';

typedef OnCameraCallBack = void Function();

enum PlayerState { RUNNING, STOPPED, WAITING }

class PlayerResponse extends StatefulWidget {
  final String videoParentPath;
  final Video videoParent;
  final Video video;
  final OnCameraCallBack onCamera;

  const PlayerResponse(
      {Key key,
      @required this.videoParent,
      this.video,
      this.videoParentPath,
      this.onCamera})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerResponseState();
}

class _PlayerResponseState extends State<PlayerResponse> {
  String _error;

  //Video controller variables
  VideoPlayerController controller1;
  VideoPlayerController controller2;
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
  var lastCanvasTimeStamp = 0;
  var closestFrame = 0;
  Timer playbackTimer;

  PlayerState playerState = PlayerState.STOPPED;

  //User's first video loop
  bool isFirstRecording = true;
  bool isFirstPlay = true;

  //Listener variables
  num listeners = 0;
  bool canvasListenerRunning = true;

  //Markers variables
  double markerPosition = 0.0;
  List<Marker> _markers = [];

  @override
  void initState() {
    retrieveVideoTrackData();
    super.initState();
  }

  @override
  void dispose() {
    if (playbackTimer != null) {
      playbackTimer.cancel();
    }
    if (controller1 != null) {
      //controller1.dispose();
    }
    if (controller2 != null) {
      //controller2.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MarkerBloc()
          ..getVideoMarkers(this.widget.video.id, this.widget.videoParentPath),
        child: Scaffold(
          backgroundColor: Colors.black,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              markerPosition = getCurrentVideoPosition();
              MarkerBloc()
                ..createMarker(markerPosition, this.widget.video.id,
                    this.widget.videoParentPath);
              _markers.add(Marker(position: markerPosition));
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
                                  widget.video.url,
                                  (BuildContext context,
                                      VideoPlayerController controller) {
                                    this.controller1 = controller;
                                    this.contents['controller1'] = controller;
                                    //addVideoControllerListener(controller);
                                    return AspectRatioVideo(controller);
                                  },
                                ))),
                        Positioned(
                            bottom: this.controller2 != null &&
                                    this.controller2.value.aspectRatio < 1
                                ? 110
                                : 60,
                            right: this.controller2 != null &&
                                    this.controller2.value.aspectRatio < 1
                                ? -100
                                : 0,
                            child: Container(
                                height: MediaQuery.of(context).size.height / 3,
                                width: MediaQuery.of(context).size.width,
                                child: NetworkPlayerLifeCycle(widget.video.url,
                                    (BuildContext context,
                                        VideoPlayerController controller) {
                                  this.controller2 = controller;
                                  this.contents['controller2'] = controller;
                                  this.controller2.value.aspectRatio;
                                  this.controller1.value.aspectRatio;
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
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
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
                                              inactiveColor:
                                                  Colors.teal.shade700,
                                              value: getCurrentVideoPosition(),
                                              max: getSliderMac().toDouble(),
                                              min: 0.0,
                                              onChanged: (val) async {
                                                await Future.wait([
                                                  controller1.seekTo(Duration(
                                                      milliseconds:
                                                          val.toInt())),
                                                  controller2.seekTo(Duration(
                                                      milliseconds:
                                                          val.toInt()))
                                                ]);
                                                // await pauseContents();
                                                setState(() {});
                                              },
                                              onChangeEnd: (val) async {
                                                // await Future.wait([
                                                //   controller1.seekTo(Duration(
                                                //       milliseconds: val.toInt())),
                                                //   controller2.seekTo(
                                                //       Duration(milliseconds: val.toInt()))
                                                // ]);
                                                // await pauseContents();
                                                this.ended = contentsEnded();
                                                this.lastPosition = val.toInt();
                                                List<DrawPoint>
                                                    pointsUntilTimeStamp =
                                                    getPointsUntilTimestamp(
                                                        this
                                                            .controller1
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
                                              child: BlocBuilder<MarkerBloc,
                                                      MarkerState>(
                                                  builder: (context, state) {
                                                if (state is MarkersSuccess) {
                                                  return _markersStack(
                                                      state.markers);
                                                } else {
                                                  return Text(
                                                    'LOADING...',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  );
                                                }
                                              })),
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
                                                setState(() =>
                                                    Navigator.pop(context));
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
                                                setState(
                                                    () => saveVideoTrackData());
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
        ));
  }

  Widget _markersStack(List<Marker> markers) {
    _markers = markers;
    List<Widget> markerWidgets = [];
    _markers.forEach((marker) {
      markerWidgets.add(buildMarkerTag(marker.position,
          icon: Icons.add_location_rounded, color: Colors.yellow));
    });
    return Stack(children: markerWidgets);
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

  ///Retrieves CanvasPoints from a VideoTrackerProvider to current video
  retrieveVideoTrackData() async {
    VideoTracking videoTracking =
        await VideoTrackingRepository.getVideoTracking(
            widget.video.id, widget.videoParentPath);
    if (videoTracking != null && videoTracking.drawPoints != null) {
      this.canvasPointsRecording = videoTracking.drawPoints;
      this.isFirstRecording = false;
    }
  }

  //Storage Functions
  ///Saves CanvasPoints from current video to a VideoTrackerProvider
  saveVideoTrackData() {
    VideoTrackingRepository.createVideoTracking(
        widget.video.id, this.canvasPointsRecording, widget.videoParentPath);
    SnackBarService.showSnackBar(context, 'Record saved!'); //SE MUESTRA MAL
  }

  //Player state functions
  Future<void> playContents() async {
    if (!this.isFirstRecording) {
      //Plays the recorded drawings on screen
      playBackCanvas();
    }
    await Future.wait([this.controller2.play(), this.controller1.play()]);
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
      this.controller1.seekTo(Duration(milliseconds: 0)),
      this.controller2.seekTo(Duration(milliseconds: 0))
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
    bool stopped = !controller1.value.isPlaying && !controller2.value.isPlaying;
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

      num con1PositionMs = controller1.value.position.inMilliseconds;
      num con2PositionMs = controller2.value.position.inMilliseconds;
      bool isDesync = ((con1PositionMs == this.lastPosition &&
              con2PositionMs > this.lastPosition) ||
          (con1PositionMs > this.lastPosition &&
              con2PositionMs == this.lastPosition));
      if (isDesync) {
        print('<==== FIXING DESYNC ====>');
        if (playerState != PlayerState.WAITING) {
          playerState = PlayerState.WAITING;
          if (con1PositionMs > this.lastPosition) {
            controller1.pause();
            print('[WAITING] Pausing video 1');
          } else if (con2PositionMs > this.lastPosition) {
            controller2.pause();
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
        if (controller1.value.isPlaying && controller2.value.isPlaying) {
          await Future.wait([this.controller1.play(), this.controller2.play()]);
        } else if (!controller1.value.isPlaying &&
            controller2.value.isPlaying) {
          await controller1.play();
        } else {
          await controller2.play();
        }
        return;
      }

      if (this._autoPlay == true && allContentsReady()) {
        this.isFirstPlay = false;
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
    return this.controller1.value.isPlaying || this.controller2.value.isPlaying;
  }

  allContentsCreated() {
    return controller1 != null && controller2 != null;
  }

  allVideosInitialized() {
    return controller1.value.initialized && controller2.value.initialized;
  }

  allVideosBuffered() {
    return this.controller1.value.buffered.length > 0 &&
        this.controller1.value.buffered.last.end >= Duration(milliseconds: 1) &&
        this.controller2.value.buffered.length > 0 &&
        this.controller2.value.buffered.last.end >= Duration(milliseconds: 1);
  }

  //Other functions
  num roundedTimestamp(num timeStamp) {
    const num division = 20;
    return (timeStamp / division).ceil();
  }

  num getSliderMac() {
    return controller1 != null && controller1.value.duration != null
        ? controller1.value.duration.inMilliseconds.toDouble()
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
                  controller1
                      .seekTo(Duration(milliseconds: markerValue.round())),
                  controller2
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
      /*Align(
        alignment: Alignment.bottomCenter,
        child: VideoProgressIndicator(
          controller,
          allowScrubbing: true,
        ),
      ),*/
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
