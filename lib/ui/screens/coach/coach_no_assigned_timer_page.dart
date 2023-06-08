import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachAssignedCountDown extends StatefulWidget {
  const CoachAssignedCountDown({this.currentUser, this.coachAssignment});
  final UserResponse currentUser;
  final CoachAssignment coachAssignment;

  @override
  _CoachAssignedCountDownState createState() => _CoachAssignedCountDownState();
}

class _CoachAssignedCountDownState extends State<CoachAssignedCountDown> {
  DateTime _now;
  Duration _difference;
  DateTime _auction;
  Timer _timer;
  Timestamp _userAssessmentsCompletedAt;
  bool _isTimeExpired = false;
  final Duration _oneDayLimit = const Duration(days: 1);
  final int _hourMinValue = 0;
  final int _timeMinValue = 0;
  final int _minutesSecondsMaxValue = 59;
  final _spacerWidget = const SizedBox(
    height: 20,
  );

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null) {
      startWatchCountdown();
    }
  }

  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final difference = _auction.difference(_now);
    return Scaffold(
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      appBar: OlukoAppBar(title: OlukoLocalizations.get(context, 'coach'), showBackButton: false, showTitle: true, showLogo: false),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: OlukoNeumorphismColors.appBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Wrap(
            children: [
              Container(
                child: Column(
                  children: [
                    if (!OlukoNeumorphism.isNeumorphismDesign)
                      Image.asset(
                        'assets/courses/coach.png',
                        color: OlukoColors.primary,
                        height: 100,
                        width: 100,
                      )
                    else
                      const SizedBox.shrink(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Text(
                        OlukoLocalizations.get(context, 'hello'),
                        style: OlukoNeumorphism.isNeumorphismDesign
                            ? OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500)
                            : OlukoFonts.olukoBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        OlukoLocalizations.get(context, 'coachText'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              countDownWatch(context, difference),
              // _isTimeExpired ? timeExpiredContent(context) : countDownWatch(context, difference),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox timeExpiredContent(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 250,
      child: Center(
        child: Text(
          'Time Expired...',
          style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.error, customFontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget countDownWatch(BuildContext context, Duration difference) {
    return difference != null
        ? OlukoNeumorphism.isNeumorphismDesign
            ? countDownNeumorphic(context, difference)
            : countDownWatchDefault(context, difference)
        : Container(color: OlukoColors.black, child: OlukoCircularProgressIndicator());
  }

  Widget countDownNeumorphic(BuildContext context, Duration difference) {
    int _hourValue = difference.inHours.remainder(60).toInt();
    int _minutesValue = difference.inMinutes.remainder(60).toInt();
    int _secondsValue = difference.inSeconds.remainder(60).toInt();
    return IgnorePointer(
      ignoring: true,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SizedBox(
          width: ScreenUtils.width(context) / 1.25,
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Neumorphic(
                  style: NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.roundRect(const BorderRadius.all(Radius.circular(10))),
                      depth: 2,
                      intensity: 1,
                      color: OlukoColors.black,
                      lightSource: LightSource.bottomRight,
                      shadowDarkColorEmboss: OlukoColors.black,
                      shadowLightColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                      surfaceIntensity: 1,
                      shadowLightColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                      shadowDarkColor: OlukoColors.black),
                  child: IntrinsicHeight(
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            OlukoColors.black,
                            Colors.transparent,
                          ],
                        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                      },
                      blendMode: BlendMode.dstIn,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Container(
                                  width: ScreenUtils.width(context) * 0.15,
                                  color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                                  // color: Colors.blue,
                                  child: buildWatchField(
                                      valueToUse: _hourValue == _oneDayLimit.inHours
                                          ? _hourMinValue < _timeMinValue
                                              ? _timeMinValue
                                              : _hourMinValue
                                          : _hourValue,
                                      maxValue: _oneDayLimit.inHours),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: addPointsDivider(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Container(
                                    width: ScreenUtils.width(context) * 0.15,
                                    color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                                    child: buildWatchField(
                                        valueToUse: _minutesValue < _timeMinValue ? _timeMinValue : _minutesValue, maxValue: _minutesSecondsMaxValue)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: addPointsDivider(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Container(
                                  width: ScreenUtils.width(context) * 0.15,
                                  color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                                  child: buildWatchField(
                                      valueToUse: _secondsValue < _timeMinValue ? _timeMinValue : _secondsValue, maxValue: _minutesSecondsMaxValue),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              neumorphicWatchLabel(context)
            ],
          ),
        ),
      ),
    );
  }

  Container countDownWatchDefault(BuildContext context, Duration difference) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        _isTimeExpired
                            ? '00'
                            : difference.inHours.toString().length == 1
                                ? '0${difference.inHours.remainder(60)}'
                                : difference.inHours.remainder(60).toString(),
                        style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                      ),
                      _spacerWidget,
                      Text(
                        OlukoLocalizations.of(context).find('hours'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    OlukoLocalizations.of(context).find('twoDots'),
                    textAlign: TextAlign.center,
                    style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        _isTimeExpired
                            ? '00'
                            : difference.inMinutes.remainder(60).toString().length == 1
                                ? '0' + difference.inMinutes.remainder(60).toString()
                                : difference.inMinutes.remainder(60).toString(),
                        style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                      ),
                      _spacerWidget,
                      Text(
                        OlukoLocalizations.of(context).find('minute'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    OlukoLocalizations.of(context).find('twoDots'),
                    textAlign: TextAlign.center,
                    style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        _isTimeExpired
                            ? '00'
                            : difference.inSeconds.remainder(60).toString().length == 1
                                ? '0${difference.inSeconds.remainder(60)}'
                                : difference.inSeconds.remainder(60).toString(),
                        style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                      ),
                      _spacerWidget,
                      Text(
                        OlukoLocalizations.of(context).find('second'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
            child: LinearProgressIndicator(
              value: _isTimeExpired ? 1 : 1 - (difference.inHours / _oneDayLimit.inHours),
              valueColor: const AlwaysStoppedAnimation<Color>(OlukoColors.primary),
              backgroundColor: Colors.white24,
              minHeight: 5,
            ),
          )
        ],
      ),
    );
  }

  Padding neumorphicWatchLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text(
          OlukoLocalizations.of(context).find('hoursAlt'),
          textAlign: TextAlign.center,
          style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
        ),
        Text(
          OlukoLocalizations.of(context).find('minuteAlt'),
          textAlign: TextAlign.center,
          style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
        ),
        Text(
          OlukoLocalizations.of(context).find('secondAlt'),
          textAlign: TextAlign.center,
          style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
        ),
      ]),
    );
  }

  Text addPointsDivider(BuildContext context) {
    return Text(
      OlukoLocalizations.of(context).find('twoDots'),
      textAlign: TextAlign.center,
      style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
    );
  }

  NumberPicker buildWatchField({int valueToUse, int maxValue}) {
    return NumberPicker(
      maxValue: maxValue,
      minValue: 0,
      textStyle: TextStyle(color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth, fontSize: 36),
      selectedTextStyle: TextStyle(color: Colors.white, fontSize: 36),
      onChanged: (int value) {
        setState(() {
          valueToUse = value; //TODO: setting param valueToUse value? in state?
        });
      },
      value: int.parse(valueToUse.toString().padLeft(10, "0")),
    );
  }

  void startWatchCountdown() {
    _userAssessmentsCompletedAt = widget.currentUser.assessmentsCompletedAt ?? Timestamp.now();
    _now = DateTime.now();
    _difference = _now.difference(_userAssessmentsCompletedAt.toDate());

    _auction = _now.add(_oneDayLimit);

    if (_difference.inHours > 24) {
      setState(() {
        _isTimeExpired = true;
      });
    } else {
      _auction = _now.add(_oneDayLimit - _difference);
      if (_auction.isBefore(_now)) {
        _isTimeExpired = true;
      }

      _timer = Timer.periodic(
        const Duration(
          seconds: 1,
        ),
        (timer) {
          setState(() {
            _now = DateTime.now();
            //time expired
            if (_auction.isBefore(_now)) {
              _isTimeExpired = true;
              timer.cancel();
            }
          });
        },
      );
    }
  }
}
