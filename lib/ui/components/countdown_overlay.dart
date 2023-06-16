import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/screens/courses/initial_timer_panel.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/sound_utils.dart';
import 'package:oluko_app/utils/timer_utils.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';

class CountdownOverlay extends StatefulWidget {
  final int seconds;
  final int totalRounds;
  final int currentRound;
  final bool recording;
  final Function() onShowAgainPressed;
  final bool showPanel;

  CountdownOverlay({this.seconds = 5, this.totalRounds, this.currentRound, this.recording, this.onShowAgainPressed, this.showPanel});

  @override
  _CountdownOverlayState createState() => _CountdownOverlayState(seconds);
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  Timer countdownTimer;
  int countdown;
  PanelController panelController = PanelController();
  bool open = true;

  _CountdownOverlayState(int seconds) {
    countdown = seconds;
    countdownTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
      await SoundUtils.playSound(countdown - 1, widget.seconds, 2, isForWatch: true);
      setState(() {
        if (countdown > 1) {
          countdown--;
        } else {
          countdownTimer.cancel();
          Navigator.pop(context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: OlukoNeumorphismColors.appBackgroundColor.withOpacity(OlukoNeumorphism.isNeumorphismDesign ? 1 : 0.8),
        body: widget.recording && widget.showPanel
            ? SlidingUpPanel(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                controller: panelController,
                minHeight: 0,
                maxHeight: 330,
                collapsed: Container(color: OlukoColors.black),
                panel: InitialTimerPanel(
                  panelController: panelController,
                  onShowAgainPressed: widget.onShowAgainPressed,
                ),
                body: body())
            : body());
  }

  Widget body() {
    if (panelController.isAttached && open) {
      panelController.open();
      open = false;
    }
    return Container(
      width: ScreenUtils.width(context),
      height: ScreenUtils.height(context),
      child: Column(children: [
        SizedBox(height: 15),
        Row(children: [
          Expanded(child: SizedBox()),
          IconButton(
              icon: Icon(
                Icons.close,
                size: 28,
                color: Colors.grey,
              ),
              onPressed: () {
                //TODO: fix this to go back
                Navigator.pop(context);
              })
        ]),
        SizedBox(height: 30),
        Stack(alignment: Alignment.center, children: [
          TimerUtils.roundsTimer(widget.totalRounds, widget.currentRound),
          TimerUtils.initialTimer(InitialTimerType.Start, widget.currentRound, widget.seconds, countdown, context, null)
        ])
      ]),
    );
  }

  @override
  void dispose() {
    if (countdownTimer != null && countdownTimer.isActive) {
      countdownTimer.cancel();
    }
    super.dispose();
  }
}
