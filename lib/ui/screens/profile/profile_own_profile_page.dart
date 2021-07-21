import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/ui/screens/profile/profile_routes.dart';
import 'package:oluko_app/utils/image_utils.dart';

class ProfileOwnProfilePage extends StatefulWidget {
  @override
  _ProfileOwnProfilePageState createState() => _ProfileOwnProfilePageState();
}

class _ProfileOwnProfilePageState extends State<ProfileOwnProfilePage> {
  UserResponse _profileInfo;
  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  List<TaskSubmission> _assessmentVideosContent = [];
  List<Challenge> _activeChallenges = [];
  List<Course> _coursesToUse = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getProfileInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _requestViewData(context, _profileInfo);
            return _buildOwnProfileView(context, _profileInfo);
          } else {
            return SizedBox();
          }
        });
  }

  void _requestViewData(BuildContext context, UserResponse profileInfo) {
    //TODO: Call once to get courseEnrollments List

    // BlocProvider.of<CourseEnrollmentBloc>(context)
    // .getCourseEnrollmentsByUserId(profileInfo.id);

    BlocProvider.of<CourseEnrollmentBloc>(context)
        .getChallengesForUser(profileInfo.id);

    BlocProvider.of<CourseEnrollmentBloc>(context)
        .getCourseEnrollmentsCoursesByUserId(profileInfo.id);

    BlocProvider.of<TransformationJourneyBloc>(context)
        .getContentByUserName(profileInfo.username);

    //TODO: Get content when save is ok
    // BlocProvider.of<TaskSubmissionBloc>(context)
    //     .getTaskSubmissionByUserId(profileInfo.id);
  }

  _buildOwnProfileView(BuildContext context, UserResponse profileInfo) {
    return Scaffold(
      body: Container(
        color: OlukoColors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              ListTile(
                leading: Transform.translate(
                  offset: Offset(-20, 0),
                  child: IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      size: 35,
                      color: OlukoColors.white,
                    ),
                    //TODO: PUSHNAMED
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                title: Transform.translate(
                    offset: Offset(-40, 0),
                    child:
                        UserProfileInformation(userInformation: profileInfo)),
              ),
              _challengesAndFriendsSection(
                  ProfileViewConstants.profileChallengesContent,
                  ProfileViewConstants.profileFriendsContent),
              _buildAssessmentVideosSection(),
              _buildTransformationJourneySection(),
              _buildCourseSectionView(),
              _buildChallengeSection()
            ]),
          ),
        ),
      ),
    );
  }

  UserProfileProgress _challengesAndFriendsSection(
      String userChallenges, String userFriends) {
    return UserProfileProgress(
        userChallenges: userChallenges, userFriends: userFriends);
  }

  _buildAssessmentVideosSection() {
    return BlocListener<TaskSubmissionBloc, TaskSubmissionState>(
        listener: (context, state) {
          if (state is GetUserTaskSubmissionSuccess) {
            _assessmentVideosContent = state.taskSubmissions;
          }
        },
        child: buildUserContentSection(
            titleForSection:
                ProfileViewConstants.profileOptionsAssessmentVideos,
            routeForSection: ProfileRoutes.goToAssessmentVideos(),
            contentForSection: mapContentToWidget(
                assessmentVideoData: _assessmentVideosContent)));
  }

  BlocBuilder<TransformationJourneyBloc, TransformationJourneyState>
      _buildTransformationJourneySection() {
    return BlocBuilder<TransformationJourneyBloc, TransformationJourneyState>(
      builder: (context, state) {
        if (state is TransformationJourneySuccess) {
          _transformationJourneyContent = state.contentFromUser;
        }
        return buildUserContentSection(
            titleForSection:
                ProfileViewConstants.profileOptionsTransformationJourney,
            routeForSection: ProfileRoutes.goToTransformationJourney(),
            contentForSection: mapContentToWidget(
                tansformationJourneyData: _transformationJourneyContent));
      },
    );
  }

  BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>
      _buildCourseSectionView() {
    return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
      builder: (context, state) {
        if (state is CourseEnrollmentCourses) {
          if (_coursesToUse.length == 0) {
            _coursesToUse = state.courseEnrollmentCourses;
          }
        }
        return buildCourseSection(
            context: context,
            contentForCourse:
                returnCoursesWidget(listOfCourses: _coursesToUse));
      },
    );
  }

  _buildChallengeSection() {
    Widget returnWidget = OlukoCircularProgressIndicator();
    return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
      builder: (context, state) {
        if (state is GetCourseEnrollmentChallenge) {
          if (_activeChallenges.length == 0) {
            _activeChallenges = state.challenges;
          }
        }
        if (_activeChallenges.length != 0) {
          returnWidget = Padding(
              padding: const EdgeInsets.all(10.0).copyWith(top: 0),
              child: ChallengesCard(
                challenge: _activeChallenges[0],
                routeToGo: ProfileRoutes.goToChallenges(),
              ));
        }
        return returnWidget;
      },
    );
  }

  Future<void> _getProfileInfo() async {
    _profileInfo =
        UserResponse.fromJson((await AuthBloc().retrieveLoginData()).toJson());
    return _profileInfo;
  }

  Padding buildCourseSection(
      {BuildContext context, List<Widget> contentForCourse}) {
    return Padding(
      padding: const EdgeInsets.all(10.0).copyWith(bottom: 0),
      child: CarouselSection(
          height: 250,
          width: MediaQuery.of(context).size.width,
          title: ProfileViewConstants.profileOwnProfileActiveCourses,
          children: contentForCourse.length != 0
              ? contentForCourse
              : [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150),
                    child: OlukoCircularProgressIndicator(),
                  )
                ]),
    );
  }

  Padding buildUserContentSection(
      {String routeForSection,
      String titleForSection,
      List<Widget> contentForSection}) {
    return Padding(
        padding: const EdgeInsets.only(top: 25),
        child: CarouselSmallSection(
            routeToGo: routeForSection,
            title: titleForSection,
            children: contentForSection.length != 0
                ? contentForSection
                : [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 150),
                      child: OlukoCircularProgressIndicator(),
                    )
                  ]));
  }

  Widget _getCourseCard({Course courseInfo}) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: CourseCard(
        width: 120,
        height: 120,
        imageCover: Image.network(
          courseInfo.imageUrl,
          frameBuilder: (BuildContext context, Widget child, int frame,
                  bool wasSynchronouslyLoaded) =>
              ImageUtils.frameBuilder(
                  context, child, frame, wasSynchronouslyLoaded,
                  height: 120, width: 120),
        ),
        progress: 0.4,
      ),
    );
  }

  Widget _getImageAndVideoCard(
      {TransformationJourneyUpload transformationJourneyContent,
      TaskSubmission taskSubmissionContent}) {
    Widget contentForReturn;
    if (transformationJourneyContent != null) {
      contentForReturn = ImageAndVideoContainer(
        assetImage: transformationJourneyContent.thumbnail,
        isVideo: transformationJourneyContent.type == FileTypeEnum.video
            ? true
            : false,
        videoUrl: transformationJourneyContent.file,
      );
    }
    if (taskSubmissionContent != null) {
      contentForReturn = ImageAndVideoContainer(
        assetImage: taskSubmissionContent.video.thumbUrl,
        isVideo: taskSubmissionContent.video != null,
        videoUrl: taskSubmissionContent.video.url,
      );
    }

    return contentForReturn;
  }

  List<Widget> returnCoursesWidget({List<Course> listOfCourses}) {
    List<Widget> contentForCourseSection = [];
    listOfCourses.forEach((course) {
      contentForCourseSection.add(_getCourseCard(courseInfo: course));
    });
    return contentForCourseSection.toList();
  }

  List<Widget> mapContentToWidget(
      {List<TransformationJourneyUpload> tansformationJourneyData,
      List<TaskSubmission> assessmentVideoData}) {
    List<Widget> contentForSection = [];

    if (tansformationJourneyData != null && (assessmentVideoData == null)) {
      tansformationJourneyData.forEach((content) {
        contentForSection
            .add(_getImageAndVideoCard(transformationJourneyContent: content));
      });
    }
    if (assessmentVideoData != null && (tansformationJourneyData == null)) {
      assessmentVideoData.forEach((content) {
        contentForSection
            .add(_getImageAndVideoCard(taskSubmissionContent: content));
      });
    }

    return contentForSection.toList();
  }
}
