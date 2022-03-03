import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/keyboard/keyboard_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:oluko_app/utils/timer_utils.dart';

class Clock extends StatefulWidget {
  final WorkState workState;
  final List<Segment> segments;
  final int segmentIndex;
  final int AMRAPRound;
  final List<TimerEntry> timerEntries;
  final int timerTaskIndex;
  TextEditingController textController;
  final Function() goToNextStep;
  final Function() actionAMRAP;
  final   Duration timeLeft;

  Clock(
      {this.workState,
      this.segments,
      this.segmentIndex,
      this.AMRAPRound,
      this.timerEntries,
      this.timerTaskIndex,
      this.textController,
      this.goToNextStep,
      this.actionAMRAP,
      this.timeLeft});

  @override
  _State createState() => _State();
}

class _State extends State<Clock> {
  @override
  Widget build(BuildContext context) {
    return countdownSection();
  }

  Widget countdownSection() {
    if (isWorkStateFinished()) {
      if (ScreenUtils.smallScreen(context)) {
        return SizedBox(
            height: 150,
            width: 150,
            child: TimerUtils.completedTimer(
                context,
                !SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])
                    ? widget.segments[widget.segmentIndex].rounds
                    : widget.AMRAPRound));
      } else {
        return SizedBox(
            height: 180,
            width: 180,
            child: TimerUtils.completedTimer(
                context,
                !SegmentUtils.isAMRAP(widget.segments[widget.segmentIndex])
                    ? widget.segments[widget.segmentIndex].rounds
                    : widget.AMRAPRound));
      }
    }

    if (!isWorkStatePaused() && (isCurrentTaskByReps() || isCurrentTaskByDistance())) {
      return BlocBuilder<KeyboardBloc, KeyboardState>(
        builder: (context, state) {
          BlocProvider.of<KeyboardBloc>(context).add(HideKeyboard());
          return TimerUtils.repsTimer(
            () => widget.goToNextStep(),
            context,
            widget.timerEntries[widget.timerTaskIndex].movement.isBothSide,
          );
        },
      );
    }

    if (isWorkStatePaused() && (isCurrentTaskByReps() || isCurrentTaskByDistance())) {
      return TimerUtils.pausedTimer(context);
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
        return TimerUtils.finalTimer(InitialTimerType.End, 5, widget.timeLeft.inSeconds, context,
            isLastEntryOfTheRound() ? widget.timerEntries[widget.timerTaskIndex].round : null);
      } else {
        return needInput && OlukoNeumorphism.isNeumorphismDesign
            ? TimerUtils.restTimer(
                needInput ? neumorphicTextfieldForScore(true) : null,
                circularProgressIndicatorValue,
                TimeConverter.durationToString(widget.timeLeft),
                context,
              )
            : TimerUtils.restTimer(
                needInput ? getTextField(true) : null,
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
        widget.AMRAPRound,
      );
    }
    final String counter = widget.timerEntries[widget.timerTaskIndex].counter == CounterEnum.reps
        ? widget.timerEntries[widget.timerTaskIndex].movement.name
        : null;

    if (widget.timeLeft.inSeconds <= 5) {
      return TimerUtils.finalTimer(InitialTimerType.End, 5, widget.timeLeft.inSeconds, context,
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

  Widget getTextField(bool keyboardVisibilty) {
    final CounterEnum currentCounter = widget.timerEntries[widget.timerTaskIndex - 1].counter;
    final bool isCounterByReps = currentCounter == CounterEnum.reps;
    List<String> counterTxt =
        SegmentClocksUtils.counterText(context, currentCounter, widget.timerEntries[widget.timerTaskIndex - 1].movement.name);
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/courses/gray_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      height: 50,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 20),
              Text(counterTxt[0], style: TextStyle(fontSize: 18, color: OlukoColors.white, fontWeight: FontWeight.w300)),
              const SizedBox(width: 10),
              SizedBox(
                width: isCounterByReps ? 40 : 70,
                child: BlocBuilder<KeyboardBloc, KeyboardState>(
                  builder: (context, state) {
                    return Scrollbar(
                      controller: state.textScrollController,
                      child: () {
                        final _customKeyboardBloc = BlocProvider.of<KeyboardBloc>(context);
                        TextSelection textSelection = state.textEditingController.selection;
                        textSelection = state.textEditingController.selection.copyWith(
                          baseOffset: state.textEditingController.text.length,
                          extentOffset: state.textEditingController.text.length,
                        );
                        widget.textController = state.textEditingController;
                        widget.textController.selection = textSelection;

                        return TextField(
                          scrollController: state.textScrollController,
                          controller: widget.textController,
                          onTap: () {
                            !state.setVisible ? _customKeyboardBloc.add(SetVisible()) : null;
                          },
                          style: const TextStyle(
                            fontSize: 20,
                            color: OlukoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          focusNode: state.focus,
                          readOnly: true,
                          showCursor: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        );
                      }(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 25),
              Text(counterTxt[1], style: TextStyle(fontSize: 18, color: OlukoColors.white, fontWeight: FontWeight.w300)),
            ],
          ),
        ],
      ),
    );
  }

  Container neumorphicTextfieldForScore(bool isCounterByReps) {
    //TODO: AJUSTAR EL INPUT
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      height: 65,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isCounterByReps ? ScreenUtils.width(context) / 3.7 : ScreenUtils.width(context) / 3.0,
                child: BlocBuilder<KeyboardBloc, KeyboardState>(
                  builder: (context, state) {
                    return Scrollbar(
                      controller: state.textScrollController,
                      child: () {
                        final _customKeyboardBloc = BlocProvider.of<KeyboardBloc>(context);
                        TextSelection textSelection = state.textEditingController.selection;
                        textSelection = state.textEditingController.selection.copyWith(
                          baseOffset: state.textEditingController.text.length,
                          extentOffset: state.textEditingController.text.length,
                        );
                        widget.textController = state.textEditingController;
                        widget.textController.selection = textSelection;

                        return TextField(
                          textAlign: TextAlign.center,
                          scrollController: state.textScrollController,
                          controller: widget.textController,
                          onTap: () {
                            !state.setVisible ? _customKeyboardBloc.add(SetVisible()) : null;
                          },
                          style: const TextStyle(
                            fontSize: 20,
                            color: OlukoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          focusNode: state.focus,
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
                        );
                      }(),
                    );
                  },
                ),
              ),
              if (isCounterByReps)
                Text(
                  OlukoNeumorphism.isNeumorphismDesign && ScreenUtils.height(context) < 700
                      ? OlukoLocalizations.get(context, 'reps')
                      : widget.timerEntries[widget.timerTaskIndex - 1].movement.name,
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w300),
                  overflow: TextOverflow.ellipsis,
                )
              else
                widget.textController.value != null && widget.textController.value.text != ""
                    ? Expanded(
                        child: Text(
                          OlukoLocalizations.get(context, 'meters'),
                          style: const TextStyle(fontSize: 24, color: OlukoColors.white, fontWeight: FontWeight.w300),
                        ),
                      )
                    : const SizedBox.shrink(),
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
                  // SizedBox(height: 30),
                  Text(
                    'Tap here to type the score',
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

  bool useInput() => (isCurrentMovementRest() &&
      (widget.timerEntries[widget.timerTaskIndex - 1].counter == CounterEnum.reps ||
          widget.timerEntries[widget.timerTaskIndex - 1].counter == CounterEnum.distance));
}
