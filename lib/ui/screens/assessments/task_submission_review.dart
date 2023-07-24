import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/event.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/screens/assessments/task_submission_review_preview.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:video_player/video_player.dart';
import '../../../helpers/video_player_helper.dart';

class TaskSubmissionReview extends StatefulWidget {
  TaskSubmissionReview({this.taskSubmission, Key key}) : super(key: key);

  final TaskSubmission taskSubmission;

  @override
  _TaskSubmissionReviewState createState() => _TaskSubmissionReviewState();
}

class _TaskSubmissionReviewState extends State<TaskSubmissionReview> {
  final _formKey = GlobalKey<FormState>();

  //camera
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool isReady = false;
  bool _recording = false;
  bool iscamerafront = true;
  int actualPos = 0;
  int duration;

  //video
  VideoPlayerController _videoController;
  Future<void> _initializeVideoPlayerFuture;
  bool playing = false;
  List<Event> videoEvents = [];

  //stopwatch
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  int lastIndexAdded = -1;

  @override
  void initState() {
    super.initState();
    initializeVideo();
    _videoController.addListener(getActualPosition);
    _setupCameras();
  }

  void initializeVideo() {
    _videoController = VideoPlayerHelper.videoPlayerControllerFromNetwork(
      widget.taskSubmission.videoHls ?? widget.taskSubmission.video.url,
    );
    _initializeVideoPlayerFuture = _videoController.initialize();
    _videoController.setLooping(true);
  }

  void getActualPosition() {
    if (_videoController != null) {
      int pos = _videoController.value.position.inMilliseconds;
      print("POSICION:  " + pos.toString());
      if (pos >= 0 && pos <= duration) {
        setState(() {
          actualPos = pos;
        });
      } else if (pos > duration) {
        setState(() {
          actualPos = duration;
        });
      }
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    _videoController.dispose();
    _stopWatchTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return form();
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: OlukoAppBar(title: "Record review"),
            bottomNavigationBar: BottomAppBar(
              color: OlukoColors.black,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                          size: 45,
                        ),
                        onPressed: () async {
                          setState(() {
                            iscamerafront = !iscamerafront;
                          });
                          _setupCameras();
                        }),
                    GestureDetector(
                      onTap: () async {
                        if (_recording) {
                          XFile videopath = await cameraController.stopVideoRecording();
                          if (videoEvents.length > 0) {
                            addTimerLapToEvents();
                          }
                          _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                          _videoController.pause();
                          setState(() {
                            playing = false;
                          });
                          String path = videopath.path;
                          Navigator.pushNamed(context, routeLabels[RouteEnum.taskSubmissionReviewPreview],
                              arguments: {'taskSubmission': widget.taskSubmission, 'filePath': path, 'videoEvents': videoEvents});
                        } else {
                          if (playing) {
                            await _videoController.pause();
                            setState(() {
                              playing = false;
                            });
                          }
                          _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                          await cameraController.startVideoRecording();
                        }
                        setState(() {
                          _recording = !_recording;
                        });
                      },
                      child: _recording ? Image.asset('assets/self_recording/recording.png') : Image.asset('assets/self_recording/record.png'),
                    ),
                    Image.asset('assets/self_recording/gallery.png'),
                  ],
                ),
              ),
            ),
            body: Stack(children: <Widget>[
              Opacity(
                  opacity: 1,
                  child: Stack(children: [
                    Positioned(
                        top: 0,
                        right: 0,
                        left: 0,
                        bottom: 0,
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
                                return Container(color: OlukoColors.black, child: Center(child: CircularProgressIndicator()));
                              }
                            },
                          ),
                        )),
                    Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          height: MediaQuery.of(context).size.height / 4.3,
                          width: MediaQuery.of(context).size.width / 3.3,
                          child:
                              (!isReady) ? Container() : AspectRatio(aspectRatio: cameraController.value.aspectRatio, child: CameraPreview(cameraController)),
                        )),
                  ])),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Visibility(
                      child: Padding(
                          padding: EdgeInsets.all(2.0),
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
                                                await playPauseVideo();
                                                if (_recording) {
                                                  addTimerLapToEvents();
                                                }
                                              }),
                                          Expanded(
                                              child: SizedBox(
                                            child: sliderAdaptive(),
                                          ))
                                        ]))
                                  ]))))))
            ])));
  }

  Widget sliderAdaptive() {
    setDuration();
    return Slider.adaptive(
      activeColor: Colors.white,
      inactiveColor: Colors.teal.shade700,
      value: actualPos.toDouble(),
      max: duration.toDouble(),
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

  playPauseVideo() async {
    if (_videoController.value.isPlaying) {
      await _videoController.pause();
    } else {
      await _videoController.play();
    }
    setState(() {
      playing = !playing;
    });
  }

  addEvent(int recordingPos) {
    EventType eventType;
    playing ? eventType = EventType.play : eventType = EventType.pause;
    Event event = Event(eventType: eventType, videoPosition: actualPos, recordingPosition: recordingPos);
    videoEvents.add(event);
  }

  addTimerLapToEvents() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.lap);
    _stopWatchTimer.records.listen((values) {
      if (values.length > 0 && values.length - 1 > lastIndexAdded) {
        lastIndexAdded++;
        addEvent(values[values.length - 1].rawValue);
      }
    });
  }

  setDuration() {
    if (_videoController != null && _videoController.value.duration != null) {
      int videoDuration = _videoController.value.duration.inMilliseconds;
      print("DURACION:  " + videoDuration.toString());
      setState(() {
        duration = videoDuration;
      });
      return videoDuration.toDouble();
    } else {
      setState(() {
        duration = 100;
      });
      return 100.0;
    }
  }

  Future<void> _setupCameras() async {
    int cameraPos = iscamerafront ? 0 : 1;
    try {
      cameras = await availableCameras();
      cameraController = new CameraController(cameras[cameraPos], ResolutionPreset.medium);
      await cameraController.initialize();
    } on CameraException catch (_) {}
    if (!mounted) return;
    setState(() {
      isReady = true;
    });
  }
}
