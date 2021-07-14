import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/ui/screens/profile/profile_routes.dart';

class ProfileOwnProfilePage extends StatefulWidget {
  @override
  _ProfileOwnProfilePageState createState() => _ProfileOwnProfilePageState();
}

class _ProfileOwnProfilePageState extends State<ProfileOwnProfilePage> {
  UserResponse _profileInfo;
  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  List<TaskSubmission> _assessmentVideosContent = [];
  List<Challenge> _activeChallenges = [];
  List<CourseEnrollment> _coursesToUse = [];
  List<Content> _listOfStaticContent = [];

  @override
  void initState() {
    setState(() {
      _listOfStaticContent = uploadListContent;
    });
    //TODO: Use CourseEnrollments to display courses data.
    BlocProvider.of<CourseBloc>(context).get();
    super.initState();
  }

  @override
  void dispose() {
    setState(() {
      _transformationJourneyContent = [];
      _assessmentVideosContent = [];
      _activeChallenges = [];
      _listOfStaticContent = [];
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getProfileInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildOwnProfileView(context, _profileInfo);
          } else {
            return SizedBox();
          }
        });
  }

  _buildOwnProfileView(BuildContext context, UserResponse profileInfo) {
    _requestTransformationJourneyData(context, profileInfo);
    // _requestCourseEnrollmentChallengesData(context, profileInfo);
    // _requestCourseEnrollmentListForUser(context, profileInfo);
    return Scaffold(
      body: Container(
        color: OlukoColors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Flexible(
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
          // if (state is GetUserTaskSubmissionSuccess) {
          //   _assessmentVideosContent = state.taskSubmissions;
          // }
        },
        child: buildUserContentSection(
            titleForSection:
                ProfileViewConstants.profileOptionsAssessmentVideos,
            routeForSection: ProfileRoutes.goToAssessmentVideos(),
            contentForSection:
                mapContentToWidget(staticContent: _listOfStaticContent)));
  }

  BlocListener<TransformationJourneyBloc, TransformationJourneyState>
      _buildTransformationJourneySection() {
    return BlocListener<TransformationJourneyBloc, TransformationJourneyState>(
      listener: (context, state) {
        if (state is TransformationJourneySuccess) {
          _transformationJourneyContent = state.contentFromUser;
        }
      },
      //TODO: Use transformationJourneyContent
      child: buildUserContentSection(
          titleForSection:
              ProfileViewConstants.profileOptionsTransformationJourney,
          routeForSection: ProfileRoutes.goToTransformationJourney(),
          contentForSection:
              mapContentToWidget(staticContent: _listOfStaticContent)),
    );
  }

  BlocConsumer<CourseEnrollmentBloc, CourseEnrollmentState>
      _buildCourseSectionView() {
    return BlocConsumer<CourseEnrollmentBloc, CourseEnrollmentState>(
      listener: (context, state) {
        if (state is CourseEnrollmentListSuccess) {
          _coursesToUse = state.courseEnrollmentList;
        }
      },
      builder: (context, state) {
        return buildCourseSection(
            context: context,
            contentForCourse:
                returnCoursesWidget(listOfCourses: _coursesToUse));
      },
    );
  }

  _buildChallengeSection() {
    return BlocListener<CourseEnrollmentBloc, CourseEnrollmentState>(
      listener: (context, state) {
        if (state is GetCourseEnrollmentChallenge) {
          _activeChallenges = state.challenges;
        }
      },
      child: Padding(
          padding: const EdgeInsets.all(10.0).copyWith(top: 0),
          child: ChallengesCard(
            challenge: _activeChallenges.length != 0
                ? _activeChallenges[0]
                : challengeDefault,
            routeToGo: ProfileRoutes.goToChallenges(),
          )),
    );
  }

  Future<void> _getProfileInfo() async {
    _profileInfo =
        UserResponse.fromJson((await AuthBloc().retrieveLoginData()).toJson());
    return _profileInfo;
  }

  void _requestTransformationJourneyData(
      BuildContext context, UserResponse profileInfo) {
    BlocProvider.of<TransformationJourneyBloc>(context)
        .getContentByUserName(profileInfo.username);
  }

  void _requestCourseEnrollmentChallengesData(
      BuildContext context, UserResponse profileInfo) {
    BlocProvider.of<CourseEnrollmentBloc>(context)
        .getChallengesForUser(profileInfo.id);
  }

  void _requestCourseEnrollmentListForUser(
      BuildContext context, UserResponse profileInfo) {
    BlocProvider.of<CourseEnrollmentBloc>(context)
        .getCourseEnrollmentsByUserId(profileInfo.id);
  }

  Padding buildCourseSection(
      {BuildContext context, List<Widget> contentForCourse}) {
    return Padding(
      padding: const EdgeInsets.all(10.0).copyWith(bottom: 0),
      child: CarouselSection(
        height: 250,
        width: MediaQuery.of(context).size.width,
        title: ProfileViewConstants.profileOwnProfileActiveCourses,
        children: contentForCourse,
      ),
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
          children: contentForSection),
    );
  }

  Widget _getCourseCard({CourseEnrollment courseForCard, Course staticCourse}) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: CourseCard(
        width: 120,
        height: 120,
        //TODO: Use CourseEnrollment -> Course
        imageCover: Image.network((staticCourse.imageUrl)),
        progress: 0.4,
      ),
    );
  }

  Widget _getImageAndVideoCard(
      {Content staticContent,
      TransformationJourneyUpload transformationJourneyContent,
      TaskSubmission taskSubmissionContent}) {
    Widget contentForReturn;
    if (staticContent != null) {
      contentForReturn = ImageAndVideoContainer(
        assetImage: staticContent.imgUrl,
        isVideo: staticContent.isVideo,
        videoUrl:
            'https://oluko-mvt.s3.us-west-1.amazonaws.com/assessments/85b2f81c1fe74f9cb5e804c57db30137/85b2f81c1fe74f9cb5e804c57db30137_2.mp4',
      );
    }
    if (transformationJourneyContent != null) {
      contentForReturn = ImageAndVideoContainer(
        assetImage: transformationJourneyContent.thumbnail,
        isVideo: transformationJourneyContent.type == FileTypeEnum.video,
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

  List<Widget> returnCoursesWidget({List<CourseEnrollment> listOfCourses}) {
    //TODO: Use CourseEnrollment
    List<Widget> contentForCourseSection = [];
    listOfCourses.forEach((course) {
      contentForCourseSection.add(_getCourseCard(courseForCard: course));
    });
    return contentForCourseSection.toList();
  }

  List<Widget> mapContentToWidget(
      {List<Content> staticContent,
      List<TransformationJourneyUpload> tansformationJourneyData,
      List<TaskSubmission> assessmentVideoData}) {
    List<Widget> contentForSection = [];

    if (staticContent != null &&
        tansformationJourneyData != null &&
        (tansformationJourneyData.isEmpty && assessmentVideoData.isEmpty)) {
      staticContent.forEach((content) {
        contentForSection.add(_getImageAndVideoCard(staticContent: content));
      });
    }
    if (tansformationJourneyData != null &&
        (staticContent == null && assessmentVideoData == null)) {
      tansformationJourneyData.forEach((content) {
        contentForSection
            .add(_getImageAndVideoCard(transformationJourneyContent: content));
      });
    }
    if (assessmentVideoData != null &&
        (tansformationJourneyData.isEmpty && staticContent.isEmpty)) {
      assessmentVideoData.forEach((content) {
        contentForSection
            .add(_getImageAndVideoCard(taskSubmissionContent: content));
      });
    }

    return contentForSection.toList();
  }
}
