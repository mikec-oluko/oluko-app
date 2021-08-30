import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/helpers/coach_segment_info.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/task_submission.dart';

import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/coach_tab_challenge_card.dart';
import 'package:oluko_app/ui/components/coach_tab_segment_card.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CoachPage extends StatefulWidget {
  const CoachPage();

  @override
  _CoachPageState createState() => _CoachPageState();
}

bool selected = false;
final PanelController _panelController = new PanelController();
List<Challenge> _activeChallenges = [];
List<CourseEnrollment> _courseEnrollmentList = [];
UserResponse _currentAuthUser;
List<InfoForSegments> toDoSegments = [];
List<CoachSegmentContent> actualSegmentsToDisplay = [];
List<TaskSubmission> _assessmentVideosContent = [];

class _CoachPageState extends State<CoachPage> {
  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          _currentAuthUser = state.user;

          BlocProvider.of<CourseEnrollmentBloc>(context)
              .getCourseEnrollmentsByUserId(_currentAuthUser.id);

          BlocProvider.of<CourseEnrollmentBloc>(context)
              .getChallengesForUser(_currentAuthUser.id);

          BlocProvider.of<TaskSubmissionBloc>(context)
              .getTaskSubmissionByUserId(_currentAuthUser.id);

          return coachView(radius, context);
        } else {
          return Container(
            color: OlukoColors.black,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: OlukoCircularProgressIndicator(),
          );
        }
      },
    );
  }

  Scaffold coachView(BorderRadiusGeometry radius, BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        title: "Coach Section",
        showSearchBar: false,
      ),
      body: SlidingUpPanel(
        header: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
          child: Text(
            "My Timeline",
            style: OlukoFonts.olukoBigFont(
                customColor: OlukoColors.grayColor,
                custoFontWeight: FontWeight.w500),
          ),
        ),
        borderRadius: radius,
        backdropEnabled: true,
        isDraggable: true,
        margin: const EdgeInsets.all(0),
        backdropTapClosesPanel: true,
        padding: EdgeInsets.zero,
        color: OlukoColors.black,
        minHeight: 50.0,
        maxHeight: 500,
        panel: Container(
          decoration: BoxDecoration(
            color: OlukoColors.grayColor,
            borderRadius: radius,
            gradient: LinearGradient(colors: [
              OlukoColors.grayColorFadeTop,
              OlukoColors.grayColorFadeBottom
            ], stops: [
              0.0,
              1
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          width: MediaQuery.of(context).size.width,
          height: 300,
        ),
        defaultPanelState: PanelState.CLOSED,
        controller: _panelController,
        body: Container(
          color: Colors.black,
          child: ListView(
            children: [
              Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: 300,
              ),
              userProgressComponent(context),
              Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          contentSection(title: "Mentored Videos"),
                          BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
                              builder: (context, state) {
                            if (state is GetUserTaskSubmissionSuccess) {
                              _assessmentVideosContent = state.taskSubmissions;
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        "Sent Videos",
                                        style: OlukoFonts.olukoMediumFont(
                                            customColor: OlukoColors.grayColor,
                                            custoFontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        width: 150,
                                        height: 100,
                                        color: Colors.black,
                                        child: _assessmentVideosContent
                                                    .length !=
                                                0
                                            ? ImageAndVideoContainer(
                                                backgroundImage:
                                                    _assessmentVideosContent[0]
                                                        .video
                                                        .thumbUrl,
                                                isContentVideo: true,
                                                videoUrl:
                                                    _assessmentVideosContent[0]
                                                        .video
                                                        .url,
                                                originalContent:
                                                    _assessmentVideosContent[0],
                                              )
                                            : SizedBox(),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            );
                          }),
                          contentSection(title: "Sent for Review"),
                          contentSection(title: "Recomended Videos"),
                          contentSection(title: "Voice Messages"),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Text(
                "To Do",
                style: OlukoFonts.olukoMediumFont(
                    customColor: OlukoColors.white,
                    custoFontWeight: FontWeight.w500),
              ),
              toDoSection(context),
              assessmentSection(context),
              SizedBox(
                height: 200,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget toDoSection(BuildContext context) {
    return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
      builder: (context, state) {
        if (state is GetCourseEnrollmentChallenge) {
          if (_activeChallenges.length == 0) {
            _activeChallenges = state.challenges;
          }
        }
        if (state is CourseEnrollmentListSuccess) {
          _courseEnrollmentList = state.courseEnrollmentList;
          toDoSegments = segments(_courseEnrollmentList);
          actualSegmentsToDisplay =
              createSegmentContentInforamtion(toDoSegments);
        }
        return Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            height: 120,
            child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  Wrap(children: toDoContent()
                      // children: segmentCard(
                      // actualSegmentsToDisplay: actualSegmentsToDisplay),
                      // children: challengeCard(challenges: _activeChallenges),
                      ),
                ]));
      },
    );
  }

  Container assessmentSection(BuildContext context) {
    return Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [
              Wrap(
                children: [
                  assessmentCard(),
                  assessmentCard(),
                  assessmentCard(),
                ],
              ),
            ]));
  }

  Padding assessmentCard() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: 250,
        height: 150,
        color: OlukoColors.challengesGreyBackground,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Introduce Yourself",
                    style: OlukoFonts.olukoBigFont(
                        customColor: OlukoColors.white,
                        custoFontWeight: FontWeight.w500),
                  ),
                  Image.asset(
                    'assets/assessment/check_ellipse.png',
                    scale: 4,
                  ),
                ],
              ),
              Wrap(
                children: [
                  Text(
                    "Contrary to popular belief, Lor em Ipsum is not sim ply ran...",
                    style: OlukoFonts.olukoMediumFont(
                        customColor: OlukoColors.grayColor,
                        custoFontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Public",
                    style: OlukoFonts.olukoBigFont(
                        customColor: OlukoColors.grayColor,
                        custoFontWeight: FontWeight.w500),
                  ),
                  Stack(alignment: Alignment.center, children: [
                    Image.asset(
                      'assets/assessment/green_ellipse.png',
                      scale: 4,
                    ),
                    Image.asset(
                      'assets/home/right_icon.png',
                      scale: 4,
                    )
                  ])
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Lista de challenges a widget
  challengeCard({List<Challenge> challenges}) {
    List<Widget> contentForSection = [];

    challenges.forEach((challenge) {
      contentForSection.add(returnCardForChallenge(challenge));
    });

    return contentForSection;
  }

  //Lista de segments a widget
  segmentCard({List<CoachSegmentContent> actualSegmentsToDisplay}) {
    List<Widget> contentForSection = [];

    actualSegmentsToDisplay.forEach((segment) {
      if (segment.compleatedAt == null) {
        contentForSection.add(returnCardForSegment(segment));
      }
    });

    return contentForSection;
  }

  toDoContent() {
    return challengeCard(challenges: _activeChallenges) +
        segmentCard(actualSegmentsToDisplay: actualSegmentsToDisplay);
  }

  returnCardForChallenge(Challenge upcomingChallengesContent) {
    Widget contentForReturn = SizedBox();
    contentForReturn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: CoachTabChallengeCard(challenge: upcomingChallengesContent),
    );
    return contentForReturn;
  }

  //transforma segment a segment card
  returnCardForSegment(CoachSegmentContent segment) {
    Widget contentForReturn = SizedBox();
    contentForReturn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: CoachTabSegmentCard(segment: segment),
    );
    return contentForReturn;
  }

  AnimatedContainer userProgressComponent(BuildContext context) {
    return AnimatedContainer(
      decoration: ContainerGradient.getContainerGradientDecoration(),
      width: MediaQuery.of(context).size.width,
      clipBehavior: Clip.none,
      height: selected ? 180 : 100,
      duration: const Duration(seconds: 1),
      child: Stack(
        children: [
          Positioned(top: 0, right: 0, child: SizedBox()),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                progressComponent(value: 2, title: "Classes Completed"),
                progressComponent(value: 3, title: "Challenges Completed"),
                TextButton(
                    onPressed: () {
                      setState(() {
                        selected = !selected;
                      });
                    },
                    child: selected
                        ? Icon(Icons.arrow_drop_up)
                        : Icon(Icons.arrow_drop_down)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                progressComponent(value: 5, title: "Course Completed"),
                progressComponent(
                    value: 20, title: "App Completed", needPercent: true),
                Container(
                  width: 70,
                  height: 50,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Row progressComponent({int value, String title, bool needPercent = false}) {
    return Row(
      children: [
        Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: Image.asset(
                'assets/assessment/check_ellipse.png',
                scale: 4,
              ).image,
            )),
            child: Center(
                child: Text(
              needPercent ? value.toString() + "%" : value.toString(),
              style: OlukoFonts.olukoMediumFont(
                  customColor: OlukoColors.white,
                  custoFontWeight: FontWeight.w500),
            ))),
        Container(
            width: 80,
            child: Text(
              title,
              style: OlukoFonts.olukoMediumFont(
                  customColor: OlukoColors.grayColor,
                  custoFontWeight: FontWeight.w500),
            )),
      ],
    );
  }

  Row contentSection({String title, contentForSection}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                title,
                style: OlukoFonts.olukoMediumFont(
                    customColor: OlukoColors.grayColor,
                    custoFontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                width: 150,
                height: 100,
                color: Colors.blue,
              ),
            )
          ],
        )
      ],
    );
  }

  segments(List<CourseEnrollment> courseEnrollments) {
    List<InfoForSegments> listOfSegments = [];
    String className;
    String classImage;

    courseEnrollments.forEach((courseEnrollment) {
      courseEnrollment.classes.forEach((classToCheck) {
        className = classToCheck.name;
        classImage = classToCheck.image;
        InfoForSegments infoForSegmentElement = InfoForSegments(
            classImage: classImage, className: className, segments: []);
        classToCheck.segments.forEach((segment) {
          infoForSegmentElement.segments.add(segment);
        });
        listOfSegments.add(infoForSegmentElement);
      });
    });
    return listOfSegments;
  }

  createSegmentContentInforamtion(List<InfoForSegments> segments) {
    List<CoachSegmentContent> coachSegmentContent = [];

    segments.forEach((segment) {
      segment.segments.forEach((actualSegment) {
        coachSegmentContent.add(CoachSegmentContent(
            classImage: segment.classImage,
            className: segment.className,
            segmentName: actualSegment.name,
            compleatedAt: actualSegment.compleatedAt,
            segmentReference: actualSegment.reference));
      });
    });
    return coachSegmentContent;
  }
}
