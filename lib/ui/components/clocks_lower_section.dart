import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/timer_task_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/ui/screens/courses/feedback_card.dart';
import 'package:oluko_app/ui/screens/courses/share_card.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class ClocksLowerSection extends StatefulWidget {
  final WorkState workState;
  final List<Segment> segments;
  final int segmentIndex;
  final List<TimerEntry> timerEntries;
  final int timerTaskIndex;
  final Function() createStory;
  final WorkoutType originalWorkoutType;
  final WorkoutType workoutType;
  final SegmentSubmission segmentSubmission;
  final int totalScore;
  final List<String> scores;
  final bool counter;
  final bool isCameraReady;
  final CameraController cameraController;
  final Widget pauseButton;
  final CourseEnrollment courseEnrollment;
  final int classIndex;
  final String segmentId;
  final bool areDiferentMovsWithRepCouter;

  ClocksLowerSection(
      {this.workState,
      this.areDiferentMovsWithRepCouter,
      this.segments,
      this.originalWorkoutType,
      this.segmentIndex,
      this.timerEntries,
      this.timerTaskIndex,
      this.createStory,
      this.workoutType,
      this.segmentSubmission,
      this.scores,
      this.totalScore,
      this.counter,
      this.isCameraReady,
      this.cameraController,
      this.pauseButton,
      this.courseEnrollment,
      this.classIndex,
      this.segmentId});

  @override
  _State createState() => _State();
}

class _State extends State<ClocksLowerSection> {
  bool shareDone = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimerTaskBloc, TimerTaskState>(
        listener: (context, timerTaskState) {
          if (timerTaskState is SetShareDone) {
            setState(() {
              shareDone = timerTaskState.shareDone;
            });
          }
        },
        child: _lowerSection());
  }

  Widget _lowerSection() {
    if (widget.workState != WorkState.finished) {
      return Container(
          color: Colors.black,
          child: isSegmentWithRecording() && widget.timerTaskIndex > 0
              ? SegmentClocksUtils.cameraSection(
                  context, isWorkStateFinished(), widget.isCameraReady, widget.cameraController, widget.pauseButton)
              : const SizedBox());
    } else {
      return _segmentInfoSection();
    }
  }

  ///Section with information about segment and workout movements.
  Widget _segmentInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Stack(children: [
        Column(
          crossAxisAlignment: OlukoNeumorphism.isNeumorphismDesign ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            getTitle(),
            const SizedBox(height: 5),
            if (widget.counter || widget.segments[widget.segmentIndex].isChallenge) getScores() else getWorkouts(),
          ],
        ),
        Positioned(
          bottom: 15,
          child: Container(width: ScreenUtils.width(context) - 40, height: 140, child: getCard()),
        ),
      ]),
    );
  }

  Widget getWorkouts() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
                height: ScreenUtils.smallScreen(context) ? ScreenUtils.height(context) / 7.2 : ScreenUtils.height(context) / 5.8,
                width: ScreenUtils.width(context),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: SegmentUtils.getWorkouts(widget.segments[widget.segmentIndex])
                      .map((e) => SegmentUtils.getTextWidget(e, OlukoColors.grayColor))
                      ?.toList(),
                )),
          )
        : Column(
            children: SegmentUtils.getWorkouts(widget.segments[widget.segmentIndex])
                .map((e) => SegmentUtils.getTextWidget(e, OlukoColors.grayColor))
                ?.toList(),
          );
  }

  Widget getScores() {
    return SizedBox(
        height: ScreenUtils.smallScreen(context) ? ScreenUtils.height(context) / 6.4 : ScreenUtils.height(context) / 5.2,
        child: Container(
            color: Colors.red,
            child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: SegmentClocksUtils.getScoresByRound(context, widget.timerEntries, widget.timerTaskIndex, widget.totalScore,
                    widget.scores, widget.areDiferentMovsWithRepCouter))));
  }

  Widget getTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(top: ScreenUtils.smallScreen(context) ? 5 : 15),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: MovementUtils.movementTitle(
                  widget.segments[widget.segmentIndex].isChallenge
                      ? OlukoLocalizations.get(context, 'challengeTitle') + widget.segments[widget.segmentIndex].name
                      : widget.segments[widget.segmentIndex].name,
                ),
              )),
        ],
      ),
    );
  }

  Widget getCard() {
    return widget.originalWorkoutType == WorkoutType.segment || shareDone
        ? FeedbackCard(widget.courseEnrollment, widget.classIndex, widget.segmentIndex, widget.segmentId)
        : ShareCard(createStory: widget.createStory, whistleAction: _whistleAction);
  }

  _whistleAction(bool delete) {
    BlocProvider.of<SegmentSubmissionBloc>(context).setIsDeleted(widget.segmentSubmission, delete);
  }

  bool isSegmentWithRecording() {
    return widget.workoutType == WorkoutType.segmentWithRecording;
  }

  bool isWorkStateFinished() {
    return widget.workState == WorkState.finished;
  }
}
