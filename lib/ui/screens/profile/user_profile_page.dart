import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/challenge/upcoming_challenge_bloc.dart';
import 'package:oluko_app/blocs/course/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/points_card_panel_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/helpers/privacy_options.dart';
import 'package:oluko_app/helpers/profile_helper_functions.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/modal_cards.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/user_challenges_component.dart';
import 'package:oluko_app/ui/screens/profile/challenge_courses_panel_content.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class UserProfilePage extends StatefulWidget {
  final UserResponse userRequested;
  final bool isFriend;
  const UserProfilePage({this.userRequested, this.isFriend});
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserResponse _currentAuthUser;
  UserResponse _userProfileToDisplay;
  UserConnectStatus connectStatus;
  UserStatistics userStats;
  Friend friendData;
  FriendModel friendModel;
  UniqueChallengesSuccess _challengesCardsState;
  bool _isCurrentUser = false;
  bool _isFollow = false;
  bool _friendsRequested = false;
  bool canHidePanel = true;
  bool canDeleteProfilePic = false;
  bool canDeleteCoverPic = false;
  String _connectButtonTitle = '';
  List<UserResponse> friendUsers = [];
  List<ChallengeNavigation> listOfChallenges = [];
  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  List<TaskSubmission> _assessmentVideosContent = [];
  List<Course> _coursesToUse = [];
  List<CourseEnrollment> _courseEnrollmentList = [];
  Widget defaultWidgetNoContent = const SizedBox.shrink();
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    setState(() {
      _isCurrentUser = widget.userRequested == null;
      _userProfileToDisplay = widget.userRequested;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        _currentAuthUser = state.user;
        BlocProvider.of<GalleryVideoBloc>(context).getFirstImageFromGalley();
        if (_isOwnerProfile(authUser: _currentAuthUser, userRequested: widget.userRequested)) {
          _isCurrentUser = true;
          _userProfileToDisplay = _currentAuthUser;
          if (_isCurrentUser) {
            canDeleteProfilePic = _userProfileToDisplay.avatar != null;
            canDeleteCoverPic = _userProfileToDisplay.coverImage != null;
          }
        }
        _requestContentForUser(context: context, userRequested: _userProfileToDisplay);
        if (!_isCurrentUser && !_friendsRequested) {
          BlocProvider.of<FriendBloc>(context).getFriendsByUserId(_currentAuthUser.id);
          _friendsRequested = true;
        }
        return Material(
            type: MaterialType.transparency,
            child: SlidingUpPanel(
                backdropEnabled: canHidePanel,
                margin: EdgeInsets.zero,
                header: defaultWidgetNoContent,
                padding: EdgeInsets.zero,
                color: OlukoColors.black,
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 3,
                collapsed: defaultWidgetNoContent,
                controller: _panelController,
                onPanelClosed: () {
                  BlocProvider.of<PointsCardPanelBloc>(context).emitDefaultState();
                },
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                panel: _getPanel(),
                body: _buildUserProfileView(
                    profileViewContext: context, authUser: _currentAuthUser, userRequested: widget.userRequested, isOwnProfile: _isCurrentUser)));
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

  Widget _getPanel() {
    return BlocBuilder<PointsCardPanelBloc, PointsCardPanelState>(builder: (context, state) {
      if (state is PointsCardPanelOpen) {
        _panelController.open();
        return ModalCards();
      } else {
        return ChallengeCoursesPanelContent(panelController: _panelController);
      }
    });
  }

  bool _isOwnerProfile({@required UserResponse authUser, @required UserResponse userRequested}) => authUser.id == userRequested.id;

  Widget _buildUserProfileView({BuildContext profileViewContext, UserResponse authUser, UserResponse userRequested, bool isOwnProfile}) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: _scaffoldBody(profileViewContext, userRequested),
    );
  }

  Widget _scaffoldBody(BuildContext profileViewContext, UserResponse userRequested) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FriendBloc, FriendState>(
          listenWhen: (FriendState previous, FriendState current) => current != previous,
          listener: (context, FriendState state) {
            if (state is GetFriendsSuccess) {
              friendData = state.friendData;
              friendUsers = state.friendUsers;
              checkConnectionStatus(userRequested, friendData);
              if (state.friendUsers.where((element) => element.id == widget.userRequested.id).isNotEmpty) {
                friendModel = state.friendData.friends.where((element) => element.id == widget.userRequested.id).first;
              }
            }
          },
        ),
        BlocListener<FriendRequestBloc, FriendRequestState>(
          listenWhen: (FriendRequestState previous, FriendRequestState current) => current != previous,
          listener: (context, FriendRequestState state) {
            if (state is GetFriendsRequestSuccess) {
              friendData = state.friendData;
              friendUsers = state.friendUsers;
              checkConnectionStatus(userRequested, friendData);
              if (state.friendUsers.where((element) => element.id == widget.userRequested.id).isNotEmpty) {
                friendModel = state.friendData.friends.where((element) => element.id == widget.userRequested.id).first;
              }
            }
          },
        ),
      ],
      child: buildProfileView(userRequested),
    );
  }

  Container buildProfileView(UserResponse userRequested) {
    return Container(
      color: OlukoNeumorphismColors.appBackgroundColor,
      constraints: const BoxConstraints.expand(),
      child: ListView(
        physics: OlukoNeumorphism.listViewPhysicsEffect,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: ScreenUtils.smallScreen(context) ? ScreenUtils.height(context) / 1.8 : ScreenUtils.height(context) / 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [profileCoverImage(), userInformationPanel()],
            ),
          ),
          if (OlukoNeumorphism.isNeumorphismDesign)
            SizedBox(
              height: MediaQuery.of(context).size.height / 16,
            )
          else
            const SizedBox.shrink(),
          Column(
            children: [
              if (!_isCurrentUser) otherUserInteraction(userRequested) else defaultWidgetNoContent,
              const SizedBox(
                height: 30,
              ),
              assessmentVideosSlider(),
              transformationJourneySlider(),
              activeCoursesSlider(_isCurrentUser),
              activeChallengesSlider(_isCurrentUser),
              SizedBox(height: ScreenUtils.height(context) / 10, width: ScreenUtils.width(context))
            ],
          ),
        ],
      ),
    );
  }

  Widget activeChallengesSlider(bool isCurrentUserRequested) {
    return isCurrentUserRequested
        ? BlocBuilder<CourseEnrollmentListStreamBloc, CourseEnrollmentListStreamState>(
            builder: (context, state) {
              if (state is CourseEnrollmentsByUserStreamSuccess) {
                _courseEnrollmentList = state.courseEnrollments;
                listOfChallenges = ProfileHelperFunctions.getChallenges(_courseEnrollmentList);
              }
              return listOfChallenges.isNotEmpty ? buildActiveChallengesForUser() : defaultWidgetNoContent;
            },
          )
        : BlocBuilder<CourseEnrollmentListBloc, CourseEnrollmentListState>(
            builder: (context, state) {
              if (state is CourseEnrollmentsByUserSuccess) {
                _courseEnrollmentList = state.courseEnrollments;
                listOfChallenges = ProfileHelperFunctions.getChallenges(_courseEnrollmentList);
              }
              return listOfChallenges.isNotEmpty ? buildActiveChallengesForUser() : defaultWidgetNoContent;
            },
          );
  }

  Padding buildActiveChallengesForUser() {
    List<Challenge> _activeChallenges = [];
    Widget contentToReturn = SizedBox.shrink();
    return Padding(
      padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.symmetric(horizontal: 20) : EdgeInsets.zero,
      child: BlocBuilder<ChallengeStreamBloc, ChallengeStreamState>(
        builder: (context, state) {
          if (state is GetChallengeStreamSuccess) {
            _activeChallenges = state.challenges;
            listOfChallenges = ProfileHelperFunctions.getActiveChallenges(_activeChallenges, listOfChallenges);
          } else if (state is ChallengesForUserRequested) {
            _activeChallenges = state.challenges;
            listOfChallenges = ProfileHelperFunctions.getActiveChallenges(_activeChallenges, listOfChallenges);
          }
          return buildChallengeSection(
              listOfChallenges: listOfChallenges,
              context: context,
              content: TransformListOfItemsToWidget.getWidgetListFromContent(
                  challengeSegments: listOfChallenges,
                  requestedFromRoute: ActualProfileRoute.userProfile,
                  requestedUser: widget.userRequested,
                  useAudio: !_isCurrentUser));
        },
      ),
    );
  }

  Widget activeCoursesSlider(bool isCurrentUserRequested) {
    return isCurrentUserRequested
        ? BlocBuilder<CourseEnrollmentListStreamBloc, CourseEnrollmentListStreamState>(
            builder: (context, courseEnrollmentStreamState) {
              if (courseEnrollmentStreamState is CourseEnrollmentsByUserStreamSuccess) {
                _courseEnrollmentList = courseEnrollmentStreamState.courseEnrollments;
              }
              return courseSectionBuilder();
            },
          )
        : BlocBuilder<CourseEnrollmentListBloc, CourseEnrollmentListState>(
            builder: (context, state) {
              if (state is CourseEnrollmentsByUserSuccess) {
                _courseEnrollmentList = state.courseEnrollments;
              }
              return courseSectionBuilder();
            },
          );
  }

  BlocBuilder<CourseBloc, CourseState> courseSectionBuilder() {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state is UserEnrolledCoursesSuccess) {
          _coursesToUse = state.courses;
        }
        return _coursesToUse.isNotEmpty && _courseEnrollmentList != null
            ? Padding(
                padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.symmetric(horizontal: 20) : EdgeInsets.zero,
                child: buildCourseSection(context: context, contentForCourse: returnCoursesWidget(listOfCourses: _courseEnrollmentList)))
            : defaultWidgetNoContent;
      },
    );
  }

  BlocBuilder<TransformationJourneyBloc, TransformationJourneyState> transformationJourneySlider() {
    return BlocBuilder<TransformationJourneyBloc, TransformationJourneyState>(
      builder: (context, state) {
        if (state is TransformationJourneySuccess) {
          _transformationJourneyContent = state.contentFromUser;
        }
        return _transformationJourneyContent.isNotEmpty
            ? _buildCarouselSection(
                titleForSection: OlukoLocalizations.get(context, 'transformationPhotos'),
                routeForSection: RouteEnum.profileTransformationJourney,
                contentForSection: TransformListOfItemsToWidget.getWidgetListFromContent(
                    tansformationJourneyData: _transformationJourneyContent,
                    requestedFromRoute: ActualProfileRoute.userProfile,
                    requestedUser: _userProfileToDisplay))
            : defaultWidgetNoContent;
      },
    );
  }

  BlocBuilder<TaskSubmissionBloc, TaskSubmissionState> assessmentVideosSlider() {
    return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(builder: (context, state) {
      if (state is GetUserTaskSubmissionSuccess) {
        _assessmentVideosContent = state.taskSubmissions;
        if (!_isCurrentUser) {
          _assessmentVideosContent = _assessmentVideosContent.where((assessment) => assessment.isPublic).toList();
        }
      }

      return _assessmentVideosContent.isNotEmpty && _isCurrentUser
          ? _buildCarouselSection(
              titleForSection: OlukoLocalizations.get(context, 'assessmentVideos'),
              routeForSection: RouteEnum.profileAssessmentVideos,
              contentForSection: TransformListOfItemsToWidget.getWidgetListFromContent(
                  requestedUser: _userProfileToDisplay, assessmentVideoData: _assessmentVideosContent, requestedFromRoute: ActualProfileRoute.userProfile))
          : defaultWidgetNoContent;
    });
  }

  Padding otherUserInteraction(UserResponse userRequested) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
      child: Row(
        children: [
          if (friendModel != null)
            NeumorphicButton(
              style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
              onPressed: () {
                BlocProvider.of<FavoriteFriendBloc>(context).favoriteFriend(context, friendData, friendModel);
                setState(() {
                  _isFollow = !_isFollow;
                });
              },
              child: Icon(_isFollow ? Icons.favorite : Icons.favorite_border, color: OlukoColors.primary),
            )
          else
            defaultWidgetNoContent,
          Container(
            child: friendModel == null
                ? const Expanded(
                    child: Align(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : !OlukoNeumorphism.isNeumorphismDesign
                    ? OlukoOutlinedButton(
                        onPressed: () {
                          AppMessages().showDialogActionMessage(context, '', 2);
                          checkUserConnectStatus(userRequested);
                          BlocProvider.of<FriendBloc>(context).getFriendsByUserId(_currentAuthUser.id);
                        },
                        title: _connectButtonTitle)
                    : OlukoNeumorphicPrimaryButton(
                        title: _connectButtonTitle,
                        onPressed: () {
                          if (connectStatus != UserConnectStatus.connected) {
                            AppMessages().showDialogActionMessage(context, '', 2);
                          }
                          checkUserConnectStatus(userRequested);
                          BlocProvider.of<FriendBloc>(context).getFriendsByUserId(_currentAuthUser.id);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void checkUserConnectStatus(UserResponse userRequested) {
    switch (connectStatus) {
      case UserConnectStatus.connected:
        BottomDialogUtils.removeConfirmationPopup(_currentAuthUser.id, userRequested, friendData, context, BlocProvider.of<FriendBloc>(context));
        break;
      case UserConnectStatus.notConnected:
        BlocProvider.of<FriendRequestBloc>(context).sendRequestOfConnect(_currentAuthUser.id, friendData, userRequested.id);
        break;
      case UserConnectStatus.requestPending:
        BlocProvider.of<FriendRequestBloc>(context).removeRequestSent(_currentAuthUser.id, friendData, userRequested.id);
        break;
      case UserConnectStatus.requestReceived:
        BlocProvider.of<FriendRequestBloc>(context).acceptRequestOfConnect(_currentAuthUser.id, userRequested.id, friendData);
        break;
      default:
    }
  }

  Positioned userInformationPanel() {
    return Positioned(
      top: OlukoNeumorphism.isNeumorphismDesign ? ScreenUtils.height(context) / 4.5 : ScreenUtils.height(context) / 3.5,
      child: SizedBox(
          width: ScreenUtils.width(context),
          height: getAdaptativeHeight(),
          child: BlocProvider.value(
              value: BlocProvider.of<ProfileBloc>(context),
              child: BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
                builder: (context, state) {
                  if (state is StatisticsSuccess) {
                    userStats = state.userStats;
                  }
                  return UserProfileInformation(
                    userToDisplayInformation: _userProfileToDisplay,
                    actualRoute: ActualProfileRoute.userProfile,
                    currentUser: _currentAuthUser,
                    connectStatus: connectStatus,
                    userStats: userStats,
                  );
                },
              ))),
    );
  }

  Widget profileCoverImage() {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            OlukoNeumorphismColors.appBackgroundColor,
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: Stack(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3,
          child: _userProfileToDisplay.coverImage == null
              ? defaultWidgetNoContent
              : Image(
                  image: CachedNetworkImageProvider(_userProfileToDisplay.coverImage),
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.colorBurn,
                  height: MediaQuery.of(context).size.height,
                ),
        ),
        if (OlukoNeumorphism.isNeumorphismDesign)
          Positioned(
              top: MediaQuery.of(context).size.height / 10,
              left: 15,
              child: OlukoNeumorphicCircleButton(
                onPressed: () {
                  Navigator.pop(context);
                },
              ))
        else
          const SizedBox.shrink(),
      ]),
    );
  }

  void _requestContentForUser({BuildContext context, UserResponse userRequested}) {
    if (PrivacyOptions()
        .canShowDetails(isOwner: _isCurrentUser, currentUser: _currentAuthUser, userRequested: _userProfileToDisplay, connectStatus: connectStatus)) {
      _isCurrentUser
          ? BlocProvider.of<CourseEnrollmentListStreamBloc>(context).getStream(userRequested.id)
          : BlocProvider.of<CourseEnrollmentListBloc>(context).getCourseEnrollmentsByUser(userRequested.id);
      BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionByUserId(userRequested.id);
      BlocProvider.of<CourseBloc>(context).getUserEnrolled(userRequested.id);
      BlocProvider.of<TransformationJourneyBloc>(context).getContentByUserId(userRequested.id);
      _isCurrentUser
          ? BlocProvider.of<ChallengeStreamBloc>(context).getStream(userRequested.id)
          : BlocProvider.of<ChallengeStreamBloc>(context).getChallengesForUserRequested(userRequested.id);
      BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(userRequested.id);
    }
  }

  Padding buildCourseSection({BuildContext context, List<Widget> contentForCourse}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
      child: CarouselSection(
          height: 250,
          width: MediaQuery.of(context).size.width,
          title: ProfileViewConstants.profileOwnProfileActiveCourses,
          optionLabel: OlukoLocalizations.get(context, 'viewAll'),
          onOptionTap: () {
            Navigator.pushNamed(context, routeLabels[RouteEnum.viewAll],
                arguments: {'courses': _coursesToUse, 'title': OlukoLocalizations.get(context, 'activeCourses')});
          },
          children: contentForCourse ??
              [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: OlukoCircularProgressIndicator(),
                )
              ]),
    );
  }

  Padding buildChallengeSection({BuildContext context, List<Widget> content, List<ChallengeNavigation> listOfChallenges}) {
    if (listOfChallenges.isNotEmpty) {
      BlocProvider.of<UpcomingChallengesBloc>(context).getUniqueChallengeCards(
          userId: _userProfileToDisplay.id, listOfChallenges: listOfChallenges, isCurrentUser: _isCurrentUser, userRequested: _userProfileToDisplay);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
      child: BlocBuilder<UpcomingChallengesBloc, UpcomingChallengesState>(
        builder: (context, state) {
          if (state is UniqueChallengesSuccess) {
            _challengesCardsState = state;
            return UserChallengeSection(
              userToDisplay: _userProfileToDisplay,
              isCurrentUser: _isCurrentUser,
              challengeState: state,
              panelController: _panelController,
              defaultNavigation: true,
            );
          } else {
            return getCarouselSection([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: OlukoCircularProgressIndicator(),
              )
            ]);
          }
        },
      ),
    );
  }

  List<Widget> buildChallengeCards(UniqueChallengesSuccess state) {
    List<Widget> challengeList = [];
    for (String id in state.challengeMap.keys) {
      challengeList.add(ChallengesCard(
          panelController: _panelController,
          challengeNavigations: state.challengeMap[id],
          userRequested: !_isCurrentUser ? _userProfileToDisplay : null,
          useAudio: !_isCurrentUser,
          segmentChallenge: state.challengeMap[id][0],
          navigateToSegment: _isCurrentUser,
          audioIcon: !_isCurrentUser,
          customValueForChallenge: state.lockedChallenges[id]));
    }
    ;
    return challengeList;
  }

  Widget getCarouselSection(List<Widget> challengeList) {
    return CarouselSection(
        height: 280,
        width: MediaQuery.of(context).size.width,
        title: OlukoLocalizations.get(context, 'upcomingChallenges'),
        optionLabel: OlukoLocalizations.get(context, 'viewAll'),
        onOptionTap: () {
          if (_challengesCardsState != null) {
            Navigator.pushNamed(context, routeLabels[RouteEnum.profileChallenges],
                arguments: {'isCurrentUser': _isCurrentUser, 'userRequested': _userProfileToDisplay, 'challengesCardsState': _challengesCardsState});
          }
        },
        children: challengeList.isNotEmpty ? challengeList : [const SizedBox.shrink()]);
  }

  Padding _buildCarouselSection({RouteEnum routeForSection, String titleForSection, List<Widget> contentForSection}) {
    return Padding(
        padding: EdgeInsets.zero,
        child: CarouselSmallSection(
            routeToGo: routeForSection,
            title: titleForSection,
            userToGetData: _userProfileToDisplay,
            children: contentForSection.isNotEmpty
                ? contentForSection
                : [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 150),
                      child: OlukoCircularProgressIndicator(),
                    )
                  ]));
  }

  List<Widget> returnCoursesWidget({List<CourseEnrollment> listOfCourses}) {
    List<Widget> contentForCourseSection = [];
    if (listOfCourses.isNotEmpty) {
      listOfCourses.forEach((course) {
        if (course != null) {
          contentForCourseSection.add(_getCourseCard(courseInfo: course));
        }
      });
    }
    return contentForCourseSection.toList();
  }

  Widget _getCourseCard({CourseEnrollment courseInfo}) {
    return Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: CourseCard(
            actualCourse: courseInfo,
            width: 120,
            height: 120,
            imageCover: Image(
              image: CachedNetworkImageProvider(courseInfo.course.image),
              frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
                  ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, width: 120),
            ),
            progress: courseInfo.completion ??
                getCourseProgress(
                    courseEnrollments: _courseEnrollmentList,
                    course: _coursesToUse.isNotEmpty
                        ? _coursesToUse.where((element) => element.id == courseInfo.course.id && courseInfo.isUnenrolled != true).isNotEmpty
                            ? _coursesToUse.where((element) => element.id == courseInfo.course.id && courseInfo.isUnenrolled != true).first
                            : null
                        : null),
            canUnenrollCourse: _isCurrentUser,
            unrolledFunction: () => _requestContentForUser(context: context, userRequested: widget.userRequested)));
  }

  double getCourseProgress({List<CourseEnrollment> courseEnrollments, Course course}) {
    double _completion = 0.0;
    if (courseEnrollments.isNotEmpty && course != null) {
      for (CourseEnrollment courseEnrollment in courseEnrollments) {
        if (courseEnrollment.course.id == course.id) {
          _completion = courseEnrollment.completion / 100;
        }
      }
    }
    return _completion;
  }

  checkConnectionStatus(UserResponse userRequested, Friend friendData) {
    FriendModel userFriendModel;
    final bool userRequestedIsFriend = friendData?.friends?.isNotEmpty && friendData.friends.where((element) => element.id == userRequested.id).isNotEmpty;
    final bool connectionRequested = !userRequestedIsFriend && friendData.friendRequestSent.where((element) => element.id == userRequested.id).isNotEmpty;
    final bool connectionRequestReceived =
        !userRequestedIsFriend && friendData.friendRequestReceived.where((element) => element.id == userRequested.id).isNotEmpty;

    if (userRequestedIsFriend) {
      userFriendModel = friendData.friends.where((element) => element.id == userRequested.id).first;
      _isFollow = userFriendModel.isFavorite;
    }
    if (userRequestedIsFriend) {
      connectStatus = UserConnectStatus.connected;
    } else if (connectionRequested) {
      connectStatus = UserConnectStatus.requestPending;
    } else if (connectionRequestReceived) {
      connectStatus = UserConnectStatus.requestReceived;
    } else {
      connectStatus = UserConnectStatus.notConnected;
    }

    if (_connectButtonTitle != ProfileHelperFunctions.returnTitleForConnectButton(connectStatus, context)) {
      setState(() {
        _connectButtonTitle = ProfileHelperFunctions.returnTitleForConnectButton(connectStatus, context);
      });
    }
  }

  double getAdaptativeHeight() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? ScreenUtils.height(context) < 700
            ? ScreenUtils.height(context) / 2.5
            : ScreenUtils.height(context) / 2.8
        : ScreenUtils.height(context) / 5;
  }
}
