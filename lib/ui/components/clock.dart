import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:oluko_app/blocs/amrap_round_bloc.dart';
import 'package:oluko_app/blocs/clocks_timer_bloc.dart';
import 'package:oluko_app/blocs/segments/current_time_bloc.dart';
import 'package:oluko_app/blocs/stopwatch_bloc.dart';
import 'package:oluko_app/blocs/timer_task_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/ui/components/custom_keyboard.dart';
import 'package:oluko_app/ui/newDesignComponents/rep_timer_component.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/sound_player.dart';
import 'package:oluko_app/utils/sound_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:oluko_app/utils/timer_utils.dart';
import 'package:headset_connection_event/headset_event.dart';

class Clock extends StatefulWidget {
  final WorkState workState;
  final WorkoutType workoutType;
  final List<Segment> segments;
  final int segmentIndex;
  int timerTaskIndex;
  final List<TimerEntry> timerEntries;
  //final int timerTaskIndex;
  TextEditingController textController;
  final Function() goToNextStep;
  final Function() setPaused;
  final Function() actionAMRAP;
  Duration timeLeft;

  Clock(
      {this.workState,
      this.segments,
      this.segmentIndex,
      this.timerEntries,
      this.textController,
      this.goToNextStep,
      this.setPaused,
      this.actionAMRAP,
      this.workoutType,
      this.timerTaskIndex = 0,
      this.timeLeft});

  @override
  _State createState() => _State();
}

