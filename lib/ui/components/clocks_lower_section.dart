import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/timer_task_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/challenge_type_enum.dart';
import 'package:oluko_app/models/enums/segment_type_enum.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/enrollment_section.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/segment_summary_component.dart';
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
  final bool storyShared;
  final UserResponse currentUser;
  final Function(List<WorkoutWeight> listOfWeigthsToUpdate) movementAndWeightsForWorkout;
  final Function(bool usePersonalRecord) segmentHasPersonalRecordMovement;
  final GlobalKey<TooltipState> tooltipRemoteKey;

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
      this.segmentId,
      this.storyShared,
      this.currentUser,
      this.movementAndWeightsForWorkout,
      this.segmentHasPersonalRecordMovement,
      this.tooltipRemoteKey});

  @override
  _State createState() => _State();
}

class _State extends State<ClocksLowerSection> {
  bool shareDone = false;
  SegmentSubmission _updatedSegmentSubmission;
  bool isWorkoutUsingWeights = false;

  List<EnrollmentMovement> enrollmentMovements = [];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerTaskBloc, TimerTaskState>(builder: (context, timerTaskState) {
      if (timerTaskState is SetShareDone) {
        shareDone = widget.storyShared ? widget.storyShared : timerTaskState.shareDone;
      }
      return _lowerSection();
    });
  }

  Widget _lowerSection() {
    if (widget.workState != WorkState.finished) {
      return Container(
          color: OlukoColors.black,
          child: isSegmentWithRecording() && widget.timerTaskIndex > 0
              ? SegmentClocksUtils.cameraSection(context, isWorkStateFinished(), widget.isCameraReady, widget.cameraController, widget.pauseButton)
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
            if (isWorkoutUsingWeights)
              Padding(
                padding: EdgeInsets.only(top: ScreenUtils.smallScreen(context) ? 5 : 15),
                child: MovementUtils.movementTitle(title: OlukoLocalizations.get(context, 'weightsQuestion'), isSmallScreen: ScreenUtils.smallScreen(context)),
              )
            else
              getTitle(),
            const SizedBox(height: 5),
            if (challengeUseScores()) getScores() else getWorkouts(),
          ],
        ),
        Positioned(
          bottom: 15,
          child: Column(
            children: [
              Container(
                  width: ScreenUtils.width(context) - 40,
                  height: _showShareCard ? 185 : 150,
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      const OlukoNeumorphicDivider(
                        isFadeOut: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: getCard(),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ]),
    );
  }

  bool challengeUseScores() =>
      widget.counter ||
      ((widget.segments[widget.segmentIndex].isChallenge && widget.segments[widget.segmentIndex].typeOfChallenge == ChallengeTypeEnum.DurationDistanceReps) &&
          widget.segments[widget.segmentIndex].type == SegmentTypeEnum.Rounds);

  bool get _showShareCard => widget.originalWorkoutType != WorkoutType.segment && !shareDone;

  EnrollmentSegment getCourseEnrollmentSegment() {
    final EnrollmentSegment currentEnrollmentSegment =
        widget.courseEnrollment.classes[widget.classIndex].segments.where((enrollmentSegment) => enrollmentSegment.id == widget.segmentId).first;
    return widget
        .courseEnrollment.classes[widget.classIndex].segments[widget.courseEnrollment.classes[widget.classIndex].segments.indexOf(currentEnrollmentSegment)];
  }

  Widget getWorkouts() {
    getMovementsWithWeightRequired();
    return OlukoNeumorphism.isNeumorphismDesign
        ? Container(
            height: ScreenUtils.smallScreen(context)
                ? ScreenUtils.height(context) / 7.2
                : _showShareCard
                    ? ScreenUtils.height(context) / 5.5
                    : ScreenUtils.height(context) / 5,
            width: ScreenUtils.width(context),
            decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth),
            child: SegmentSummaryComponent(
              segmentIndex: widget.segmentIndex,
              segmentId: getCurrentSegmentId(),
              classIndex: widget.classIndex,
              isResults: true,
              useImperialSystem: widget.currentUser.useImperialSystem,
              sectionsFromSegment: getSegmentSections(),
              sectionsFromEnrollment: getEnrollmentSectionsForSegment(),
              enrollmentMovements: enrollmentMovements,
              addWeightEnable: true,
              tooltipKey: widget.tooltipRemoteKey,
              movementWeights: (movementsAndWeights) {
                widget.movementAndWeightsForWorkout(movementsAndWeights);
              },
              workoutHasWeights: (useWeights) {
                isWorkoutUsingWeights = useWeights;
              },
              segmentHasPersonalRecordMovement: (usePersonalRecord) {
                widget.segmentHasPersonalRecordMovement(usePersonalRecord ?? false);
              },
            ))
        : Column(
            children: SegmentUtils.getWorkouts(widget.segments[widget.segmentIndex]).map((e) => SegmentUtils.getTextWidget(e, OlukoColors.grayColor))?.toList(),
          );
  }

  String getCurrentSegmentId() => widget.courseEnrollment.classes[widget.classIndex].segments[widget.segmentIndex].id;

  void getMovementsWithWeightRequired() {
    enrollmentMovements = MovementUtils.getMovementsFromEnrollmentSegment(courseEnrollmentSections: getCourseEnrollmentSegment().sections);
  }

  List<SectionSubmodel> getSegmentSections() {
    return widget.segments
        .where(
          (segment) => segment.id == widget.segmentId,
        )
        .first
        .sections;
  }

  List<EnrollmentSection> getEnrollmentSectionsForSegment() {
    return widget.courseEnrollment.classes[widget.classIndex].segments.firstWhere((EnrollmentSegment segment) => segment.id == widget.segmentId).sections;
  }

  Widget getScores() {
    return SizedBox(
        height: ScreenUtils.smallScreen(context) ? ScreenUtils.height(context) / 6.4 : ScreenUtils.height(context) / 5.2,
        child: ListView(
            physics: OlukoNeumorphism.listViewPhysicsEffect,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: SegmentClocksUtils.getScoresByRound(
                context, widget.timerEntries, widget.timerTaskIndex, widget.totalScore, widget.scores, widget.areDiferentMovsWithRepCouter)));
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
                    title: widget.segments[widget.segmentIndex].isChallenge
                        ? OlukoLocalizations.get(context, 'challengeTitle') + widget.segments[widget.segmentIndex].name
                        : widget.segments[widget.segmentIndex].name,
                    isSmallScreen: ScreenUtils.smallScreen(context)),
              )),
        ],
      ),
    );
  }

  Widget getCard() {
    return widget.originalWorkoutType == WorkoutType.segment || shareDone
        ? FeedbackCard(widget.courseEnrollment, widget.classIndex, widget.segmentIndex, widget.segmentId)
        : shareCardComponent();
  }

  BlocBuilder<SegmentSubmissionBloc, SegmentSubmissionState> shareCardComponent() {
    return BlocBuilder<SegmentSubmissionBloc, SegmentSubmissionState>(
      builder: (context, state) {
        if (state is SaveSegmentSubmissionSuccess) {
          _updatedSegmentSubmission = state.segmentSubmission;
        }
        return ShareCard(
          createStory: widget.createStory,
          whistleAction: _whistleAction,
          videoRecordedThumbnail: _updatedSegmentSubmission?.video?.thumbUrl,
        );
      },
    );
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
