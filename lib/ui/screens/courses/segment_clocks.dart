import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_update_bloc.dart';
import 'package:oluko_app/blocs/keyboard/keyboard_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart' as storyBloc;
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';
import 'package:oluko_app/models/enums/submission_state_enum.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/custom_keyboard.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/progress_bar.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/screens/courses/collapsed_movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/feedback_card.dart';
import 'package:oluko_app/ui/screens/courses/movement_videos_section.dart';
import 'package:oluko_app/ui/screens/courses/share_card.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:oluko_app/utils/timer_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock/wakelock.dart';

enum WorkoutType { segment, segmentWithRecording }

class SegmentClocks extends StatefulWidget {
  final WorkoutType workoutType;
  final CourseEnrollment courseEnrollment;
  final int classIndex;
  final int segmentIndex;
  final List<Segment> segments;
  final int courseIndex;

  SegmentClocks({Key key, this.courseIndex, this.workoutType, this.classIndex, this.segmentIndex, this.courseEnrollment, this.segments})
      : super(key: key);

  @override
  _SegmentClocksState createState() => _SegmentClocksState();
}

class _SegmentClocksState extends State<SegmentClocks> {
  //Imported from Timer POC Models
  WorkState workState;
  WorkState lastWorkStateBeforePause;

  //Current task running on Countdown Timer
  int timerTaskIndex = 0;
  Duration timeLeft;
  Timer countdownTimer;

  final toolbarHeight = kToolbarHeight * 2;

  //Flex proportions to display sections vertically in body.
  List<num> flexProportions(WorkoutType workoutType) => isSegmentWithRecording() ? [3, 7] : [8, 2];

  //Camera
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool _isReady = false;
  bool isCameraFront = false;
  List<TimerEntry> timerEntries;

  User _user;
  SegmentSubmission _segmentSubmission;
  List<Movement> _movements = [];
  bool isPlaying = true;
  PanelController panelController = PanelController();
  TextEditingController textController = TextEditingController();
  int AMRAPRound = 0;
  Widget topBarIcon;
  String processPhase = '';
  double progress = 0.0;
  bool isThereError = false;
  bool shareDone = false;

  WorkoutType workoutType;

  List<String> scores = [];
  int totalScore = 0;
  bool counter = false;
  bool _wantsToCreateStory = false;
  bool _isVideoUploaded = false;
  bool waitingForSegSubCreation = false;

  CoachRequest _coachRequest;

  XFile videoRecorded;