class _State extends State<Clock> with WidgetsBindingObserver {
  Timer countdownTimer;
  int AMRAPRound = 0;
  Duration stopwatch = Duration();
  final _headsetPlugin = HeadsetEvent();
  HeadsetState _headsetState;
  final SoundPlayer _soundPlayer = SoundPlayer();
  bool skipRest = true;
  FocusNode focusNode = FocusNode();
  DateTime _backgroundTime;
  Duration secondsBeforePaused;
  bool canReproduce = true;
  bool isKeyboardRequested = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      canReproduce = false;
      _backgroundTime = DateTime.now();
      secondsBeforePaused = widget.timeLeft;
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null) {
        secondsBeforePaused -= DateTime.now().difference(_backgroundTime);
        if (secondsBeforePaused > Duration.zero) {
          widget.timeLeft = secondsBeforePaused;
        } else {
          widget.timeLeft = Duration.zero;
        }
        _backgroundTime = null;
        Future.delayed(const Duration(milliseconds: 3000), () {
          canReproduce = true;
        });
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _headsetPlugin.getCurrentState.then((headsetStatus) {
      setState(() {
        _headsetState = headsetStatus;
      });
    });

    if (AMRAPRound != 0) {
      AMRAPRound = 0;
    }
    if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) && isWorkStateFinished() && AMRAPRound == 0) {
      BlocProvider.of<AmrapRoundBloc>(context).get();
    }
    if (!isWorkStateFinished() && isCurrentTaskTimed()) {
      widget.timeLeft = Duration(seconds: widget.timeLeft.inSeconds);
      _playCountdown(() => widget.goToNextStep(), () => widget.setPaused(), headsetState: _headsetState);
    }
  }

  @override
  void deactivate() {
    if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) && isWorkStateFinished() && AMRAPRound != 0) {
      BlocProvider.of<AmrapRoundBloc>(context).emitDefault();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (countdownTimer != null && countdownTimer.isActive) {
      countdownTimer.cancel();
    }
    _soundPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AmrapRoundBloc, AmrapRound>(builder: (context, amrapState) {
      if (amrapState is AmrapRound && AMRAPRound != amrapState.amrapValue) {
        AMRAPRound = amrapState.amrapValue;
      }
      return BlocListener<StopwatchBloc, StopwatchState>(
          listener: (context, stopwatchState) {
            if (stopwatchState is UpdateStopwatchSuccess) {
              setState(() {
                stopwatch = stopwatchState.duration;
              });
            }
          },
          child: BlocListener<TimerTaskBloc, TimerTaskState>(
              listener: (context, timerTaskState) {
                if (timerTaskState is SetTimerTaskIndex) {
                  setState(() {
                    widget.timerTaskIndex = timerTaskState.timerTaskIndex;
                    skipRest = true;
                  });
                }
              },
              child: BlocListener<ClocksTimerBloc, ClocksTimerState>(
                  listener: (context, state) {
                    if (state is ClocksTimerPlay) {
                      _playCountdown(() => state.goToNextStep(), () => state.setPaused(), headsetState: _headsetState);
                    } else if (state is ClocksTimerPause) {
                      _pauseCountdown(() => state.setPaused());
                    } else if (state is UpdateTimeLeft) {
                      widget.timeLeft = Duration(seconds: widget.timerEntries[widget.timerTaskIndex].value);
                    }
                  },
                  child: _timerSection())));
    });
  }

  Widget _timerSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Container(
            color: OlukoNeumorphismColors.appBackgroundColor,
            child: Column(
              children: [
                if (OlukoNeumorphism.isNeumorphismDesign) const SizedBox.shrink() else getSegmentLabel(),
                Padding(
                    padding: EdgeInsets.only(
                      top: SegmentClocksUtils.getWatchPadding(widget.workState, _usePulseAnimationForResting()),
                    ),
                    child: ScreenUtils.height(context) < 700
                        ? SizedBox(
                            height: isWorkStateFinished() ? 205 : 270,
                            width: isWorkStateFinished() ? 205 : 270,
                            child: Stack(
                                alignment: Alignment.center,
                                children: [if (_usePulseAnimationForResting()) roundTimerWithPulse() else getRoundsTimer(), countdownSection()]),
                          )
                        : Stack(alignment: Alignment.center, children: [
                            if (_usePulseAnimationForResting())
                              roundTimerWithPulse()
                            else
                              isWorkStateFinished() ? SizedBox(height: 250, width: 250, child: getRoundsTimer()) : getRoundsTimer(),
                            countdownSection(),
                          ])),
              ],
            ),
          ),
        ),
        if (isWorkStateFinished()) const SizedBox() else Positioned(top: ScreenUtils.height(context) * 0.48, child: _tasksSection()),
        if ((widget.workState == WorkState.resting && skipRest) && (canUseSkipRest() && !isKeyboardRequested))
          Positioned(
            bottom: 100,
            child: Container(
              width: ScreenUtils.width(context),
              height: 60,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    widget.timeLeft = const Duration(seconds: 5);
                    skipRest = !skipRest;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.skip_next, color: OlukoColors.primary),
                    Text('Skip rest - next movement',
                        textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w300, customColor: OlukoColors.primary)),
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }

  bool canUseSkipRest() => widget.timeLeft > const Duration(seconds: 5);

  Widget countdownSection() {
    if (isWorkStateFinished()) {
      if (ScreenUtils.smallScreen(context)) {
        return SizedBox(
            height: 150,
            width: 150,
            child: TimerUtils.completedTimer(
                context, !SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) ? widget.segments[widget.segmentIndex].rounds : AMRAPRound));
      } else {
        return SizedBox(
            height: 180,
            width: 180,
            child: TimerUtils.completedTimer(
                context, !SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) ? widget.segments[widget.segmentIndex].rounds : AMRAPRound));
      }
    }

    if (!isWorkStatePaused() && (isCurrentTaskByReps() || isCurrentTaskByDistance())) {
      return TimerUtils.repsTimer(() {
        widget.goToNextStep();
      }, context, widget.timerEntries[widget.timerTaskIndex].movement.isBothSide,
          widget.timerEntries[widget.timerTaskIndex].stopwatch ? TimeConverter.durationToString(stopwatch) : null);
    }

    if (isWorkStatePaused() && (isCurrentTaskByReps() || isCurrentTaskByDistance())) {
      return TimerUtils.pausedTimer(context);
    }

    if (widget.timerEntries[widget.timerTaskIndex].isInitialTimer != null && widget.timerEntries[widget.timerTaskIndex].isInitialTimer) {
      return TimerUtils.initialTimer(InitialTimerType.Start, widget.timerEntries[widget.timerTaskIndex].round, widget.timerEntries[widget.timerTaskIndex].value,
          widget.timeLeft.inSeconds, context, widget.timerEntries[widget.timerTaskIndex]);
    }

    final Duration actualTime = Duration(seconds: widget.timerEntries[widget.timerTaskIndex].value) - widget.timeLeft;

    double circularProgressIndicatorValue = actualTime.inSeconds / widget.timerEntries[widget.timerTaskIndex].value;
    if (circularProgressIndicatorValue.isNaN) circularProgressIndicatorValue = 0;

    if (isWorkStatePaused()) {
      return TimerUtils.pausedTimer(context, TimeConverter.durationToString(widget.timeLeft));
    }

    if (widget.workState == WorkState.resting) {
      final bool needInput = useInput();
      if (widget.timerEntries[widget.timerTaskIndex].counter == CounterEnum.none && widget.timeLeft.inSeconds <= 5) {
        return TimerUtils.finalTimer(InitialTimerType.End, widget.timerEntries[widget.timerTaskIndex].value, widget.timeLeft.inSeconds, context,
            isLastEntryOfTheRound() ? widget.timerEntries[widget.timerTaskIndex].round : null);
      } else {
        return needInput && OlukoNeumorphism.isNeumorphismDesign
            ? TimerUtils.restTimer(
                needInput ? neumorphicTextfieldForScore() : null,
                circularProgressIndicatorValue,
                TimeConverter.durationToString(widget.timeLeft),
                context,
              )
            : TimerUtils.restTimer(
                needInput ? getTextField() : null,
                circularProgressIndicatorValue,
                TimeConverter.durationToString(widget.timeLeft),
                context,
              );
      }
    }

    if (widget.timerEntries[widget.timerTaskIndex].round == null) {
      //is AMRAP
      return TimerUtils.AMRAPTimer(
        circularProgressIndicatorValue,
        TimeConverter.durationToString(widget.timeLeft),
        context,
        () {
          widget.actionAMRAP();
        },
        AMRAPRound,
      );
    }
    final String counter =
        widget.timerEntries[widget.timerTaskIndex].counter == CounterEnum.reps ? widget.timerEntries[widget.timerTaskIndex].movement.name : null;

    if (widget.timeLeft.inSeconds <= 5) {
      return TimerUtils.finalTimer(InitialTimerType.End, widget.timerEntries[widget.timerTaskIndex].value, widget.timeLeft.inSeconds, context,
          isLastEntryOfTheRound() ? widget.timerEntries[widget.timerTaskIndex].round : null);
    } else {
      return TimerUtils.timeTimer(
        circularProgressIndicatorValue,
        TimeConverter.durationToString(widget.timeLeft),
        context,
        counter,
        widget.timerEntries[widget.timerTaskIndex].movement.isBothSide,
      );
    }
  }

  bool isWorkStateFinished() {
    return widget.workState == WorkState.finished;
  }

  bool isWorkStatePaused() {
    return widget.workState == WorkState.paused;
  }

  bool isCurrentMovementRest() {
    return widget.timerEntries[widget.timerTaskIndex].movement.isRestTime;
  }

  Widget getTextField() {
    final CounterEnum currentCounter = widget.timerEntries[widget.timerTaskIndex - 1].counter;
    final bool isCounterByReps = currentCounter == CounterEnum.reps;
    List<String> counterTxt = SegmentClocksUtils.counterText(context, currentCounter, widget.timerEntries[widget.timerTaskIndex - 1].movement.name);
    return Container(
      decoration: BoxDecoration(
        gradient: OlukoNeumorphism.olukoNeumorphicGradientDark(),
      ),
      height: 50,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 20),
              Text(counterTxt[0], style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w300)),
              const SizedBox(width: 10),
              SizedBox(
                  width: isCounterByReps ? 40 : 70,
                  child: Scrollbar(
                      child: TextField(
                    controller: widget.textController,
                    onTap: () {
                      setState(() {
                        isKeyboardRequested = !isKeyboardRequested;
                      });
                      open();
                    },
                    style: const TextStyle(
                      fontSize: 20,
                      color: OlukoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    focusNode: focusNode,
                    readOnly: true,
                    showCursor: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ))),
              const SizedBox(width: 25),
              Text(counterTxt[1], style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w300)),
            ],
          ),
        ],
      ),
    );
  }

  void open() {
    BottomDialogUtils.showBottomDialog(
      barrierColor: false,
      context: context,
      content: Container(
        height: ScreenUtils.height(context) * 0.35,
        child: CustomKeyboard(
          boxDecoration: OlukoNeumorphism.boxDecorationForKeyboard(),
          controller: widget.textController,
          focus: focusNode,
          onSubmit: () {
            Navigator.pop(context);
            focusNode.unfocus();
            setState(() {
              isKeyboardRequested = !isKeyboardRequested;
            });
          },
        ),
      ),
    );
  }

  Container neumorphicTextfieldForScore() {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      height: 65,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: ScreenUtils.width(context) / 3.7,
                  child: Scrollbar(
                      child: TextField(
                    textAlign: TextAlign.center,
                    controller: widget.textController,
                    onTap: () {
                      setState(() {
                        isKeyboardRequested = !isKeyboardRequested;
                      });
                      open();
                    },
                    style: const TextStyle(
                      fontSize: 20,
                      color: OlukoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    focusNode: focusNode,
                    readOnly: true,
                    showCursor: true,
                    decoration: InputDecoration(
                      isDense: false,
                      contentPadding: EdgeInsets.zero,
                      focusColor: Colors.transparent,
                      fillColor: Colors.transparent,
                      hintText: OlukoLocalizations.get(context, "enterScore"),
                      hintStyle: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColorSemiTransparent),
                      hintMaxLines: 1,
                      border: InputBorder.none,
                    ),
                  ))),
              SizedBox(
                width: 100,
                child: Text(
                  OlukoNeumorphism.isNeumorphismDesign && ScreenUtils.height(context) < 700
                      ? OlukoLocalizations.get(context, SegmentUtils.getCounterInputLabel(widget.timerEntries[widget.timerTaskIndex - 1].counter))
                      : widget.timerEntries[widget.timerTaskIndex - 1].movement.name,
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w300),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (widget.textController.value != null && widget.textController.value.text != "")
            const SizedBox.shrink()
          else
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    OlukoLocalizations.get(context, "typeScore"),
                    textAlign: TextAlign.center,
                    style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.primary),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  bool isCurrentTaskByReps() {
    return widget.timerEntries[widget.timerTaskIndex].parameter == ParameterEnum.reps;
  }

  bool isCurrentTaskByDistance() {
    return widget.timerEntries[widget.timerTaskIndex].parameter == ParameterEnum.distance;
  }

  bool isLastEntryOfTheRound() {
    if (widget.timerTaskIndex == widget.timerEntries.length - 1) {
      return true;
    } else if (widget.timerEntries[widget.timerTaskIndex + 1].round != widget.timerEntries[widget.timerTaskIndex].round) {
      return true;
    } else {
      return false;
    }
  }

  Widget roundTimerWithPulse() {
    return Stack(alignment: Alignment.center, children: [
      Stack(alignment: Alignment.center, children: [
        Transform.scale(scale: 1.6, child: const AvatarGlow(glowColor: Color.fromARGB(255, 3, 254, 149), endRadius: 160, child: SizedBox.shrink())),
        Transform.scale(scale: 1.8, child: const AvatarGlow(glowColor: Color.fromARGB(255, 3, 254, 149), endRadius: 160, child: SizedBox.shrink()))
      ]),
      getRoundsTimer()
    ]);
  }

  Widget getRoundsTimer() {
    if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex]) && isWorkStateFinished()) {
      return TimerUtils.roundsTimer(AMRAPRound, AMRAPRound);
    } else if (isWorkStateFinished()) {
      return TimerUtils.roundsTimer(
        widget.segments[widget.segmentIndex].rounds,
        widget.segments[widget.segmentIndex].rounds,
      );
    } else if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
      return TimerUtils.roundsTimer(
        AMRAPRound,
        AMRAPRound,
      );
    } else {
      return TimerUtils.roundsTimer(
        widget.segments[widget.segmentIndex].rounds,
        widget.timerEntries[widget.timerTaskIndex].round,
      );
    }
  }

  Widget getSegmentLabel() {
    if (isWorkStateFinished()) {
      return const SizedBox();
    }
    if (SegmentUtils.isEMOM(widget.segments[widget.segmentIndex])) {
      return TimerUtils.getRoundLabel(widget.timerEntries[widget.timerTaskIndex].round);
    } else if (SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])) {
      return TimerUtils.getRoundLabel(AMRAPRound);
    } else {
      return const SizedBox();
    }
  }

  ///Current and next movement labels
  Widget _tasksSection() {
    return isSegmentWithoutRecording()
        ? taskSectionWithoutRecording()
        : Column(
            children: [
              if (OlukoNeumorphism.isNeumorphismDesign) const SizedBox.shrink() else const SizedBox(height: 10),
              SegmentClocksUtils.recordingTaskSection(context, widget.timerEntries, widget.timerTaskIndex),
              const SizedBox(
                height: 60,
              ),
              ...counterTextField(),
              if (OlukoNeumorphism.isNeumorphismDesign) const SizedBox.shrink() else const SizedBox(height: 20),
            ],
          );
  }

  Widget currentAndNextTaskWithCounter(String currentTask, String nextTask) {
    return Column(
      children: [
        SizedBox(width: ScreenUtils.width(context) * 0.7, child: SegmentClocksUtils.currentTaskWidget(currentTask)),
        const SizedBox(height: 10),
        SizedBox(width: ScreenUtils.width(context), child: SegmentClocksUtils.nextTaskWidget(nextTask)),
        const SizedBox(height: 15),
        ...counterTextField(),
      ],
    );
  }

  List<Widget> counterTextField() {
    if (isCurrentMovementRest() &&
        (widget.timerEntries[widget.timerTaskIndex - 1].counter == CounterEnum.reps ||
            widget.timerEntries[widget.timerTaskIndex - 1].counter == CounterEnum.distance ||
            widget.timerEntries[widget.timerTaskIndex - 1].counter == CounterEnum.weight)) {
      final bool isCounterByReps = widget.timerEntries[widget.timerTaskIndex - 1].counter == CounterEnum.reps;
      return [
        SizedBox.shrink(),
        if (!isSegmentWithRecording())
          SizedBox(
            height: ScreenUtils.height(context) / 4,
          )
        else
          SizedBox()
      ];
    } else {
      return [const SizedBox()];
    }
  }

  Widget taskSectionWithoutRecording() {
    final bool hasMultipleLabels = widget.timerEntries[widget.timerTaskIndex].labels.length > 1;
    if (hasMultipleLabels) {
      return SizedBox(
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context) * 0.4,
        child: ListView(
            physics: OlukoNeumorphism.listViewPhysicsEffect,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            padding: EdgeInsets.zero,
            children: SegmentUtils.getJoinedLabel(widget.timerEntries[widget.timerTaskIndex].labels)),
      );
    } else {
      String currentTask = widget.timerEntries[widget.timerTaskIndex].labels[0];
      String nextTask = widget.timerTaskIndex < widget.timerEntries.length - 1 ? widget.timerEntries[widget.timerTaskIndex + 1].labels[0] : '';
      if (widget.timerTaskIndex == 0) {
        currentTask = widget.timerEntries[widget.timerTaskIndex + 1].labels[0];
        nextTask = widget.timerTaskIndex < widget.timerEntries.length - 2 ? widget.timerEntries[widget.timerTaskIndex + 2].labels[0] : '';
      }
      return Padding(
        padding: OlukoNeumorphism.isNeumorphismDesign
            ? (widget.workState == WorkState.resting && _usePulseAnimationForResting())
                ? const EdgeInsets.only(top: 40)
                : const EdgeInsets.only(top: 35)
            : EdgeInsets.zero,
        child: currentAndNextTaskWithCounter(currentTask, nextTask),
      );
    }
  }

  bool isSegmentWithRecording() {
    return widget.workoutType == WorkoutType.segmentWithRecording;
  }

  bool isSegmentWithoutRecording() {
    return widget.workoutType == WorkoutType.segment;
  }

  bool _usePulseAnimationForResting() => isWorkStateFinished() ? false : widget.workState == WorkState.resting && OlukoNeumorphism.isNeumorphismDesign;

  bool usePulseAnimation() {
    if (isWorkStateFinished()) {
      return false;
    }
    return (OlukoNeumorphism.isNeumorphismDesign &&
            !(widget.timerEntries[widget.timerTaskIndex].counter == CounterEnum.reps ||
                widget.timerEntries[widget.timerTaskIndex].counter == CounterEnum.distance)) &&
        (widget.workState == WorkState.resting);
  }

  bool useInput() =>
      isCurrentMovementRest() &&
      (widget.timerEntries[widget.timerTaskIndex - 1].counter == CounterEnum.reps ||
          widget.timerEntries[widget.timerTaskIndex - 1].counter == CounterEnum.distance ||
          widget.timerEntries[widget.timerTaskIndex - 1].counter == CounterEnum.weight);

  void _playCountdown(Function() goToNextStep, Function() setPaused, {HeadsetState headsetState}) {
    if (countdownTimer == null || !countdownTimer.isActive) {
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
        if (canReproduce) {
          await SoundUtils.playSound(
              widget.timeLeft.inSeconds - 1, widget.timerEntries[widget.timerTaskIndex].value, workStateForSounds(widget.workState.index),
              headsetState: headsetState, isForWatch: true);
        }
        if (widget.timeLeft.inSeconds == 0) {
          _pauseCountdown(setPaused);
          goToNextStep();
          return;
        }
        if (mounted) {
          setState(() {
            widget.timeLeft = Duration(seconds: widget.timeLeft.inSeconds - 1);
            BlocProvider.of<CurrentTimeBloc>(context).setCurrentTimeValue(Duration(milliseconds: widget.timeLeft.inMilliseconds));
          });
        }
      });
    }
  }

  bool nextIsLastOne() {
    return widget.timerTaskIndex + 1 == widget.timerEntries.length - 1;
  }

  void _pauseCountdown(Function() setPaused) {
    setPaused();
    countdownTimer.cancel();
  }

  bool isCurrentTaskTimed() {
    return widget.timerEntries[widget.timerTaskIndex].parameter == ParameterEnum.duration;
  }
}

int workStateForSounds(int workState) {
  if (workState == WorkState.countdown.index) {
    return ClockStateEnum.segmentStart.index;
  }
  return workState;
}
