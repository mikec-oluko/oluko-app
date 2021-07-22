import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/movement_submission_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/progress_bar.dart';

class SegmentProgress extends StatefulWidget {
  SegmentProgress({this.segmentSubmission, Key key}) : super(key: key);

  final SegmentSubmission segmentSubmission;

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
              if (state is VideoProcessing) {
                setState(() {
                  processPhase = state.processPhase;
                  progress = state.progress;
                });
              } else if (state is VideoEncoded) {
                _movementSubmissionBloc
                  ..updateStateToEncoded(
                      movementSubmissions[current - 1], state.encodedFilesDir);
              } else if (state is VideoSuccess) {
                setState(() {
                  //TODO: translate this
                  processPhase = "Completed";
                  progress = 1.0;
                  movementSubmissions[current - 1].video = state.video;
                });
                _movementSubmissionBloc
                  ..updateVideo(movementSubmissions[current - 1]);
                if (current < total) {
                  setState(() {
                    current++;
                  });
                  processMovementSubmission();
                }
              }
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
        appBar: OlukoAppBar(title: "Segment progress"),
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
                      processPhase: processPhase, progress: progress))
            ])));
  }

  processMovementSubmission() {
    MovementSubmission movementSubmission = movementSubmissions[current - 1];
    _videoBloc
      ..createVideo(context, File(movementSubmission.videoState.stateInfo),
          3.0 / 4.0, movementSubmission.id);
  }
}