  @override
  void initState() {
    Wakelock.enable();
    workoutType = widget.workoutType;
    if (isSegmentWithRecording()) {
      _setupCameras();
    }
    _startMovement();
    topBarIcon = const SizedBox();
    if (widget.segments[widget.segmentIndex].rounds != null) {
      scores = List<String>.filled(widget.segments[widget.segmentIndex].rounds, '-');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return onWillPop(context, isSegmentWithRecording());
      },
      child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
        if (authState is AuthSuccess) {
          _user = authState.firebaseUser;
          return BlocBuilder<MovementBloc, MovementState>(builder: (context, movementState) {
            return BlocBuilder<CoachRequestBloc, CoachRequestState>(builder: (context, coachRequestState) {
              if (movementState is GetAllSuccess && coachRequestState is ClassCoachRequestsSuccess) {
                _movements = movementState.movements;
                _coachRequest = getSegmentCoachRequest(coachRequestState.coachRequests, widget.segments[widget.segmentIndex].id);
                return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: BlocListener<VideoBloc, VideoState>(
                        listener: (context, state) {
                          updateSegment(state);
                        },
                        child: BlocListener<SegmentSubmissionBloc, SegmentSubmissionState>(
                            listener: (context, state) {
                              if (state is CreateSuccess) {
                                if (_segmentSubmission == null) {
                                  _segmentSubmission = state.segmentSubmission;
                                  BlocProvider.of<VideoBloc>(context)
                                    ..createVideo(context, File(_segmentSubmission.videoState.stateInfo), 3.0 / 4.0, _segmentSubmission.id);
                                }
                              } else if (state is UpdateSegmentSubmissionSuccess) {
                                waitingForSegSubCreation = false;
                                BlocProvider.of<CoachRequestBloc>(context)..resolve(_coachRequest, _user.uid);
                                if (_wantsToCreateStory) {
                                  callBlocToCreateStory(context, state.segmentSubmission);
                                } else {
                                  _isVideoUploaded = true;
                                  _segmentSubmission = state?.segmentSubmission;
                                }
                              }
                            },
                            child: form())));
              } else {
                return const SizedBox();
              }
            });
          });
        } else {
          return const SizedBox();
        }
      }),
    );
  }

  CoachRequest getSegmentCoachRequest(List<CoachRequest> coachRequests, String segmentId) {
    for (var i = 0; i < coachRequests.length; i++) {
      if (coachRequests[i].segmentId == segmentId) {
        return coachRequests[i];
      }
    }
    return null;
  }

  Future<void> callBlocToCreateStory(BuildContext context, SegmentSubmission segmentSubmission) async {
    BlocProvider.of<storyBloc.StoryBloc>(context).createStory(segmentSubmission);
    AppMessages.clearAndShowSnackbarTranslated(context, 'storyCreated');
  }

  bool isSegmentWithRecording() {
    return workoutType == WorkoutType.segmentWithRecording;
  }

  Widget form() {
    bool keyboardVisibilty=false;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: OlukoAppBar(
        showDivider: false,
        title: ' ',
        showBackButton: false,
        actions: [topBarIcon, audioIcon()],
      ),
      backgroundColor: Colors.black,
      body: isSegmentWithoutRecording() && workState != WorkState.finished
          ? BlocBuilder<KeyboardBloc, KeyboardState>(
              builder: (context, state) {
                keyboardVisibilty = state.setVisible;
                return SlidingUpPanel(
                    controller: panelController,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    minHeight: () {
                      if (!keyboardVisibilty) return 90.0;
                      return 0.0;
                    }(),
                    maxHeight: () {
                      if (!keyboardVisibilty) return 185.0;
                      return 0.0;
                    }(),
                    collapsed: Visibility(visible: !keyboardVisibilty, child: CollapsedMovementVideosSection(action: getAction())),
                    panel: Visibility(
                      visible: !keyboardVisibilty,
                      child: MovementVideosSection(
                          action: getAction(),
                          segment: widget.segments[widget.segmentIndex],
                          movements: _movements,
                          onPressedMovement: (BuildContext context, Movement movement) =>
                              Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement})),
                    ),
                    body: _body(keyboardVisibilty));
              },
            )
          : _body(keyboardVisibilty),
    );
  }

  bool isSegmentWithoutRecording() {
    return workoutType == WorkoutType.segment;
  }

  Widget getAction() {
    return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: OutlinedButton(
          onPressed: () {
            final bool isCurrentTaskTimed = timerEntries[timerTaskIndex].parameter == ParameterEnum.duration;
            setState(() {
              if (isPlaying) {
                panelController.open();
                if (isCurrentTaskTimed) {
                  _pauseCountdown();
                } else {
                  setPaused();
                }
              } else {
                panelController.close();
                workState = lastWorkStateBeforePause;
                if (isCurrentTaskTimed) {
                  _playCountdown();
                }
              }
              isPlaying = !isPlaying;
            });
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            shape: const CircleBorder(),
            side: const BorderSide(color: Colors.white),
          ),
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
        ));
  }

  Widget _body(bool keyboardVisibilty) {
    final _controller = ScrollController();
        if (!keyboardVisibilty) {
          return ListView(
            controller: _controller,
            children: [
              _timerSection(keyboardVisibilty),
              _lowerSection(),
              if (isWorkStateFinished()) showFinishedButtons() else const SizedBox(),
            ],
          );
        }
        Timer(
          Duration(milliseconds: 5),
          () => _controller.animateTo(
            _controller.position.maxScrollExtent,
            duration: Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
          ),
        );
        return ListView(
          controller: _controller,
          children: [
            _timerSection(keyboardVisibilty),
            _lowerSection(),
            if (isWorkStateFinished()) showFinishedButtons() else const SizedBox(),
          ],
        );
      
    ;
  }

  Widget showFinishedButtons() {
    if (widget.workoutType == WorkoutType.segmentWithRecording && !shareDone) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OlukoPrimaryButton(
              title: OlukoLocalizations.get(context, 'done'),
              thinPadding: true,
              onPressed: () {
                setState(() {
                  shareDone = true;
                });
              },
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OlukoOutlinedButton(
                title: OlukoLocalizations.get(context, 'goToClass'),
                thinPadding: true,
                onPressed: () {
                  if (!waitingForSegSubCreation) {
                    goToClassAction();
                  } else {
                    DialogUtils.getDialog(context, stopProcessConfirmationContent(goToClassAction), showExitButton: false);
                  }
                }),
            const SizedBox(
              width: 15,
            ),
            OlukoPrimaryButton(
              title: widget.segmentIndex == widget.segments.length - 1
                  ? OlukoLocalizations.get(context, 'done')
                  : OlukoLocalizations.get(context, 'nextSegment'),
              thinPadding: true,
              onPressed: () {
                if (!waitingForSegSubCreation) {
                  nextSegmentAction();
                } else {
                  DialogUtils.getDialog(context, stopProcessConfirmationContent(nextSegmentAction), showExitButton: false);
                }
              },
            ),
          ],
        ),
      );
    }
  }

  void nextSegmentAction() {
    widget.segmentIndex < widget.segments.length - 1
        ? Navigator.popAndPushNamed(context, routeLabels[RouteEnum.segmentDetail], arguments: {
            'segmentIndex': widget.segmentIndex + 1,
            'classIndex': widget.classIndex,
            'courseEnrollment': widget.courseEnrollment,
            'courseIndex': widget.courseIndex,
            'fromChallenge': false
          })
        : Navigator.popAndPushNamed(context, routeLabels[RouteEnum.completedClass], arguments: {
            'classIndex': widget.classIndex,
            'courseEnrollment': widget.courseEnrollment,
            'courseIndex': widget.courseIndex,
          });
  }

  void goToClassAction() {
    Navigator.popUntil(context, ModalRoute.withName('/inside-class'));
    Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.insideClass],
        arguments: {'courseEnrollment': widget.courseEnrollment, 'classIndex': widget.classIndex, 'courseIndex': widget.courseIndex});
  }

  ///Countdown & movements information
  Widget _timerSection(bool keyboardVisibilty) {
    return Center(
        child: Column(
      children: [
        getSegmentLabel(),
        Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 8),
            child: Stack(alignment: Alignment.center, children: [getRoundsTimer(keyboardVisibilty), _countdownSection()])),
        if (isWorkStateFinished()) const SizedBox() else _tasksSection(keyboardVisibilty)
      ],
    ));
  }

  bool isWorkStateFinished() {
    return workState == WorkState.finished;
  }

  bool isWorkStatePaused() {
    return workState == WorkState.paused;
  }

  Widget getSegmentLabel() {
    if (isWorkStateFinished()) {
      return const SizedBox();
    }

    if (SegmentUtils.isEMOM(widget.segments[widget.segmentIndex])) {
      return TimerUtils.getRoundLabel(timerEntries[timerTaskIndex].round);
    } else if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
      return TimerUtils.getRoundLabel(AMRAPRound);
    } else {
      return const SizedBox();
    }
  }

  Widget getRoundsTimer(bool keyboardVisibilty) {
    if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) && isWorkStateFinished()) {
      return TimerUtils.roundsTimer(AMRAPRound, AMRAPRound,keyboardVisibilty);
    } else if (isWorkStateFinished()) {
      return TimerUtils.roundsTimer(widget.segments[widget.segmentIndex].rounds, widget.segments[widget.segmentIndex].rounds,keyboardVisibilty);
    } else if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
      return TimerUtils.roundsTimer(AMRAPRound, AMRAPRound,keyboardVisibilty);
    } else {
      return TimerUtils.roundsTimer(widget.segments[widget.segmentIndex].rounds, timerEntries[timerTaskIndex].round,keyboardVisibilty);
    }
  }

  ///Current and next movement labels
  Widget _tasksSection(bool keyboardVisibilty) {
    return isSegmentWithoutRecording()
        ? taskSectionWithoutRecording(keyboardVisibilty)
        : Column(children: [SizedBox(height: 10), recordingTaskSection(keyboardVisibilty), ...counterTextField(keyboardVisibilty), SizedBox(height: 20)]);
  }

  Widget taskSectionWithoutRecording(bool keyboardVisibilty) {
    final bool hasMultipleLabels = timerEntries[timerTaskIndex].labels.length > 1;
    if (hasMultipleLabels) {
      return Column(children: SegmentUtils.getJoinedLabel(timerEntries[timerTaskIndex].labels));
    } else {
      final String currentTask = timerEntries[timerTaskIndex].labels[0];
      final String nextTask = timerTaskIndex < timerEntries.length - 1 ? timerEntries[timerTaskIndex + 1].labels[0] : '';
      return Column(
        children: [
          currentTaskWidget(keyboardVisibilty,currentTask),
          const SizedBox(height: 10),
          nextTaskWidget(nextTask,keyboardVisibilty),
          const SizedBox(height: 15),
          ...counterTextField(keyboardVisibilty),
        ],
      );
    }
  }

  List<Widget> counterTextField(bool keyboardVisibilty) {
    if (isCurrentMovementRest() &&
        (timerEntries[timerTaskIndex - 1].counter == CounterEnum.reps ||
            timerEntries[timerTaskIndex - 1].counter == CounterEnum.distance)) {
      return [getTextField(keyboardVisibilty), getKeyboard(keyboardVisibilty)];
    } else {
      return [const SizedBox()];
    }
  }

  Widget getTextField(bool keyboardVisibilty) {
    final bool isCounterByReps = timerEntries[timerTaskIndex - 1].counter == CounterEnum.reps;
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/courses/gray_background.png'),
          fit: BoxFit.cover,
        )),
        height: 50,
        child: Column(
          children: [
            Row(children: [
              const SizedBox(width: 20),
              Text(OlukoLocalizations.get(context, 'enterScore'),
                  style: TextStyle(fontSize: 18, color: OlukoColors.white, fontWeight: FontWeight.w300)),
              const SizedBox(width: 10),
              SizedBox(
                  width: isCounterByReps ? 40 : 70,
                  child: BlocBuilder<KeyboardBloc, KeyboardState>(
                    builder: (context, state) {
                      return Scrollbar(
                        child: () {
                          final _customKeyboardBloc = BlocProvider.of<KeyboardBloc>(context);
                          final ScrollController _scrollController = ScrollController();
                          TextSelection textSelection = state.textEditingController.selection;
                          textSelection = state.textEditingController.selection.copyWith(
                            baseOffset: state.textEditingController.text.length,
                            extentOffset: state.textEditingController.text.length,
                          );
                          textController = state.textEditingController;
                          textController.selection = textSelection;
                          return TextField(
                            scrollController: _scrollController,
                            controller: textController,
                            onTap: () => !state.setVisible ? _customKeyboardBloc.add(SetVisible()) : null,
                            style: const TextStyle(fontSize: 20, color: OlukoColors.white, fontWeight: FontWeight.bold),
                            focusNode: state.focus,
                            readOnly: true,
                            showCursor: true,
                            decoration: const InputDecoration(border: InputBorder.none),
                            maxLines: 1,
                          );
                        }(),
                      );
                    },
                  )),
              const SizedBox(width: 10),
              if (isCounterByReps)
                Text(timerEntries[timerTaskIndex - 1].movement.name,
                    style: TextStyle(fontSize: 18, color: OlukoColors.white, fontWeight: FontWeight.w300))
              else
                Text(OlukoLocalizations.get(context, 'meters'),
                    style: TextStyle(fontSize: 18, color: OlukoColors.white, fontWeight: FontWeight.w300)),
            ]),
          ],
        ));
  }

  Widget getKeyboard(bool keyboardVisibilty) {
    const boxDecoration = BoxDecoration(
      gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xff2b2f35), Color(0xff16171b)],
    ));
    return Visibility(
        visible: keyboardVisibilty,
        child: CustomKeyboard(
          boxDecoration: boxDecoration,
        ));
    ;
  }

  Widget recordingTaskSection(bool keyboardVisibilty) {
    final bool hasMultipleLabels = timerEntries[timerTaskIndex].labels.length > 1;
    if (hasMultipleLabels) {
      final List<Widget> items = SegmentUtils.getJoinedLabel(timerEntries[timerTaskIndex].labels);
      return SizedBox(
          height: 45, child: ListView(children: [Padding(padding: const EdgeInsets.only(top: 10), child: Column(children: items))]));
    } else {
      final String currentTask = timerEntries[timerTaskIndex].labels[0];
      final String nextTask = timerTaskIndex < timerEntries.length - 1 ? timerEntries[timerTaskIndex + 1].labels[0] : '';
      return SizedBox(
          width: ScreenUtils.width(context),
          child: Padding(
              padding: EdgeInsets.only(top: 7, bottom: 15),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  currentTaskWidget(keyboardVisibilty,currentTask, true),
                  Positioned(
                      left: ScreenUtils.width(context) - 70,
                      child: Text(
                        nextTask,
                        style: const TextStyle(fontSize: 20, color: OlukoColors.grayColorSemiTransparent, fontWeight: FontWeight.bold),
                      )),
                ],
              )));
    }
  }

  ///Clock countdown label
  Widget _countdownSection() {
    if (isWorkStateFinished()) {
      return TimerUtils.completedTimer(context);
    }

    if (!isWorkStatePaused() && (isCurrentTaskByReps() || isCurrentTaskByDistance())) {
      return TimerUtils.repsTimer(
          () => setState(() {
                _goToNextStep();
              }),
          context);
    }

    if (isWorkStatePaused() && (isCurrentTaskByReps() || isCurrentTaskByDistance())) {
      return TimerUtils.pausedTimer(context);
    }

    final Duration actualTime = Duration(seconds: timerEntries[timerTaskIndex].value) - timeLeft;

    double circularProgressIndicatorValue = actualTime.inSeconds / timerEntries[timerTaskIndex].value;
    if (circularProgressIndicatorValue.isNaN) circularProgressIndicatorValue = 0;

    if (isWorkStatePaused()) {
      return TimerUtils.pausedTimer(context, TimeConverter.durationToString(timeLeft));
    }

    //TODO: Fix end round timer
    /*if (isTimedTask && actualTime.inSeconds <= 5) {
      TimerUtils.initialTimer(
          InitialTimerType.End,
          timerEntries[timerTaskIndex].roundNumber + 1,
          5,
          timeLeft.inSeconds,
          context);
    }*/

    if (workState == WorkState.resting) {
      return TimerUtils.restTimer(circularProgressIndicatorValue, TimeConverter.durationToString(timeLeft), context);
    }

    if (timerEntries[timerTaskIndex].round == null) {
      //is AMRAP
      return TimerUtils.AMRAPTimer(circularProgressIndicatorValue, TimeConverter.durationToString(timeLeft), context, () {
        setState(() {
          AMRAPRound++;
        });
        if (AMRAPRound == 1) {
          _saveSegmentRound(timerEntries[timerTaskIndex]);
        }
      });
    }
    final String counter = timerEntries[timerTaskIndex].counter == CounterEnum.reps ? timerEntries[timerTaskIndex].movement.name : null;
    return TimerUtils.timeTimer(circularProgressIndicatorValue, TimeConverter.durationToString(timeLeft), context, counter);
  }

  Widget currentTaskWidget(bool keyboardVisibilty,String currentTask, [bool smaller = false]) {
        return Visibility(
          visible: !keyboardVisibilty,
          child: Text(
            currentTask,
            style: TextStyle(fontSize: smaller ? 20 : 25, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      ;
  }

  Widget nextTaskWidget(String nextTask,bool keyboardVisibilty) {
    return BlocBuilder<KeyboardBloc, KeyboardState>(
      builder: (context, state) {
        return Visibility(
          visible: !keyboardVisibilty,
          child: ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: Text(
              nextTask,
              style: const TextStyle(fontSize: 25, color: Color.fromRGBO(255, 255, 255, 0.25), fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  ///Lower half of the view
  Widget _lowerSection() {
    if (workState != WorkState.finished) {
      return Container(color: Colors.black, child: isSegmentWithRecording() ? _cameraSection() : SizedBox());
    } else {
      return _segmentInfoSection();
    }
  }

  ///Camera recording section. Shows camera Input and start/stop buttons.
  Widget _cameraSection() {
    return isWorkStatePaused()
        ? const SizedBox()
        : SizedBox(
            height: ScreenUtils.height(context) / 2,
            width: ScreenUtils.width(context),
            child: Stack(
              children: [
                if (!_isReady)
                  Container()
                else
                  Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/courses/camera_background.png'),
                        fit: BoxFit.cover,
                      )),
                      child: Center(child: AspectRatio(aspectRatio: 3.0 / 4.0, child: CameraPreview(cameraController)))),
                Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.all(20.0), child: pauseButton())),
              ],
            ));
  }

  bool isCurrentTaskTimed() {
    return timerEntries[timerTaskIndex].parameter == ParameterEnum.duration;
  }

  bool isCurrentTaskByReps() {
    return timerEntries[timerTaskIndex].parameter == ParameterEnum.reps;
  }

  bool isCurrentTaskByDistance() {
    return timerEntries[timerTaskIndex].parameter == ParameterEnum.distance;
  }

  bool isCurrentMovementRest() {
    return timerEntries[timerTaskIndex].movement.isRestTime;
  }

  Widget pauseButton() {
    return GestureDetector(
        onTap: () async {
          setState(() {
            if (isCurrentTaskTimed()) {
              _pauseCountdown();
            } else {
              setPaused();
            }
          });
          if (isSegmentWithRecording()) {
            await cameraController.stopVideoRecording();
          }
          setState(() {
            workoutType = WorkoutType.segment;
            isPlaying = false;
          });
        },
        child: Stack(alignment: Alignment.center, children: [
          Image.asset(
            'assets/courses/oval.png',
            scale: 4,
          ),
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Image.asset(
                'assets/courses/center_oval.png',
                scale: 4,
              )),
          Image.asset(
            'assets/courses/pause_button.png',
            scale: 4,
          ),
        ]));
  }

  Widget _cameraButton(IconData iconData, {Function() onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Icon(
        iconData,
        color: OlukoColors.primary,
        size: 30,
      ),
    );
  }

  //Timer Functions
  _saveSegmentRound(TimerEntry timerEntry) async {
    if (isSegmentWithRecording()) {
      videoRecorded = await cameraController.stopVideoRecording();
      setState(() {
        workoutType = WorkoutType.segment;
      });
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'roundInfo'));
      /*DialogUtils.getDialog(context, _confirmDialogContent(),
          showExitButton: true);*/
    }
  }

  List<Widget> _confirmDialogContent() {
    return [
      Icon(Icons.info_outline, color: Colors.white, size: 60),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(OlukoLocalizations.get(context, 'roundInfo'), textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont()),
      ),
      Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 65, left: 65),
          child: Row(children: [
            OlukoPrimaryButton(
              title: OlukoLocalizations.get(context, 'ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ])),
    ];
  }

  void _goToNextStep() {
    if (!SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) && timerEntries[timerTaskIndex].round == 0) {
      if (timerTaskIndex == timerEntries.length - 1 || timerEntries[timerTaskIndex + 1].round == 1) {
        _saveSegmentRound(timerEntries[timerTaskIndex]);
      }
    }

    _saveCounter();

    if (timerTaskIndex == timerEntries.length - 1) {
      _finishWorkout();
      return;
    }
    setState(() {
      timerTaskIndex++;
      _playTask();
    });
  }

  _saveCounter() {
    if (isCurrentMovementRest() && timerEntries[timerTaskIndex - 1].movement.counter != null && textController.text != '') {
      setState(() {
        counter = true;
      });

      addScoreEntry();

      BlocProvider.of<CourseEnrollmentUpdateBloc>(context).saveMovementCounter(
          widget.courseEnrollment,
          widget.segmentIndex,
          timerEntries[timerTaskIndex - 1].sectionIndex,
          widget.classIndex,
          timerEntries[timerTaskIndex - 1].movement,
          widget.segments[widget.segmentIndex].rounds,
          timerEntries[timerTaskIndex - 1].round,
          int.parse(textController.text));
    }
    textController.clear();
  }

  addScoreEntry() {
    setState(() {
      totalScore += int.parse(textController.text);
    });
    scores[timerEntries[timerTaskIndex - 1].round] = textController.text + ' ';
    if (timerEntries[timerTaskIndex - 1].movement.counter == CounterEnum.distance) {
      scores[timerEntries[timerTaskIndex - 1].round] += 'm';
    } else {
      scores[timerEntries[timerTaskIndex - 1].round] += timerEntries[timerTaskIndex - 1].movement.name;
    }
  }

  WorkState getCurrentTaskWorkState() {
    if (isCurrentMovementRest()) {
      return WorkState.resting;
    } else {
      return WorkState.exercising;
    }
  }

  _playTask() async {
    workState = getCurrentTaskWorkState();
    if (isCurrentTaskTimed()) {
      _playCountdown();
      timeLeft = Duration(seconds: timerEntries[timerTaskIndex].value);
    }
  }

  void _finishWorkout() {
    workState = WorkState.finished;

    print('Workout finished');
    BlocProvider.of<CourseEnrollmentBloc>(context).markSegmentAsCompleted(widget.courseEnrollment, widget.segmentIndex, widget.classIndex);
    setState(() {
      if (_segmentSubmission != null && widget.workoutType == WorkoutType.segmentWithRecording && !_isVideoUploaded) {
        topBarIcon = uploadingIcon();
      }
    });
  }

  _startMovement() {
    //Reset countdown variables
    timerTaskIndex = 0;
    timerEntries = SegmentUtils.getExercisesList(widget.segments[widget.segmentIndex]);
    if (timerEntries.isEmpty) {
      _finishWorkout();
      return;
    }
    _playTask();
  }

  void _playCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (timeLeft.inSeconds == 0) {
        _pauseCountdown();
        _goToNextStep();
        return;
      }
      setState(() {
        timeLeft = Duration(seconds: timeLeft.inSeconds - 1);
      });
    });
  }

  void setPaused() {
    lastWorkStateBeforePause = workState;
    workState = WorkState.paused;
  }

  void _pauseCountdown() {
    setPaused();
    countdownTimer.cancel();
  }

  @override
  void dispose() {
    Wakelock.disable();
    if (countdownTimer != null && countdownTimer.isActive) {
      countdownTimer.cancel();
    }
    cameraController?.dispose();
    super.dispose();
  }

  //Camera functions
  Future<void> _setupCameras() async {
    final int cameraPos = isCameraFront ? 0 : 1;
    try {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[cameraPos], ResolutionPreset.medium);
      await cameraController.initialize();
      await cameraController.startVideoRecording();
    } on CameraException catch (_) {}
    if (!mounted) return;
    setState(() {
      _isReady = true;
    });
  }

