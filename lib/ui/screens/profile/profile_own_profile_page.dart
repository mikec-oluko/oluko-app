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
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/sign_up_response.dart';
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
  List<dynamic> _assessmentVideosContent = [];
  List<Challenge> _activeChallenges = [];
  List<Content> _listOfContent = [];
  List<Course> _coursesToUse = [];

  @override
  void initState() {
    setState(() {
      _listOfContent = uploadListContent;
    });
    BlocProvider.of<CourseBloc>(context).get();
    super.initState();
  }

  @override
  void dispose() {
    setState(() {
      _assessmentVideosContent = [];
      _transformationJourneyContent = [];
      _activeChallenges = [];
      _listOfContent = [];
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
    _requestCourseEnrollmentChallengesData(context, profileInfo);
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
          if (state is GetUserTaskSubmissionSuccess) {
            _assessmentVideosContent = state.taskSubmissions;
          }
        },
        child: buildUserContentSection(
            titleForSection:
                ProfileViewConstants.profileOptionsAssessmentVideos,
            routeForSection: ProfileRoutes.goToAssessmentVideos(),
            contentForSection:
                mapContentToWidget(staticContent: _listOfContent)));
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
          contentForSection: mapContentToWidget(staticContent: _listOfContent)),
    );
  }

  BlocConsumer<CourseBloc, CourseState> _buildCourseSectionView() {
    //TODO: USE COURSES FROM COURSEENROLLMENTS
    return BlocConsumer<CourseBloc, CourseState>(
      listener: (context, state) {
        if (state is CourseSuccess) {
          _coursesToUse = state.values;
        }
      },
      builder: (context, state) {
        return buildCourseSection(
            context: context,
            contentForCourse: returnCoursesWidget(_coursesToUse));
      },
    );
  }

  _buildChallengeSection() {
    return BlocListener<CourseEnrollmentBloc, CourseEnrollmentState>(
      listener: (context, state) {
        if (state is CourseEnrollmentGetChallenge) {
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
        .getContentById(profileInfo.id);
  }

  void _requestCourseEnrollmentChallengesData(
      BuildContext context, UserResponse profileInfo) {
    BlocProvider.of<CourseEnrollmentBloc>(context)
        .getChallengesForUser(profileInfo.id);
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

  Widget _getCourseCard(Course courseForCard) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: CourseCard(
        width: 120,
        height: 120,
        imageCover: Image.network((courseForCard.imageUrl)),
        progress: 0.4,
      ),
    );
  }

  Widget _getImageAndVideoCard(
      {Content contentFromUser, TransformationJourneyUpload uploadFromUser}) {
    Widget contentForReturn;
    if (contentFromUser != null) {
      contentForReturn = ImageAndVideoContainer(
        assetImage: contentFromUser.imgUrl,
        isVideo: contentFromUser.isVideo,
      );
    }
    if (uploadFromUser != null) {
      contentForReturn = ImageAndVideoContainer(
        assetImage: uploadFromUser.thumbnail,
        isVideo: uploadFromUser.type == FileTypeEnum.video,
      );
    }

    return contentForReturn;
  }

  List<Widget> returnCoursesWidget(List<Course> listOfCourses) {
    List<Widget> contentForCourseSection = [];
    listOfCourses.forEach((course) {
      contentForCourseSection.add(_getCourseCard(course));
    });
    return contentForCourseSection.toList();
  }

  List<Widget> mapContentToWidget(
      {List<Content> staticContent,
      List<TransformationJourneyUpload> tansformationJourneyData}) {
    List<Widget> contentForSection = [];
    if (staticContent != null) {
      staticContent.forEach((content) {
        contentForSection.add(_getImageAndVideoCard(contentFromUser: content));
      });
    }
    if (tansformationJourneyData != null) {
      tansformationJourneyData.forEach((content) {
        contentForSection.add(_getImageAndVideoCard(uploadFromUser: content));
      });
    }

    return contentForSection.toList();
  }
}
