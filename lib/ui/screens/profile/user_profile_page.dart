import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/modal_upload_options.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
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
  String _connectButtonDefaultText = "Connect";
  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  List<TaskSubmission> _assessmentVideosContent = [];
  List<Challenge> _activeChallenges = [];
  List<Course> _coursesToUse = [];
  List<CourseEnrollment> _courseEnrollmentList = [];
  bool _isFollow = true;

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
        }
        _requestContentForUser(
            context: context, userRequested: _userProfileToDisplay);
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
                                isOwner: _isCurrentUser))),
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
                //TODO: Check CONNECT and FOLLOW   _currentAuthUser And _userProfileToDisplay
                !_isCurrentUser
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isFollow = !_isFollow;
                                });
                                //TODO: Send Like from _currentAuthUser to UserToDisplay
                              },
                              child: Icon(
                                  _isFollow
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: OlukoColors.primary),
                            ),
                            Container(
                              child: OlukoOutlinedButton(
                                  onPressed: () {
                                    //TODO: Connect _currentAuthUser with UserToDisplay
                                  },
                                  title: _connectButtonDefaultText),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
                    builder: (context, state) {
                  if (state is GetUserTaskSubmissionSuccess) {
                    _assessmentVideosContent = state.taskSubmissions;
                  }

                  return _assessmentVideosContent.length != 0
                      ? _buildCarouselSection(
                          titleForSection: OlukoLocalizations.of(context)
                              .find('assessmentVideos'),
                          routeForSection:
                              routeLabels[RouteEnum.profileAssessmentVideos],
                          contentForSection: TransformListOfItemsToWidget
                              .getWidgetListFromContent(
                                  assessmentVideoData: _assessmentVideosContent,
                                  requestedFromRoute:
                                      ActualProfileRoute.userProfile))
                      : SizedBox();
                }),
                BlocBuilder<TransformationJourneyBloc,
                    TransformationJourneyState>(
                  builder: (context, state) {
                    if (state is TransformationJourneySuccess) {
                      _transformationJourneyContent = state.contentFromUser;
                    }
                    return _transformationJourneyContent.length != 0
                        ? _buildCarouselSection(
                            titleForSection: OlukoLocalizations.of(context)
                                .find('transformationJourney'),
                            routeForSection: routeLabels[
                                RouteEnum.profileTransformationJourney],
                            contentForSection: TransformListOfItemsToWidget
                                .getWidgetListFromContent(
                                    tansformationJourneyData:
                                        _transformationJourneyContent,
                                    requestedFromRoute:
                                        ActualProfileRoute.userProfile))
                        : SizedBox();
                  },
                ),
                BlocBuilder<CourseBloc, CourseState>(
                  builder: (context, state) {
                    if (state is UserEnrolledCoursesSuccess) {
                      if (_coursesToUse.length == 0) {
                        _coursesToUse = state.courses;
                      }
                    }
                    return _coursesToUse.length != 0
                        ? buildCourseSection(
                            context: context,
                            contentForCourse: returnCoursesWidget(
                                listOfCourses: _coursesToUse))
                        : SizedBox();
                  },
                ),
                BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
                  builder: (context, state) {
                    if (state is GetCourseEnrollmentChallenge) {
                      if (_activeChallenges.length == 0) {
                        _activeChallenges = state.challenges;
                      }
                    }
                    if (state is CourseEnrollmentListSuccess) {
                      _courseEnrollmentList = state.courseEnrollmentList;
                    }
                    return _activeChallenges.length != 0
                        ? _buildCarouselSection(
                            titleForSection: OlukoLocalizations.of(context)
                                .find('upcomingChallenges'),
                            routeForSection:
                                routeLabels[RouteEnum.profileChallenges],
                            contentForSection: TransformListOfItemsToWidget
                                .getWidgetListFromContent(
                                    upcomingChallenges: _activeChallenges,
                                    requestedFromRoute:
                                        ActualProfileRoute.userProfile))
                        : SizedBox();
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
    BlocProvider.of<CourseEnrollmentBloc>(context)
        .getCourseEnrollmentsByUserId(userRequested.id);

    BlocProvider.of<TaskSubmissionBloc>(context)
        .getTaskSubmissionByUserId(userRequested.id);

    BlocProvider.of<CourseBloc>(context).getUserEnrolled(userRequested.id);

    BlocProvider.of<TransformationJourneyBloc>(context)
        .getContentByUserId(userRequested.id);

    BlocProvider.of<CourseEnrollmentBloc>(context)
        .getChallengesForUser(userRequested.id);
  }

  Padding buildCourseSection(
      {BuildContext context, List<Widget> contentForCourse}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
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
          courseInfo.image,
          frameBuilder: (BuildContext context, Widget child, int frame,
                  bool wasSynchronouslyLoaded) =>
              ImageUtils.frameBuilder(
                  context, child, frame, wasSynchronouslyLoaded,
                  height: 120, width: 120),
        ),
        progress: getCourseProgress(
            courseEnrollments: _courseEnrollmentList, course: courseInfo),
      ),
    );
  }

  getCourseProgress({List<CourseEnrollment> courseEnrollments, Course course}) {
    double _completion = 0.0;
    for (CourseEnrollment courseEnrollment in courseEnrollments) {
      if (courseEnrollment.course.id == course.id) {
        _completion = courseEnrollment.completion / 100;
      }
    }
    return _completion;
  }
}