//App bar icons
  Widget topCameraIcon() {
    return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Stack(alignment: Alignment.center, children: [
          Image.asset(
            'assets/courses/outlined_camera.png',
            scale: 4,
          ),
          const Padding(padding: EdgeInsets.only(top: 1), child: Icon(Icons.circle_outlined, size: 12, color: OlukoColors.primary))
        ]));
  }

  Widget uploadingIcon() {
    return Padding(
        padding: const EdgeInsets.only(right: 2),
        child: GestureDetector(
            onTap: () {} /*=> BottomDialogUtils.showBottomDialog(
                context: context, content: dialogContainer())*/
            ,
            child: Row(children: [
              Text(
                'Uploading',
                style: OlukoFonts.olukoMediumFont(custoFontWeight: FontWeight.w400),
                textAlign: TextAlign.start,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.upload, color: Colors.white)
            ])));
  }

  Widget audioIcon() {
    return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Image.asset(
          'assets/courses/audio_icon.png',
          scale: 4,
        ));
  }

  ///Section with information about segment and workout movements.
  Widget _segmentInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MovementUtils.movementTitle(widget.segments[widget.segmentIndex].isChallenge
                    ? OlukoLocalizations.get(context, 'challengeTitle') + widget.segments[widget.segmentIndex].name
                    : widget.segments[widget.segmentIndex].name),
              ],
            ),
          ),
          const SizedBox(height: 5),
          if (counter)
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: getScoresByRound())
          else
            Column(children: SegmentUtils.getWorkouts(widget.segments[widget.segmentIndex], OlukoColors.grayColor)),
          SizedBox(height: 10),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: widget.workoutType == WorkoutType.segment || shareDone
                  ? FeedbackCard()
                  : ShareCard(createStory: _createStory, whistleAction: coachAction)),
        ],
      ),
    );
  }

  _createStory() {
    _wantsToCreateStory = true;
    if (waitingForSegSubCreation) {
      if (_isVideoUploaded) {
        callBlocToCreateStory(context, _segmentSubmission);
      }
    } else if (_segmentSubmission == null) {
      createSegmentSubmission();
    }
  }

  coachAction() {
    if (!waitingForSegSubCreation) {
      createSegmentSubmission();
    }
  }

  createSegmentSubmission() {
    waitingForSegSubCreation = true;
    BlocProvider.of<SegmentSubmissionBloc>(context)
        .create(_user, widget.courseEnrollment, widget.segments[widget.segmentIndex], videoRecorded.path, _coachRequest);
  }

  List<Widget> getScoresByRound() {
    final bool isCounterByReps = timerEntries[timerTaskIndex - 1].counter == CounterEnum.reps;
    final List<Widget> widgets = [];
    String totalText = '${OlukoLocalizations.get(context, 'total')}: $totalScore ';
    if (isCounterByReps) {
      totalText += timerEntries[timerTaskIndex - 1].movement.name;
    } else {
      totalText += OlukoLocalizations.get(context, 'meters');
    }

    widgets.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(totalText, style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.w600, customColor: OlukoColors.primary)),
    ]));

    widgets.add(const SizedBox(height: 15));
    for (int i = 0; i < scores.length; i++) {
      widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${OlukoLocalizations.get(context, 'round')} ${i + 1}',
                style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w600, customColor: OlukoColors.white)),
            Container(width: 60),
            SizedBox(
                width: 50,
                child: Text(scores[i],
                    textAlign: TextAlign.end,
                    style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400, customColor: OlukoColors.white)))
          ])));
    }
    return widgets;
  }

  void updateSegment(VideoState state) {
    if (state is VideoProcessing) {
      updateProgress(state);
    } else if (state is VideoEncoded) {
      saveEncodedState(state);
    } else if (state is VideoSuccess || state is VideoFailure) {
      if (state is VideoSuccess) {
        saveUploadedState(state);
        showSegmentMessage();
        setState(() {
          topBarIcon = const SizedBox();
        });
      } else if (state is VideoFailure) {
        saveErrorState(state);
      }
    }
  }

  void saveEncodedState(VideoEncoded state) {
    setState(() {
      _segmentSubmission.videoState.state = SubmissionStateEnum.encoded;
      _segmentSubmission.videoState.stateInfo = state.encodedFilesDir;
      _segmentSubmission.video = state.video;
      _segmentSubmission.videoState.stateExtraInfo = state.thumbFilePath;
    });
    BlocProvider.of<SegmentSubmissionBloc>(context).updateStateToEncoded(_segmentSubmission);
  }

  void saveUploadedState(VideoSuccess state) {
    setState(() {
      processPhase = OlukoLocalizations.get(context, 'completed');
      progress = 1.0;
      _segmentSubmission.video = state.video;
    });
    BlocProvider.of<SegmentSubmissionBloc>(context).updateVideo(_segmentSubmission);
  }

  void saveErrorState(VideoFailure state) {
    setState(() {
      isThereError = true;
      _segmentSubmission.videoState.error = state.exceptionMessage;
    });
    BlocProvider.of<SegmentSubmissionBloc>(context).updateStateToError(_segmentSubmission);
  }

  void showSegmentMessage() {
    String message;
    if (isThereError) {
      message = OlukoLocalizations.get(context, 'uploadedWithErrors');
    } else {
      message = OlukoLocalizations.get(context, 'segmentUploadedSuccessfully');
    }
    AppMessages.clearAndShowSnackbar(context, message);
  }

  void updateProgress(VideoProcessing state) {
    setState(() {
      processPhase = state.processPhase;
      progress = state.progress;
    });
  }

  static Future<bool> onWillPop(BuildContext context, bool isRecording) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            title: TitleBody(OlukoLocalizations.get(context, 'exitConfirmationTitle')),
            content: Text(
                isRecording
                    ? OlukoLocalizations.get(context, 'goBackConfirmationWithRecording')
                    : OlukoLocalizations.get(context, 'goBackConfirmationWithoutRecording'),
                // OlukoLocalizations.get(context, 'exitConfirmationBody'),
                style: OlukoFonts.olukoBigFont()),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  OlukoLocalizations.get(context, 'no'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/segment-detail'));
                },
                child: Text(
                  OlukoLocalizations.get(context, 'yes'),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget dialogContainer() {
    return Stack(children: [
      Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/courses/dialog_background.png'),
            fit: BoxFit.cover,
          )),
          child: Column(children: [
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            Padding(padding: const EdgeInsets.all(40.0), child: ProgressBar(processPhase: processPhase, progress: progress)),
          ])),
      Align(
          alignment: Alignment.topRight,
          child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)))
    ]);
  }

  List<Widget> stopProcessConfirmationContent(function) {
    return [
      Text(
        OlukoLocalizations.get(context, 'stopProcessConfirmation'),
        textAlign: TextAlign.center,
        style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
      ),
      Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Row(
            children: [
              OlukoOutlinedButton(
                title: OlukoLocalizations.get(context, 'no'),
                thinPadding: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 20),
              OlukoPrimaryButton(
                title: OlukoLocalizations.get(context, 'yes'),
                onPressed: () {
                  Navigator.pop(context);
                  function();
                },
              ),
            ],
          ))
    ];
  }
}
