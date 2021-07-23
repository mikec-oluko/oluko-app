import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/movement_submission_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/submission_state_enum.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/progress_bar.dart';
import 'package:oluko_app/utils/app_messages.dart';

class SegmentProgress extends StatefulWidget {
  SegmentProgress(
      {this.segmentSubmission,
      this.user,
      this.classIndex,
      this.segmentIndex,
      this.courseEnrollment,
      this.segment,
      Key key})
      : super(key: key);

  final SegmentSubmission segmentSubmission;
  final User user;
  final CourseEnrollment courseEnrollment;
  final Segment segment;
  final int classIndex;
  final int segmentIndex;

  @override
  _SegmentProgressState createState() => _SegmentProgressState();
}

class _SegmentProgressState extends State<SegmentProgress> {
  VideoBloc _videoBloc;
  MovementSubmissionBloc _movementSubmissionBloc;
  int current = 1;
  int total;
  List<MovementSubmission> movementSubmissions;
  String processPhase = "";
  double progress = 0.0;
  bool isThereError = false;

  @override
  void initState() {
    _videoBloc = VideoBloc();
    _movementSubmissionBloc = MovementSubmissionBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<VideoBloc>(
            create: (context) => _videoBloc,
          ),
          BlocProvider<MovementSubmissionBloc>(
            create: (context) =>
                _movementSubmissionBloc..get(widget.segmentSubmission),
          ),
        ],
        child: BlocListener<VideoBloc, VideoState>(
            listener: (context, state) {
              saveMovement(state);
            },
            child:
                BlocListener<MovementSubmissionBloc, MovementSubmissionState>(
                    listener: (context, state) {
                      if (state is GetMovementSubmissionSuccess) {
                        if (movementSubmissions == null) {
                          total = state.movementSubmissions.length;
                          movementSubmissions = state.movementSubmissions;
                          processMovementSubmission();
                        }
                      }
                    },
                    child: form())));
  }

  Widget form() {
    return Scaffold(
        //TODO: translate this
        appBar: OlukoAppBar(
          title: "Progress",
          showBackButton: false,
          actions: [_homeWidget()],
        ),
        body: Container(
            color: OlukoColors.black,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, right: 10),
                //TODO: translate this
                child: total != null
                    ? Text(
                        "Processing video ${current} out of ${total}",
                        style: OlukoFonts.olukoBigFont(
                            custoFontWeight: FontWeight.bold,
                            customColor: OlukoColors.white),
                      )
                    : SizedBox(),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 30.0, right: 10),
                  child: ProgressBar(
                      processPhase: processPhase, progress: progress)),
            ])));
  }

  processMovementSubmission() {
    MovementSubmission movementSubmission = movementSubmissions[current - 1];
    _videoBloc
      ..createVideo(context, File(movementSubmission.videoState.stateInfo),
          3.0 / 4.0, movementSubmission.id);
  }

  Widget _homeWidget() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/');
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0, top: 5),
        child: Icon(
          Icons.home,
          color: OlukoColors.appBarIcon,
          size: 25,
        ),
      ),
    );
  }

  void saveMovement(VideoState state) {
    MovementSubmission ms = movementSubmissions[current - 1];
    if (state is VideoProcessing) {
      updateProgress(state);
    } else if (state is VideoEncoded) {
      saveEncodedState(state, ms);
    } else if (state is VideoSuccess || state is VideoFailure) {
      if (state is VideoSuccess) {
        saveUploadedState(state, ms);
      } else if (state is VideoFailure) {
        saveErrorState(state, ms);
      }
      if (current < total) {
        setState(() {
          current++;
        });
        processMovementSubmission();
      } else {
        showSegmentMessage();
      }
    }
  }

  void saveEncodedState(VideoEncoded state, MovementSubmission ms) {
    setState(() {
      ms.videoState.state = SubmissionStateEnum.encoded;
      ms.videoState.stateInfo = state.encodedFilesDir;
      ms.video = state.video;
      ms.videoState.stateExtraInfo = state.thumbFilePath;
    });
    _movementSubmissionBloc..updateStateToEncoded(ms);
  }

  void saveUploadedState(VideoSuccess state, MovementSubmission ms) {
    setState(() {
      //TODO: translate this
      processPhase = "Completed";
      progress = 1.0;
      ms.video = state.video;
    });
    _movementSubmissionBloc..updateVideo(ms);
  }

  void saveErrorState(VideoFailure state, MovementSubmission ms) {
    setState(() {
      isThereError = true;
      ms.videoState.error = state.exceptionMessage;
    });
    _movementSubmissionBloc..updateStateToError(ms);
  }

  void showSegmentMessage() {
    String message;
    //TODO: translate this
    if (isThereError) {
      message = "The segment was uploaded with errors";
    } else {
      message = "The segment was uploaded successfully";
    }
    AppMessages.showSnackbar(context, message);
  }

  void updateProgress(VideoProcessing state) {
    setState(() {
      processPhase = state.processPhase;
      progress = state.progress;
    });
  }
}
