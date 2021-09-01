import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/helpers/coach_segment_info.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/ui/components/coach_tab_challenge_card.dart';
import 'package:oluko_app/ui/components/coach_tab_segment_card.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../routes.dart';

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
UserStatistics userStats;
Assessment _assessment;
List<Task> _tasks = [];

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

          requestCurrentUserData(context);

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

  void requestCurrentUserData(BuildContext context) {
    BlocProvider.of<UserStatisticsBloc>(context)
        .getUserStatistics(_currentAuthUser.id);

    BlocProvider.of<CourseEnrollmentBloc>(context)
        .getCourseEnrollmentsByUserId(_currentAuthUser.id);

    BlocProvider.of<CourseEnrollmentBloc>(context)
        .getChallengesForUser(_currentAuthUser.id);

    BlocProvider.of<TaskSubmissionBloc>(context)
        .getTaskSubmissionByUserId(_currentAuthUser.id);

    BlocProvider.of<AssessmentBloc>(context)..getById('emnsmBgZ13UBRqTS26Qd');
  }

  Scaffold coachView(BorderRadiusGeometry radius, BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: GestureDetector(
                  onTap: () {
                    //TODO: COACH PAGE
                    Navigator.pushNamed(context,
                        routeLabels[RouteEnum.profileTransformationJourney]);
                  },
                  child: Text(
                    OlukoLocalizations.of(context).find('hiCoah'),
                    style: OlukoFonts.olukoMediumFont(
                        customColor: OlukoColors.primary,
                        custoFontWeight: FontWeight.w500),
                  ),
                ),
              ),
              _currentAuthUser.avatarThumbnail != null
                  ? CircleAvatar(
                      backgroundColor: OlukoColors.black,
                      backgroundImage: Image.network(
                        _currentAuthUser.avatarThumbnail,
                        fit: BoxFit.contain,
                        frameBuilder: (BuildContext context, Widget child,
                                int frame, bool wasSynchronouslyLoaded) =>
                            ImageUtils.frameBuilder(
                                context, child, frame, wasSynchronouslyLoaded,
                                height: 24, width: 24),
                        height: 24,
                        width: 24,
                      ).image,
                      radius: 24.0,
                    )
                  : CircleAvatar(
                      backgroundColor: OlukoColors.primary,
                      radius: 24.0,
                    ),
            ],
          )
        ],
        elevation: 0.0,
        backgroundColor: OlukoColors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.popAndPushNamed(context, routeLabels[RouteEnum.root]);
          },
        ),
      ),
      body: SlidingUpPanel(
        header: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
          child: Text(
            OlukoLocalizations.of(context).find('myTimeline'),
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
          child: coachViewPageContent(context),
        ),
      ),
    );
  }

  ListView coachViewPageContent(BuildContext context) {
    return ListView(
      children: [
        cardSlider(context),
        userProgressSection(),
        carouselContentPreview(context),
        carouselToDoSection(context),
        BlocBuilder<AssessmentBloc, AssessmentState>(
          builder: (context, state) {
            if (state is AssessmentSuccess) {
              _assessment = state.assessment;
              BlocProvider.of<TaskBloc>(context)..get(_assessment);
              return assessmentSection(context);
            } else {
              return SizedBox();
            }
          },
        ),
        SizedBox(
          height: 200,
        )
      ],
    );
  }

  Container carouselToDoSection(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            OlukoLocalizations.of(context).find('toDo'),
            style: OlukoFonts.olukoMediumFont(
                customColor: OlukoColors.white,
                custoFontWeight: FontWeight.w500),
          ),
          toDoSection(context),
        ],
      ),
    );
  }

  Container carouselContentPreview(BuildContext context) {
    return Container(
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
                contentSection(
                    title:
                        OlukoLocalizations.of(context).find('mentoredVideos')),
                BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
                    builder: (context, state) {
                  if (state is GetUserTaskSubmissionSuccess) {
                    _assessmentVideosContent = state.taskSubmissions;
                  }
                  return _assessmentVideosContent.length != null
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    OlukoLocalizations.of(context)
                                        .find('sentVideos'),
                                    style: OlukoFonts.olukoMediumFont(
                                        customColor: OlukoColors.grayColor,
                                        custoFontWeight: FontWeight.w500),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context,
                                          routeLabels[RouteEnum.sentVideos],
                                          arguments: {
                                            'taskSubmissions':
                                                _assessmentVideosContent
                                          });
                                    },
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
                                              isCoach: true)
                                          : SizedBox(),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: OlukoColors.blackColorSemiTransparent,
                          ),
                          width: 150,
                          height: 100,
                          child: Center(
                            child: Text(
                              OlukoLocalizations.of(context).find('noContent'),
                              style: OlukoFonts.olukoMediumFont(
                                  customColor: OlukoColors.primary,
                                  custoFontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                }),
                contentSection(title: "Recomended Videos"),
                contentSection(title: "Voice Messages"),
              ],
            ),
          )
        ],
      ),
    );
  }

  BlocBuilder<UserStatisticsBloc, UserStatisticsState> userProgressSection() {
    return BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
        builder: (context, state) {
      if (state is StatisticsSuccess) {
        userStats = state.userStats;
      }
      return userProgressComponent(context, userStats);
    });
  }

  Container cardSlider(BuildContext context) {
    return Container(
      color: Colors.black,
      width: MediaQuery.of(context).size.width,
      height: 300,
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
                  Wrap(children: toDoContent()),
                ]));
      },
    );
  }

  assessmentSection(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskSuccess) {
          _tasks = state.values;
        }
        return Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  Wrap(children: getAssessmentCards(tasks: _tasks)),
                ]));
      },
    );
  }

  Padding assessmentCard(Task task) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: 250,
        height: 170,
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
                    task.name,
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
                    task.description,
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
                    OlukoLocalizations.of(context).find('public'),
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

  getAssessmentCards({List<Task> tasks}) {
    List<Widget> contentForSection = [];
    tasks.forEach((task) {
      contentForSection.add(assessmentCard(task));
    });
    return contentForSection;
  }

  challengeCard({List<Challenge> challenges}) {
    List<Widget> contentForSection = [];
    challenges.forEach((challenge) {
      contentForSection.add(returnCardForChallenge(challenge));
    });
    return contentForSection;
  }

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

  returnCardForSegment(CoachSegmentContent segment) {
    Widget contentForReturn = SizedBox();
    contentForReturn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: CoachTabSegmentCard(segment: segment),
    );
    return contentForReturn;
  }

  userProgressComponent(BuildContext context, UserStatistics userStats) {
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
                progressComponent(
                  value: userStats != null ? userStats.completedClasses : 0,
                  title:
                      OlukoLocalizations.of(context).find('classesCompleted'),
                ),
                progressComponent(
                    value:
                        userStats != null ? userStats.completedChallenges : 0,
                    title: OlukoLocalizations.of(context)
                        .find('challengesCompleted')),
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
                progressComponent(
                    value: userStats != null ? userStats.completedCourses : 0,
                    title: OlukoLocalizations.of(context)
                        .find('coursesCompleted')),
                progressComponent(
                    value: 0,
                    title: OlukoLocalizations.of(context).find('appCompleted'),
                    needPercent: true),
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: OlukoColors.blackColorSemiTransparent,
                ),
                width: 150,
                height: 100,
                child: Center(
                  child: Text(
                    OlukoLocalizations.of(context).find('noContent'),
                    style: OlukoFonts.olukoMediumFont(
                        customColor: OlukoColors.primary,
                        custoFontWeight: FontWeight.w500),
                  ),
                ),
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
