import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mvt_fitness/utils/oluko_localizations.dart';
import 'package:mvt_fitness/utils/screen_utils.dart';

class CountdownOverlay extends StatefulWidget {
  final num seconds;
  final String title;
  CountdownOverlay({this.seconds = 5, this.title});

  @override
  _CountdownOverlayState createState() => _CountdownOverlayState(seconds);
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  Timer countdownTimer;
  num countdown;

  _CountdownOverlayState(num seconds) {
    countdown = seconds;
    countdownTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      this.setState(() {
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
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Container(
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context),
        child: Stack(
          children: [
            Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(45.0),
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  child: Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        countdown.toString(),
                        style: TextStyle(
                            fontSize: 150,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        OlukoLocalizations.of(context)
                            .find('seconds')
                            .toUpperCase(),
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  )),
                )),
          ],
        ),
      ),
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
