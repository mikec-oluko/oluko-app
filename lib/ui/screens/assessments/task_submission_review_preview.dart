import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/task_review_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/event.dart';
import 'package:oluko_app/models/submodels/video_info.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/progress_bar.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:video_player/video_player.dart';
import '../../../helpers/video_player_helper.dart';

class TaskSubmissionReviewPreview extends StatefulWidget {
  TaskSubmissionReviewPreview({this.taskSubmission, this.videoEvents, this.filePath, Key key}) : super(key: key);

  final TaskSubmission taskSubmission;
  final String filePath;
  final List<Event> videoEvents;

  @override
  _TaskSubmissionReviewPreviewState createState() => _TaskSubmissionReviewPreviewState();
}

class _TaskSubmissionReviewPreviewState extends State<TaskSubmissionReviewPreview> {
  final _formKey = GlobalKey<FormState>();

  int actualPos = 0;
  int duration = 100;

  //video
  VideoPlayerController _videoController;
  Future<void> _initializeVideoPlayerFuture;
  bool playPauseState = false;

  //video recorded
  VideoPlayerController _videoRecordedController;
  Future<void> _initializeVideoPlayerRecordedFuture;

  int index = 0;

  String _taskReviewId;

  String assessmentAssignmentId = "8dWwPNggqruMQr0OSV9f";

  //TODO: remove hardcoded reference
  CollectionReference reference = FirebaseFirestore.instance
      .collection("projects")
      .doc(GlobalConfiguration().getString('projectId'))
      .collection("assessmentAssignments")
      .doc('8dWwPNggqruMQr0OSV9f')
      .collection('taskReviews');

  @override
  void initState() {
    super.initState();
    initializeVideos();
    _videoRecordedController.addListener(listen);
  }

