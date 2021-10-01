import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachAssignedCountDown extends StatefulWidget {
  const CoachAssignedCountDown();

  @override
  _CoachAssignedCountDownState createState() => _CoachAssignedCountDownState();
}

class _CoachAssignedCountDownState extends State<CoachAssignedCountDown> {
  DateTime _now;
  DateTime _auction;
  Timer _timer;

  @override
  void initState() {
    super.initState();

    // Sets the current date time.
    _now = DateTime.now();
    // Sets the date time of the auction.
    _auction = _now.add(Duration(days: 1));

    // Creates a timer that fires every second.
    _timer = Timer.periodic(
      Duration(
        seconds: 1,
      ),
      (timer) {
        setState(() {
          // Updates the current date time.
          _now = DateTime.now();

          // If the auction has now taken place, then cancels the timer.
          if (_auction.isBefore(_now)) {
            timer.cancel();
          }
        });
      },
    );
  }

  void dispose() {
    // Cancels the timer when the page is disposed.
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final difference = _auction.difference(_now);
    return Scaffold(
      appBar: OlukoAppBar(
        title: OlukoLocalizations.get(context, 'coach'),
        showBackButton: false,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: OlukoColors.black,
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Wrap(
            children: [
              Container(
                child: Column(
                  children: [
                    // TextButton(
                    //   onPressed: () {
                    //     Navigator.pushNamed(
                    //         context, routeLabels[RouteEnum.coach2]);
                    //   },
                    //   child: Text(
                    //     OlukoLocalizations.get(context, 'coach'),
                    //     textAlign: TextAlign.center,
                    //     style: OlukoFonts.olukoMediumFont(
                    //         customColor: OlukoColors.primary,
                    //         custoFontWeight: FontWeight.w500),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, routeLabels[RouteEnum.coach2]);
                      },
                      child: Image.asset(
                        'assets/courses/coach.png',
                        color: OlukoColors.primary,
                        height: 100,
                        width: 100,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Text(
                        OlukoLocalizations.get(context, 'hey'),
                        style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        OlukoLocalizations.get(context, 'coachText'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 100,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              difference.inHours.toString(),
                              style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              OlukoLocalizations.get(context, 'hours'),
                              textAlign: TextAlign.center,
                              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          OlukoLocalizations.get(context, 'twoDots'),
                          textAlign: TextAlign.center,
                          style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              difference.inMinutes.remainder(60).toString(),
                              style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              OlukoLocalizations.get(context, 'minute'),
                              textAlign: TextAlign.center,
                              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          OlukoLocalizations.get(context, 'twoDots'),
                          textAlign: TextAlign.center,
                          style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              difference.inSeconds.remainder(60).toString(),
                              style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              OlukoLocalizations.get(context, 'second'),
                              textAlign: TextAlign.center,
                              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
