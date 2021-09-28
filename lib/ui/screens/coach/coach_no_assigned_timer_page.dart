import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

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
  Timestamp _userCreatedDate;
  bool _isTimeExpired = false;
  final Duration _oneDayLimit = const Duration(days: 1);
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
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final difference = _auction.difference(_now);
    return Scaffold(
      appBar: OlukoAppBar(
        title: OlukoLocalizations.of(context).find('coach'),
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
                        OlukoLocalizations.of(context).find('hey'),
                        style:
                            OlukoFonts.olukoBigFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        OlukoLocalizations.of(context).find('coachText'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoMediumFont(
                            customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500),
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
          style: OlukoFonts.olukoBiggestFont(customColor: OlukoColors.error, custoFontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Container countDownWatch(BuildContext context, Duration difference) {
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
                        _isTimeExpired ? '00' : difference.inHours.toString(),
                        style: OlukoFonts.olukoBiggestFont(
                            customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                      ),
                      _spacerWidget,
                      Text(
                        OlukoLocalizations.of(context).find('hours'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoMediumFont(
                            customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    OlukoLocalizations.of(context).find('twoDots'),
                    textAlign: TextAlign.center,
                    style:
                        OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        _isTimeExpired ? '00' : difference.inMinutes.remainder(60).toString(),
                        style: OlukoFonts.olukoBiggestFont(
                            customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                      ),
                      _spacerWidget,
                      Text(
                        OlukoLocalizations.of(context).find('minute'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoMediumFont(
                            customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    OlukoLocalizations.of(context).find('twoDots'),
                    textAlign: TextAlign.center,
                    style:
                        OlukoFonts.olukoBiggestFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        _isTimeExpired ? '00' : difference.inSeconds.remainder(60).toString() ,
                        style: OlukoFonts.olukoBiggestFont(
                            customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                      ),
                      _spacerWidget,
                      Text(
                        OlukoLocalizations.of(context).find('second'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoMediumFont(
                            customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
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

  void startWatchCountdown() {
    _userCreatedDate = widget.currentUser.createdAt;
    _now = DateTime.now();
    _difference = _now.difference(_userCreatedDate.toDate());

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
