import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/feedback_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class FeedbackCard extends StatefulWidget {
  CourseEnrollment courseEnrollment;
  int classIndex;
  int segmentIndex;
  String segmentId;
  FeedbackCard(this.courseEnrollment, this.classIndex, this.segmentIndex, this.segmentId);
  @override
  _State createState() => _State();
}

class _State extends State<FeedbackCard> {
  List<Movement> segmentMovements;
  bool like = false;
  bool dislike = false;
  bool updateFeedback = false;
  bool isProcessingLike = false;

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
                OlukoLocalizations.get(context, 'howWasYourWorkout'),
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

  void setFeedback() async {
    if (updateFeedback) {
      await BlocProvider.of<FeedbackBloc>(context).update(widget.courseEnrollment, widget.classIndex, widget.segmentIndex, widget.segmentId, like);
    } else if (like) {
      await BlocProvider.of<FeedbackBloc>(context).like(widget.courseEnrollment, widget.classIndex, widget.segmentIndex, widget.segmentId);
    } else {
      await BlocProvider.of<FeedbackBloc>(context).dislike(widget.courseEnrollment, widget.classIndex, widget.segmentIndex, widget.segmentId);
    }
    updateFeedback = true;
    isProcessingLike = false;
  }

  Container neumorphicFeedBackCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight),
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
                OlukoLocalizations.get(context, 'howWasYourWorkout'),
                style: OlukoFonts.olukoBigFont(),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      if (!isProcessingLike) {
                        isProcessingLike = true;
                        setState(() {
                          like = true;
                          dislike = false;
                        });
                        setFeedback();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Neumorphic(
                            style: OlukoNeumorphism.getNeumorphicStyleForCircleElementNegativeDepth().copyWith(lightSource: LightSource.bottom, intensity: 1),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  like
                                      ? Image.asset(
                                          'assets/icon/heart_filled.png',
                                          scale: 3,
                                        )
                                      : Image.asset(
                                          'assets/icon/heart.png',
                                          scale: 3,
                                        ),
                                ],
                              ),
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
                      if (!isProcessingLike) {
                        isProcessingLike = true;
                        setState(() {
                          like = false;
                          dislike = true;
                        });
                        setFeedback();
                      }
                    },
                    child: Column(
                      children: [
                        Neumorphic(
                          style: OlukoNeumorphism.getNeumorphicStyleForCircleElementNegativeDepth().copyWith(lightSource: LightSource.bottom, intensity: 1),
                          child: Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Column(
                              children: [
                                dislike
                                    ? Image.asset(
                                        'assets/courses/filled_dislike.png',
                                        scale: 3,
                                      )
                                    : Image.asset(
                                        'assets/courses/outlined_dislike.png',
                                        scale: 4,
                                      ),
                              ],
                            ),
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
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