  @override
  void dispose() {
    _videoController.dispose();
    _videoRecordedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskReviewBloc, TaskReviewState>(
        listener: (context, state) {
          if (state is CreateSuccess) {
            setState(() {
              _taskReviewId = state.taskReviewId;
            });
            BlocProvider.of<VideoBloc>(context).createVideo(context, File(widget.filePath), 3.0 / 4.0, state.taskReviewId);
          }
        },
        child: form());
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            appBar: OlukoAppBar(title: "Record review"),
            bottomNavigationBar: BottomAppBar(
              color: OlukoColors.black,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OlukoPrimaryButton(
                      title: OlukoLocalizations.get(context, 'done'),
                      onPressed: () async {
                        _videoController.pause();
                        BlocProvider.of<TaskReviewBloc>(context).createTaskReview(reference, widget.taskSubmission, assessmentAssignmentId);
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: BlocListener<VideoBloc, VideoState>(listener: (context, state) {
              if (state is VideoSuccess) {
                VideoInfo videoInfo = VideoInfo(video: state.video, events: widget.videoEvents, markers: [], drawing: []);
                BlocProvider.of<TaskReviewBloc>(context).updateTaskReviewVideoInfo(reference.doc(_taskReviewId), videoInfo);
                Navigator.popUntil(context, ModalRoute.withName('/'));
              }
            }, child: BlocBuilder<VideoBloc, VideoState>(builder: (context, state) {
              if (state is VideoProcessing) {
                return ProgressBar(processPhase: state.processPhase, progress: state.progress);
              } else {
                return videoPlayerWidget();
              }
            }))));
  }

  Widget videoPlayerWidget() {
    return Stack(children: <Widget>[
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
                  child: FutureBuilder(
                    future: _initializeVideoPlayerRecordedFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return AspectRatio(
                          aspectRatio: _videoRecordedController.value.aspectRatio,
                          child: VideoPlayer(_videoRecordedController),
                        );
                      } else {
                        return Container(color: OlukoColors.black, child: Center(child: CircularProgressIndicator()));
                      }
                    },
                  ),
                )),
            videoControls(),
          ])),
    ]);
  }

  Widget videoControls() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Visibility(
            child: Padding(
                padding: EdgeInsets.all(2.0),
                child: Container(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: OlukoColors.black87),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          Container(
                              height: 40,
                              child: Row(children: <Widget>[
                                IconButton(
                                    color: OlukoColors.white,
                                    icon: Icon(
                                      !_videoRecordedController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                    ),
                                    onPressed: () => playPauseVideo()),
                                Expanded(
                                    child: SizedBox(
                                  child: sliderAdaptive(),
                                ))
                              ]))
                        ]))))));
  }

  Widget sliderAdaptive() {
    return Slider.adaptive(
      activeColor: OlukoColors.white,
      inactiveColor: Colors.teal.shade700,
      value: actualPos.toDouble(),
      max: duration.toDouble(),
      min: 0,
      onChanged: (val) async {
        await _videoRecordedController.seekTo(Duration(milliseconds: val.toInt()));
        setState(() {
          actualPos = val.toInt();
        });
        setCorrectVideoPosition();
      },
      /*onChangeEnd: (val) async {
      },*/
    );
  }

  playPauseVideo() async {
    if (_videoRecordedController.value.isPlaying) {
      await _videoRecordedController.pause();
      await _videoController.pause();
    } else {
      await _videoRecordedController.play();
      if (playPauseState) {
        await _videoController.play();
      }
    }
  }

  setDuration() {
    if (_videoRecordedController != null && _videoRecordedController.value.duration != null) {
      int videoDuration = _videoRecordedController.value.duration.inMilliseconds;
      setState(() {
        duration = videoDuration;
      });
    }
  }

  void initializeVideos() {
    _videoController = VideoPlayerHelper.videoPlayerControllerFromNetwork(
      widget.taskSubmission.video.url,
    );
    _initializeVideoPlayerFuture = _videoController.initialize().then((value) => _videoController.setVolume(0.0));
    _videoController.setLooping(true);

    _videoRecordedController = VideoPlayerHelper.videoPlayerControllerFromFile(File(widget.filePath));
    _initializeVideoPlayerRecordedFuture = _videoRecordedController.initialize().then((value) => setDuration());
    _videoRecordedController.setLooping(true);
  }

  void listen() async {
    if (_videoRecordedController != null) {
      int pos = _videoRecordedController.value.position.inMilliseconds;
      setActualPosition(pos);

      await checkEventToPerform(pos);

      if (_videoRecordedController.value != null && _videoRecordedController.value.duration != null && pos >= 0 && pos <= 500) {
        setState(() {
          index = 0;
        });
        _videoController.pause();
        setState(() {
          playPauseState = false;
        });
        setCorrectVideoPosition();
      }
    }
  }

  setActualPosition(int pos) {
    print("POSITION:  " + pos.toString());
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

  checkEventToPerform(int position) async {
    List<Event> events = widget.videoEvents;
    if (events.length > 0 && index < events.length) {
      int dif = position - events[index].recordingPosition;
      if (dif.abs() < 500) {
        Event event = events[index];
        print("EVENT: " + event.recordingPosition.toString());
        playOrPauseVideo(event.eventType);
        setState(() {
          index++;
        });
      }
    }
  }

  playOrPauseVideo(EventType eventType) {
    if (eventType == EventType.play) {
      _videoController.play();
    } else if (eventType == EventType.pause) {
      _videoController.pause();
    }
  }

  setCorrectVideoPosition() async {
    if (_videoController.value != null && _videoController.value.duration != null) {
      List<Event> events = widget.videoEvents;
      for (var i = 0; i < events.length; i++) {
        if (events[i].recordingPosition >= actualPos) {
          if (i > 0) {
            Event previousEvent = events[i - 1];
            calculateAndSeekToNewVideoPosition(previousEvent);
            setPlayPauseState(previousEvent);
          } else {
            await _videoController.seekTo(Duration(milliseconds: events[i].videoPosition));
          }
          setState(() {
            index = i;
          });
          if (!_videoRecordedController.value.isPlaying) {
            _videoController.pause();
          } else {
            opositePlayOrPauseVideo(events[i].eventType);
          }
          return;
        }
      }

      if (events.length > 0) {
        Event lastEvent = events[events.length - 1];
        playOrPauseVideo(lastEvent.eventType);
        calculateAndSeekToNewVideoPosition(lastEvent);
      }
    }
  }

  opositePlayOrPauseVideo(EventType eventType) {
    if (eventType == EventType.play) {
      _videoController.pause();
    } else {
      _videoController.play();
    }
  }

  calculateAndSeekToNewVideoPosition(Event event) async {
    int recordingDif = actualPos - event.recordingPosition;
    int newPos = event.videoPosition + recordingDif;
    await _videoController.seekTo(Duration(milliseconds: newPos));
  }

  setPlayPauseState(Event previousEvent) {
    if (previousEvent.eventType == EventType.play) {
      setState(() {
        playPauseState = true;
      });
    } else {
      setState(() {
        playPauseState = false;
      });
    }
  }
}
