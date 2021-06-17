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
import 'package:oluko_app/models/video_info.dart';
import 'package:video_player/video_player.dart';

typedef OnCameraCallBack = void Function();

class RecordingResponse extends StatefulWidget {
  final User user;
  final VideoInfo parentVideoInfo;
  final CollectionReference parentVideoReference;
  final OnCameraCallBack onCamera;

  const RecordingResponse(
      {Key key,
      this.user,
      @required this.parentVideoInfo,
      this.parentVideoReference,
      this.onCamera})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecordingResponseState();
}

class _RecordingResponseState extends State<RecordingResponse> {
  //video
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  List<Event> videoEvents = [];

  //camera
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool _isReady = false;
  bool _recording = false;

  //Timeline
  static const duration = const Duration(milliseconds: 1);
  int millisecondsPassed = 0;
  bool isTimerActive = false;
  Timer timer;

  @override
  void initState() {
    super.initState();
    _setupCameras();

    _controller = VideoPlayerController.network(
      widget.parentVideoInfo.video.url,
    );

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _startTimer();
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
                        future: _initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    )),
                Positioned(
                    bottom: 118,
                    right: 8,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width / 2,
                      child: (!_isReady)
                          ? Container()
                          : AspectRatio(
                              aspectRatio: cameraController.value.aspectRatio,
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
                            isTimerActive = false;
                            print("El timer midio:  " +
                                millisecondsPassed.toString());
                          });
                          File videoFile = File(videopath.path);
                          BlocProvider.of<VideoInfoBloc>(context)
                            ..processVideo(widget.user, videoFile,
                                widget.parentVideoReference, true,
                                givenAspectRatio:
                                    cameraController.value.aspectRatio,
                                events: this.videoEvents);
                          Navigator.pop(context);
                        } else {
                          await cameraController.startVideoRecording();
                          setState(() {
                            _recording = true;
                            isTimerActive = true;
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
                                this._recording
                                    ? IconButton(
                                        color: Colors.white,
                                        icon: Icon(
                                          _controller.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                        ),
                                        onPressed: () {
                                          setState(() async {
                                            if (_controller.value.isPlaying) {
                                              await _controller.pause();
                                              this.videoEvents.add(Event(
                                                  eventType: EventType.pause,
                                                  position:
                                                      this.millisecondsPassed));
                                            } else {
                                              await _controller.play();
                                              this.videoEvents.add(Event(
                                                  eventType: EventType.play,
                                                  position:
                                                      this.millisecondsPassed));
                                            }
                                          });
                                        })
                                    : Text(""),
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
        _controller,
        allowScrubbing: true,
        colors:
            VideoProgressColors(playedColor: Color.fromRGBO(255, 100, 0, 0.7)),
      );

  void _startTimer() {
    if (timer == null) {
      timer = Timer.periodic(duration, (Timer t) {
        if (isTimerActive) {
          setState(() {
            millisecondsPassed = millisecondsPassed + 1;
          });
        }
      });
    }
  }
}
