import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class FeedbackCard extends StatefulWidget {
  FeedbackCard();

  @override
  _State createState() => _State();
}

class _State extends State<FeedbackCard> {
  List<Movement> segmentMovements;
  bool like = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign ? neumorphicFeedBackCard(context) : feedBackCard(context);
  }

  Container feedBackCard(BuildContext context) {
    return Container(
      height: 145,
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoColors.listGrayColor),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                OlukoLocalizations.get(context, 'howWasYourWorkoutSession'),
                style: OlukoFonts.olukoBigFont(),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        like = true;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          like
                              ? Image.asset(
                                  'assets/courses/like-painted.png',
                                  scale: 4,
                                )
                              : Image.asset(
                                  'assets/courses/like.png',
                                  scale: 5,
                                ),
                        ],
                      ),
                    )),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        like = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          like
                              ? Image.asset(
                                  'assets/courses/dislike.png',
                                  scale: 5,
                                )
                              : Image.asset(
                                  'assets/courses/dislike-painted.png',
                                  scale: 4,
                                ),
                        ],
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Container neumorphicFeedBackCard(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                OlukoLocalizations.get(context, 'howWasYourWorkoutSession'),
                style: OlukoFonts.olukoBigFont(),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        like = true;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Neumorphic(
                            style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
                            child: Column(
                              children: [
                                like
                                    ? Image.asset(
                                        'assets/courses/like-painted.png',
                                        scale: 5,
                                      )
                                    : Image.asset(
                                        'assets/courses/like.png',
                                        scale: 6,
                                      ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              OlukoLocalizations.get(context, 'workoutGoodFeedback'),
                              style: OlukoFonts.olukoMediumFont(customColor: like ? OlukoColors.primary : OlukoColors.grayColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        like = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Neumorphic(
                            style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
                            child: Column(
                              children: [
                                like
                                    ? Image.asset(
                                        'assets/courses/dislike.png',
                                        scale: 6,
                                      )
                                    : Image.asset(
                                        'assets/courses/dislike-painted.png',
                                        scale: 5,
                                      ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              OlukoLocalizations.get(context, 'workoutBadFeedback'),
                              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
