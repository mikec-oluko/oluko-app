import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/ui/screens/videos/player_life_cycle.dart';
import 'package:oluko_app/ui/screens/videos/aspect_ratio.dart';
import 'package:oluko_app/ui/screens/videos/loading.dart';
import 'package:video_player/video_player.dart';

typedef OnCameraCallBack = void Function();

class RecordingResponse extends StatefulWidget {
  final User user;
  final Video videoParent;
  final CollectionReference parentVideoReference;
  final OnCameraCallBack onCamera;

  const RecordingResponse(
      {Key key,
      this.user,
      @required this.videoParent,
      this.parentVideoReference,
      this.onCamera})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecordingResponseState();
}

class _RecordingResponseState extends State<RecordingResponse> {
  String _error;
  VideoPlayerController controller;
  List<dynamic> contents;
  bool contentInitialized = false;
  bool _autoPlay = true;
  bool playing = false;
  bool ended = false;
  Timer playbackTimer;

  //camera
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool _isReady = false;
  bool _recording = false;

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }

  Future<void> _setupCameras() async {
    try {
      // initialize cameras.
      cameras = await availableCameras();
      // initialize camera controllers.
      cameraController =
          new CameraController(cameras[0], ResolutionPreset.medium);
      await cameraController.initialize();
    } on CameraException catch (_) {
      // do something on error.
    }
    if (!mounted) return;
    setState(() {
      _isReady = true;
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
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
                              widget.videoParent.url,
                              (BuildContext context,
                                  VideoPlayerController controller) {
                                this.controller = controller;
                                addVideoControllerListener(controller);
                                return AspectRatioVideo(controller);
                              },
                            ))),
                    Positioned(
                        bottom: 118,
                        right: 8,
                        child: Container(
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width / 2,
                          child: (!_isReady)
                              ? Container()
                              : AspectRatio(
                                  aspectRatio:
                                      cameraController.value.aspectRatio,
                                  child: CameraPreview(cameraController)),
                        )),
                    Positioned(
                      bottom: 200,
                      right: 70,
                      child: Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () async {
                            if (this._recording) {
                              XFile videopath =
                                  await cameraController.stopVideoRecording();
                              setState(() {
                                _recording = false;
                              });
                              File videoFile = File(videopath.path);
                              BlocProvider.of<VideoBloc>(context)
                                ..processVideo(widget.user, videoFile,
                                    widget.parentVideoReference, true,
                                    givenAspectRatio:
                                        cameraController.value.aspectRatio);
                              Navigator.pop(context);
                            } else {
                              await cameraController.startVideoRecording();
                              setState(() {
                                _recording = true;
                              });
                            }
                          },
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: Colors.black38,
                            child: Icon(
                              this._recording ? Icons.stop : Icons.circle,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    )
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
                                    child: Slider.adaptive(
                                      activeColor: Colors.lightGreen.shade300,
                                      inactiveColor: Colors.teal.shade700,
                                      value: getCurrentVideoPosition(),
                                      max: getSliderMac().toDouble(),
                                      min: 0,
                                      onChanged: (val) async {
                                        await Future.wait([
                                          controller.seekTo(Duration(
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
    if (controller != null && controller.value.position != null) {
      if (controller.value.duration != null &&
          controller.value.duration < controller.value.position) {
        position = controller.value.duration.inMilliseconds.toDouble();
      } else {
        position = controller.value.position.inMilliseconds.toDouble();
      }
    }
    return position;
  }

  playContents() async {
    var position = this.controller.value.position;
    var duration = this.controller.value.duration;

    if (position.inSeconds == duration.inSeconds) {
      resetContents();
    } else if (position.inSeconds < duration.inSeconds) {
      await Future.wait([this.controller.play()]);
    }
  }

  resetContents() async {
    this.ended = false;
    this.contentInitialized = false;
    this._autoPlay = true;
    await Future.wait([
      this.controller.seekTo(Duration(milliseconds: 0)),
    ]);
  }

  pauseContents() async {
    await this.controller.pause();

    if (this.playbackTimer != null) {
      this.playbackTimer.cancel();
      this.playbackTimer = null;
    }
    setState(() {
      this.playing = false;
    });
  }

  bool contentsEnded() {
    return videoControllerEnded(this.controller);
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
    bool stopped = !controller.value.isPlaying;

    return created && initialized && buffered && stopped && !contentInitialized;
  }

  allContentIsPlaying() {
    return this.controller.value.isPlaying;
  }

  allContentsCreated() {
    return controller != null;
  }

  allVideosInitialized() {
    return controller.value.initialized;
  }

  allVideosBuffered() {
    return !controller.value.isBuffering;
  }

  num getSliderMac() {
    return controller != null && controller.value.duration != null
        ? controller.value.duration.inMilliseconds.toDouble()
        : 100;
  }
}
