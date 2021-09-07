import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/helpers/coach_segment_info.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/ui/components/coach_app_bar.dart';
import 'package:oluko_app/ui/components/coach_carousel_section.dart';
import 'package:oluko_app/ui/components/coach_content_preview_content.dart';
import 'package:oluko_app/ui/components/coach_content_section_card.dart';
import 'package:oluko_app/ui/components/coach_horizontal_carousel_component.dart';
import 'package:oluko_app/ui/components/coach_sliding_up_panel.dart';
import 'package:oluko_app/ui/components/coach_user_progress_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachPage extends StatefulWidget {
  const CoachPage();

  @override
  _CoachPageState createState() => _CoachPageState();
}

List<Challenge> _activeChallenges = [];
List<CourseEnrollment> _courseEnrollmentList = [];
UserResponse _currentAuthUser;
List<InfoForSegments> _toDoSegments = [];
List<CoachSegmentContent> actualSegmentsToDisplay = [];
List<TaskSubmission> _assessmentVideosContent = [];
UserStatistics _userStats;
Assessment _assessment;
List<Task> _tasks = [];
ChewieController _controller;

class _CoachPageState extends State<CoachPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          _currentAuthUser = state.user;
          requestCurrentUserData(context);
          return Scaffold(
            appBar: CoachAppBar(
              coachUser: _currentAuthUser,
            ),
            body: CoachSlidingUpPanel(content: coachViewPageContent(context)),
          );
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

    BlocProvider.of<CourseEnrollmentListBloc>(context)
        .getCourseEnrollmentsByUserId(_currentAuthUser.id);

    BlocProvider.of<CourseEnrollmentBloc>(context)
        .getChallengesForUser(_currentAuthUser.id);

    BlocProvider.of<TaskSubmissionBloc>(context)
        .getTaskSubmissionByUserId(_currentAuthUser.id);

    BlocProvider.of<AssessmentBloc>(context)..getById('emnsmBgZ13UBRqTS26Qd');
  }

  coachViewPageContent(BuildContext context) {
    return BlocBuilder<AssessmentBloc, AssessmentState>(
      builder: (context, state) {
        if (state is AssessmentSuccess) {
          _assessment = state.assessment;
          BlocProvider.of<TaskBloc>(context)..get(_assessment);
          return ListView(
            children: [
              CoachCarouselSliderSection(
                  contentForCarousel: listOfContentForUser(true)),
              userProgressSection(),
              CoachHorizontalCarousel(
                  contentToDisplay: listOfContentForUser(false),
                  isForVideoContent: true),
              carouselToDoSection(context),
              assessmentSection(context),
              SizedBox(
                height: 200,
              )
            ],
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  BlocBuilder<UserStatisticsBloc, UserStatisticsState> userProgressSection() {
    return BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
        builder: (context, state) {
      if (state is StatisticsSuccess) {
        _userStats = state.userStats;
      }
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CoachUserProgressCard(
            userStats: _userStats,
          ));
    });
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

  Widget toDoSection(BuildContext context) {
    return BlocBuilder<CourseEnrollmentListBloc, CourseEnrollmentListState>(
      builder: (context, state) {
        if (state is CourseEnrollmentsByUserSuccess) {
          _courseEnrollmentList = state.courseEnrollments;
          _toDoSegments =
              TransformListOfItemsToWidget.segments(_courseEnrollmentList);
          actualSegmentsToDisplay =
              TransformListOfItemsToWidget.createSegmentContentInforamtion(
                  _toDoSegments);
        }
        return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
          builder: (context, state) {
            if (state is GetCourseEnrollmentChallenge) {
              if (_activeChallenges.length == 0) {
                _activeChallenges = state.challenges;
              }
            }
            return CoachHorizontalCarousel(contentToDisplay: toDoContent());
          },
        );
      },
    );
  }

  toDoContent() => TransformListOfItemsToWidget.coachChallengesAndSegments(
      challenges: _activeChallenges, segments: actualSegmentsToDisplay);

  assessmentSection(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskSuccess) {
          _tasks = state.values;
        }
        return CoachHorizontalCarousel(
          contentToDisplay: TransformListOfItemsToWidget.getAssessmentCards(
              tasks: _tasks, tasksSubmitted: _assessmentVideosContent),
          isAssessmentContent: true,
        );
      },
    );
  }

  listOfContentForUser(bool carousel) {
    if (carousel) {
      return [
        mentoredVideos(carousel),
        sentVideos(carousel),
        CoachContentSectionCard(
            title: "Recomended Videos", isForCarousel: carousel),
        CoachContentSectionCard(
            title: "Voice Messages", isForCarousel: carousel),
      ];
    }
    return [
      mentoredVideos(carousel),
      SizedBox(
        width: 5,
      ),
      sentVideos(carousel),
      SizedBox(
        width: 5,
      ),
      CoachContentSectionCard(
          title: "Recomended Videos", isForCarousel: carousel),
      SizedBox(
        width: 5,
      ),
      CoachContentSectionCard(title: "Voice Messages", isForCarousel: carousel),
    ];
  }

  BlocBuilder<TaskSubmissionBloc, TaskSubmissionState> sentVideos(
      bool isForCarousel) {
    return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
        builder: (context, state) {
      if (state is GetUserTaskSubmissionSuccess) {
        // _assessmentVideosContent = [];
        _assessmentVideosContent = state.taskSubmissions;
      }
      return _assessmentVideosContent.length != null &&
              _assessmentVideosContent.length != 0
          ? CoachContentPreviewContent(
              contentFor: CoachContentSection.sentVideos,
              titleForSection:
                  OlukoLocalizations.of(context).find('sentVideos'),
              videoContent: _assessmentVideosContent,
              isForCarousel: isForCarousel)
          : CoachContentSectionCard(
              title: OlukoLocalizations.of(context).find('sentVideos'),
              isForCarousel: isForCarousel,
              needTitle: false);
    });
  }

  BlocBuilder<TaskSubmissionBloc, TaskSubmissionState> mentoredVideos(
      bool isForCarousel) {
    return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
        builder: (context, state) {
      if (state is GetUserTaskSubmissionSuccess) {
        // _assessmentVideosContent = [];
        _assessmentVideosContent = state.taskSubmissions;
      }
      return _assessmentVideosContent.length != null &&
              _assessmentVideosContent.length != 0
          ? CoachContentPreviewContent(
              contentFor: CoachContentSection.mentoredVideos,
              titleForSection:
                  OlukoLocalizations.of(context).find('mentoredVideos'),
              videoContent: _assessmentVideosContent,
              isForCarousel: isForCarousel)
          : CoachContentSectionCard(
              title: OlukoLocalizations.of(context).find('mentoredVideos'),
              isForCarousel: isForCarousel,
              needTitle: false);
    });
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ScreenUtils.height(context) / 4
                    : ScreenUtils.height(context) / 1.5,
            minHeight:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ScreenUtils.height(context) / 4
                    : ScreenUtils.height(context) / 1.5),
        child: Container(height: 400, child: Stack(children: widgets)));
  }
}
