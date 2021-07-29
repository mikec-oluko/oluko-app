import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/blocs/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
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
import 'package:oluko_app/ui/components/modal_upload_options.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/ui/screens/profile/profile_routes.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class UserProfilePage extends StatefulWidget {
  final UserResponse userRequested;
  UserProfilePage({this.userRequested});
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserResponse _currentAuthUser;
  UserResponse _userProfileToDisplay;
  bool _isCurrentUser = false;
  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  List<TaskSubmission> _assessmentVideosContent = [];
  List<Challenge> _activeChallenges = [];
  List<Course> _coursesToUse = [];

  @override
  void initState() {
    setState(() {
      _isCurrentUser = widget.userRequested == null ? true : false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      _userProfileToDisplay = widget.userRequested;

      if (state is AuthSuccess) {
        this._currentAuthUser = state.user;

        if (!_isOwnerProfile(
            authUser: this._currentAuthUser,
            userRequested: widget.userRequested)) {
          _userProfileToDisplay = this._currentAuthUser;
          _isCurrentUser = true;
          _requestContentForUser(
              context: context, userRequested: _userProfileToDisplay);
        }

        return _buildUserProfileView(
            context: context,
            authUser: _currentAuthUser,
            userRequested: widget.userRequested,
            isOwnProfile: _isCurrentUser);
      } else {
        return Container(
          color: OlukoColors.black,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: OlukoCircularProgressIndicator(),
        );
      }
    });
  }

  bool _isOwnerProfile(
      {@required UserResponse authUser, @required UserResponse userRequested}) {
    if (userRequested == null) {
      _isCurrentUser = false;
      return false;
    }
    return authUser.id == userRequested.id;
  }

  _buildUserProfileView(
      {BuildContext context,
      UserResponse authUser,
      UserResponse userRequested,
      bool isOwnProfile}) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: ListView(
          clipBehavior: Clip.none,
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    //TODO: LOAD USER COVERIMAGE
                    child: _userProfileToDisplay.coverImage == null
                        ? SizedBox()
                        : Image.network(
                            _userProfileToDisplay.coverImage,
                            fit: BoxFit.cover,
                            colorBlendMode: BlendMode.colorBurn,
                            height: MediaQuery.of(context).size.height,
                          ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height / 4,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 3.5,
                        child: BlocProvider.value(
                            value: BlocProvider.of<ProfileBloc>(context),
                            child: UserProfileInformation(
                                userInformation: _userProfileToDisplay,
                                actualRoute: ActualProfileRoute.userProfile,
                                userIsOwnerProfile: _isCurrentUser))),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height / 5,
                    right: 10,
                    child: Visibility(
                      visible: _isCurrentUser,
                      child: Container(
                        clipBehavior: Clip.none,
                        width: 40,
                        height: 40,
                        child: TextButton(
                            onPressed: () {
                              AppModal.dialogContent(
                                  context: context,
                                  content: [
                                    BlocProvider.value(
                                      value:
                                          BlocProvider.of<ProfileBloc>(context),
                                      child: ModalUploadOptions(
                                          UploadFrom.profileCoverImage),
                                    )
                                  ]);
                            },
                            child:
                                Image.asset('assets/profile/uploadImage.png')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                BlocListener<TaskSubmissionBloc, TaskSubmissionState>(
                    listener: (context, state) {
                      if (state is GetUserTaskSubmissionSuccess) {
                        _assessmentVideosContent = state.taskSubmissions;
                      }
                    },
                    child: _buildCarouselSection(
                        titleForSection: OlukoLocalizations.of(context)
                            .find('assessmentVideos'),
                        routeForSection: ProfileRoutes.goToAssessmentVideos(),
                        contentForSection: _getWidgetListFromContent(
                            assessmentVideoData: _assessmentVideosContent))),
                BlocBuilder<TransformationJourneyBloc,
                    TransformationJourneyState>(
                  builder: (context, state) {
                    if (state is TransformationJourneySuccess) {
                      _transformationJourneyContent = state.contentFromUser;
                    }
                    return _buildCarouselSection(
                        titleForSection: OlukoLocalizations.of(context)
                            .find('transformationJourney'),
                        routeForSection:
                            ProfileRoutes.goToTransformationJourney(),
                        contentForSection: _getWidgetListFromContent(
                            tansformationJourneyData:
                                _transformationJourneyContent));
                  },
                ),
                BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
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
                ),
                BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
                  builder: (context, state) {
                    if (state is GetCourseEnrollmentChallenge) {
                      if (_activeChallenges.length == 0) {
                        _activeChallenges = state.challenges;
                      }
                    }
                    return _buildCarouselSection(
                        titleForSection: OlukoLocalizations.of(context)
                            .find('upcomingChallenges'),
                        routeForSection: ProfileRoutes.goToChallenges(),
                        contentForSection: _getWidgetListFromContent(
                            upcomingChallenges: _activeChallenges));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _requestContentForUser(
      {BuildContext context, UserResponse userRequested}) {
    // BlocProvider.of<CourseEnrollmentBloc>(context)
    // .getCourseEnrollmentsByUserId(profileInfo.id);
    BlocProvider.of<TaskSubmissionBloc>(context)
        .getTaskSubmissionByUserId(userRequested.id);

    BlocProvider.of<CourseEnrollmentBloc>(context)
        .getCourseEnrollmentsCoursesByUserId(userRequested.id);

    BlocProvider.of<TransformationJourneyBloc>(context)
        .getContentByUserName(userRequested.username);

    // BlocProvider.of<CourseEnrollmentBloc>(context)
    //     .getChallengesForUser(userRequested.id);
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

  Padding _buildCarouselSection(
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

  List<Widget> returnCoursesWidget({List<Course> listOfCourses}) {
    List<Widget> contentForCourseSection = [];
    listOfCourses.forEach((course) {
      contentForCourseSection.add(_getCourseCard(courseInfo: course));
    });
    return contentForCourseSection.toList();
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

  List<Widget> _getWidgetListFromContent(
      {List<TransformationJourneyUpload> tansformationJourneyData,
      List<TaskSubmission> assessmentVideoData,
      List<Challenge> upcomingChallenges}) {
    List<Widget> contentForSection = [];

    if (tansformationJourneyData != null &&
        (assessmentVideoData == null && upcomingChallenges == null)) {
      tansformationJourneyData.forEach((contentUploaded) {
        contentForSection.add(_getImageAndVideoCard(
            transformationJourneyContent: contentUploaded));
      });
    }
    if (assessmentVideoData != null &&
        (tansformationJourneyData == null && upcomingChallenges == null)) {
      assessmentVideoData.forEach((assessmentVideo) {
        contentForSection
            .add(_getImageAndVideoCard(taskSubmissionContent: assessmentVideo));
      });
    }
    if (upcomingChallenges != null &&
        (tansformationJourneyData == null && assessmentVideoData == null)) {
      upcomingChallenges.forEach((challenge) {
        contentForSection
            .add(_getImageAndVideoCard(upcomingChallengesContent: challenge));
      });
    }
    return contentForSection.toList();
  }

  Widget _getImageAndVideoCard(
      {TransformationJourneyUpload transformationJourneyContent,
      TaskSubmission taskSubmissionContent,
      Challenge upcomingChallengesContent}) {
    Widget contentForReturn = SizedBox();
    if (transformationJourneyContent != null) {
      contentForReturn = ImageAndVideoContainer(
        assetImage: transformationJourneyContent.thumbnail,
        isVideo: transformationJourneyContent.type == FileTypeEnum.video
            ? true
            : false,
        videoUrl: transformationJourneyContent.file,
      );
    }
    if (taskSubmissionContent != null && taskSubmissionContent.video != null) {
      contentForReturn = ImageAndVideoContainer(
        assetImage: taskSubmissionContent.video != null &&
                taskSubmissionContent.video.thumbUrl != null
            ? taskSubmissionContent.video.thumbUrl
            : '',
        isVideo: taskSubmissionContent.video != null,
        videoUrl: taskSubmissionContent.video != null &&
                taskSubmissionContent.video.url != null
            ? taskSubmissionContent.video.url
            : '',
      );
    }
    if (upcomingChallengesContent != null) {
      //TODO: Crear container con locker icon and w/ also style
      contentForReturn = ImageAndVideoContainer(
        assetImage: upcomingChallengesContent.challengeImage,
        isVideo: false,
      );
    }

    return contentForReturn;
  }
}
