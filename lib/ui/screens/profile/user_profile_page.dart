import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_completed_before_bloc.dart';
import 'package:oluko_app/blocs/challenge/upcoming_challenge_bloc.dart';
import 'package:oluko_app/blocs/course/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_avatar_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_cover_image_bloc.dart';
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
import 'package:oluko_app/ui/components/modal_exception_message.dart';
import 'package:oluko_app/ui/components/modal_upload_options.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/components/uploading_modal_success.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/screens/profile/challenge_courses_panel_content.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/permissions_utils.dart';
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
  bool _isCurrentUser = false;
  bool _isFollow = false;
  UserConnectStatus connectStatus;
  Friend friendData;
  FriendModel friendModel;
  List<UserResponse> friendUsers = [];
  List<ChallengeNavigation> listOfChallenges = [];
  String _connectButtonTitle = '';
  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  List<TaskSubmission> _assessmentVideosContent = [];
  List<Challenge> _activeChallenges = [];
  List<Course> _coursesToUse = [];
  List<CourseEnrollment> _courseEnrollmentList = [];
  UserStatistics userStats;
  final PanelController _panelController = PanelController();
  final PanelController _coursesPanelController = PanelController();
  double _panelMaxHeight = 100.0;
  double _panelExtendedMaxHeight = 300.0;
  bool _isNewCoverImage = false;
  bool _friendsRequested = false;
  bool canHidePanel = true;
  Widget defaultWidgetNoContent = const SizedBox.shrink();
  UniqueChallengesSuccess _challengesCardsState;

  @override
  void initState() {
    setState(() {
      if (widget.userRequested == null) {
        _isCurrentUser = true;
      } else {
        _isCurrentUser = false;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      _userProfileToDisplay = widget.userRequested;

      if (state is AuthSuccess) {
        _currentAuthUser = state.user;
        BlocProvider.of<GalleryVideoBloc>(context).getFirstImageFromGalley();
        if (_isOwnerProfile(authUser: _currentAuthUser, userRequested: widget.userRequested)) {
          _userProfileToDisplay = _currentAuthUser;
          _isCurrentUser = true;
        }
        _requestContentForUser(context: context, userRequested: _userProfileToDisplay);

        if (!_isCurrentUser && !_friendsRequested) {
          BlocProvider.of<FriendBloc>(context).getFriendsByUserId(_currentAuthUser.id);
          _friendsRequested = true;
        }
        return SlidingUpPanel(
            backdropEnabled: canHidePanel,
            isDraggable: true,
            margin: EdgeInsets.zero,
            header: defaultWidgetNoContent,
            padding: EdgeInsets.zero,
            color: OlukoColors.black,
            minHeight: 0,
            maxHeight: (ScreenUtils.height(context) / 4) * 3,
            collapsed: defaultWidgetNoContent,
            controller: _coursesPanelController,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            panel: ChallengeCoursesPanelContent(panelController: _coursesPanelController),
            body: _buildUserProfileView(
                profileViewContext: context, authUser: _currentAuthUser, userRequested: widget.userRequested, isOwnProfile: _isCurrentUser));
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

  bool _isOwnerProfile({@required UserResponse authUser, @required UserResponse userRequested}) => authUser.id == userRequested.id;

  Widget _buildUserProfileView({BuildContext profileViewContext, UserResponse authUser, UserResponse userRequested, bool isOwnProfile}) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: !OlukoNeumorphism.isNeumorphismDesign,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: OlukoNeumorphism.isNeumorphismDesign
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileCoverImageBloc, ProfileCoverImageState>(
            listener: (context, state) {
              if (state is ProfileCoverImageDefault || state is ProfileCoverImageOpen) {
                setState(() {
                  updatePanelProperties(_panelMaxHeight, true);
                });
              } else {
                setState(() {
                  updatePanelProperties(_panelExtendedMaxHeight, false);
                });
              }
              if (state is ProfileCoverImageFailure) {
                setState(() {
                  updatePanelProperties(_panelMaxHeight, true);
                });
              }
            },
          ),
          BlocListener<ProfileAvatarBloc, ProfileAvatarState>(
            listener: (context, state) {
              if (state is ProfileAvatarDefault || state is ProfileAvatarOpenPanel) {
                setState(() {
                  updatePanelProperties(_panelMaxHeight, true);
                });
              } else {
                setState(() {
                  updatePanelProperties(_panelExtendedMaxHeight, false);
                });
              }
              if (state is ProfileAvatarFailure) {
                setState(() {
                  updatePanelProperties(_panelMaxHeight, true);
                });
              }
            },
          ),
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
        child: SlidingUpPanel(
          onPanelClosed: () {
            if (_isNewCoverImage) {
              setState(() {
                _isNewCoverImage = !_isNewCoverImage;
              });
              BlocProvider.of<ProfileCoverImageBloc>(context).emitDefaultState();
            } else {
              BlocProvider.of<ProfileAvatarBloc>(context).emitDefaultState();
            }
          },
          backdropEnabled: canHidePanel,
          isDraggable: false,
          margin: EdgeInsets.zero,
          header: defaultWidgetNoContent,
          padding: EdgeInsets.zero,
          color: OlukoColors.black,
          minHeight: 0.0,
          maxHeight: _panelMaxHeight,
          collapsed: defaultWidgetNoContent,
          controller: _panelController,
          borderRadius:
              OlukoNeumorphism.isNeumorphismDesign ? const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)) : BorderRadius.zero,
          panel: _isNewCoverImage ? profileCoverImageBuilder(profileViewContext) : profileAvatarBuilder(profileViewContext),
          body: buildProfileView(userRequested),
        ),
      ),
    );
  }

  BlocBuilder<ProfileCoverImageBloc, ProfileCoverImageState> profileCoverImageBuilder(BuildContext profileViewContext) {
    return BlocBuilder<ProfileCoverImageBloc, ProfileCoverImageState>(builder: (context, state) {
      Widget _contentForPanel = defaultWidgetNoContent;
      if (state is ProfileCoverImageOpen) {
        _panelController.isPanelClosed ? _panelController.open() : null;
        _contentForPanel = ModalUploadOptions(contentFrom: UploadFrom.profileCoverImage);
      }
      if (state is ProfileCoverImageDefault) {
        _contentForPanel = defaultWidgetNoContent;
        _panelController.isPanelOpen ? _panelController.close() : null;
      }
      if (state is ProfileCoverImageLoading) {
        _contentForPanel = UploadingModalLoader(UploadFrom.profileCoverImage);
      }
      if (state is ProfileCoverSuccess) {
        _contentForPanel = UploadingModalSuccess(goToPage: UploadFrom.profileImage, userRequested: _userProfileToDisplay);
      }
      if (state is ProfileCoverImageFailure) {
        _contentForPanel = ModalExceptionMessage(
            exceptionType: state.exceptionType,
            onPress: () => _panelController.isPanelOpen ? _panelController.close() : null,
            exceptionSource: state.exceptionSource);
      }
      if (state is ProfileCoverRequirePermissions) {
        _panelController.close().then((value) => PermissionsUtils.showSettingsMessage(context));
      }
      return _contentForPanel;
    });
  }

  BlocBuilder<ProfileAvatarBloc, ProfileAvatarState> profileAvatarBuilder(BuildContext profileViewContext) {
    return BlocBuilder<ProfileAvatarBloc, ProfileAvatarState>(builder: (context, state) {
      Widget _contentForPanel = defaultWidgetNoContent;

      if (state is ProfileAvatarOpenPanel) {
        _panelController.isPanelClosed ? _panelController.open() : null;
        _contentForPanel = ModalUploadOptions(contentFrom: UploadFrom.profileImage);
      }
      if (state is ProfileAvatarDefault) {
        _contentForPanel = defaultWidgetNoContent;

        _panelController.isPanelOpen ? _panelController.close() : null;
      }
      if (state is ProfileAvatarLoading) {
        _contentForPanel = UploadingModalLoader(UploadFrom.profileImage);
      }
      if (state is ProfileAvatarSuccess) {
        _contentForPanel = UploadingModalSuccess(goToPage: UploadFrom.profileImage, userRequested: _userProfileToDisplay);
      }
      if (state is ProfileAvatarFailure) {
        _contentForPanel = ModalExceptionMessage(
            exceptionType: state.exceptionType,
            onPress: () => _panelController.isPanelOpen ? _panelController.close() : null,
            exceptionSource: state.exceptionSource);
      }
      if (state is ProfileAvatarRequirePermissions) {
        _panelController.close().then((value) => PermissionsUtils.showSettingsMessage(context));
      }
      return _contentForPanel;
    });
  }

  Container buildProfileView(UserResponse userRequested) {
    return Container(
      color: OlukoNeumorphismColors.appBackgroundColor,
      constraints: const BoxConstraints.expand(),
      child: ListView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: ScreenUtils.smallScreen(context) ? ScreenUtils.height(context) / 1.8 : ScreenUtils.height(context) / 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                profileCoverImage(),
                userInformationPanel(),
                coverImageWidget(),
              ],
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
              assessmentVideosSlider(),
              transformationJourneySlider(),
              activeCoursesSlider(_isCurrentUser),
              activeChallengesSlider(_isCurrentUser),
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
          }
          if (state is ChallengesForUserRequested) {
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
                padding: OlukoNeumorphism.isNeumorphismDesign ? EdgeInsets.symmetric(horizontal: 20) : EdgeInsets.symmetric(),
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
                titleForSection: OlukoLocalizations.get(context, 'transformationJourney'),
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
        if(!_isCurrentUser){
          _assessmentVideosContent=_assessmentVideosContent.where((assessment) => assessment.isPublic).toList();
        }
      }

      return _assessmentVideosContent.isNotEmpty
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
            TextButton(
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
            child: !OlukoNeumorphism.isNeumorphismDesign
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
          height: OlukoNeumorphism.isNeumorphismDesign
              ? ScreenUtils.height(context) < 700
                  ? ScreenUtils.height(context) / 2.5
                  : ScreenUtils.height(context) / 2.8
              : ScreenUtils.height(context) / 5,
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

  Positioned coverImageWidget() {
    return Positioned(
      top: MediaQuery.of(context).size.height / 5,
      right: 10,
      child: Visibility(
        visible: _isCurrentUser,
        child: Container(
          width: 40,
          height: 40,
          child: TextButton(
              onPressed: () {
                setState(() {
                  _isNewCoverImage = true;
                });
                BlocProvider.of<ProfileCoverImageBloc>(context).openPanel();
              },
              child: Image.asset('assets/profile/uploadImage.png')),
        ),
      ),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: MediaQuery.of(context).size.height / 10),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker,
                      width: 52,
                      height: 52,
                      child: Image.asset(
                        'assets/courses/left_back_arrow.png',
                        scale: 3.5,
                      )),
                )),
          )
        else
          SizedBox.shrink(),
      ]),
    );
  }

  void updatePanelProperties(double panelHeight, bool hidePanel) {
    _panelMaxHeight = panelHeight;
    canHidePanel = hidePanel;
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
          children: contentForCourse != null
              ? contentForCourse
              : [
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
            return getCarouselSection(buildChallengeCards(state));
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
          panelController: _coursesPanelController,
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
        children: challengeList.isNotEmpty ? challengeList : [SizedBox.shrink()]);
  }

  Padding _buildCarouselSection({RouteEnum routeForSection, String titleForSection, List<Widget> contentForSection}) {
    return Padding(
        padding: const EdgeInsets.only(top: 0),
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
}
