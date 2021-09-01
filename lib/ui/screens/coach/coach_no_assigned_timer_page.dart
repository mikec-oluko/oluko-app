import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachAssignedCountDown extends StatefulWidget {
  const CoachAssignedCountDown();

  @override
  _CoachAssignedCountDownState createState() => _CoachAssignedCountDownState();
}

class _CoachAssignedCountDownState extends State<CoachAssignedCountDown> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(title: OlukoLocalizations.of(context).find('coach')),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: OlukoColors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/courses/green_circle.png',
                      color: Colors.white,
                      height: 100,
                      width: 100,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Text(
                        "Hey!",
                        style: OlukoFonts.olukoBigFont(
                            customColor: OlukoColors.white,
                            custoFontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Text(
                        "Your coach will be assigning soon. We will notify when the coach is assigned.",
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoMediumFont(
                            customColor: OlukoColors.grayColor,
                            custoFontWeight: FontWeight.w500),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Text(
                            "08",
                            style: OlukoFonts.olukoBiggestFont(
                                customColor: OlukoColors.white,
                                custoFontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Hour(s)",
                            textAlign: TextAlign.center,
                            style: OlukoFonts.olukoMediumFont(
                                customColor: OlukoColors.grayColor,
                                custoFontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Text(
                            "38",
                            style: OlukoFonts.olukoBiggestFont(
                                customColor: OlukoColors.white,
                                custoFontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Minute(s)",
                            textAlign: TextAlign.center,
                            style: OlukoFonts.olukoMediumFont(
                                customColor: OlukoColors.grayColor,
                                custoFontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Text(
                            "46",
                            style: OlukoFonts.olukoBiggestFont(
                                customColor: OlukoColors.white,
                                custoFontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Second(s)",
                            textAlign: TextAlign.center,
                            style: OlukoFonts.olukoMediumFont(
                                customColor: OlukoColors.grayColor,
                                custoFontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
