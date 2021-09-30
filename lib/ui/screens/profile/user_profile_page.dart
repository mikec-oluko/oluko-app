import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_avatar_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_cover_image_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/helpers/privacy_options.dart';
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
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/modal_upload_options.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/open_settings_modal.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/components/uploading_modal_success.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
  bool _isFollow = false;
  UserConnectStatus connectStatus;
  Friend friendData;
  FriendModel friendModel;
  List<UserResponse> friendUsers = [];

  String _connectButtonTitle = '';

  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  List<TaskSubmission> _assessmentVideosContent = [];
  List<Challenge> _activeChallenges = [];
  List<Course> _coursesToUse = [];
  List<CourseEnrollment> _courseEnrollmentList = [];
  UserStatistics userStats;

  final PanelController _panelController = PanelController();
  double _panelMaxHeight = 100.0;
  double _statePanelMaxHeight = 100.0;
  bool _isNewCoverImage = false;
  bool _friendsRequested = false;

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

        if (_isOwnerProfile(authUser: _currentAuthUser, userRequested: widget.userRequested)) {
          _userProfileToDisplay = _currentAuthUser;
          _isCurrentUser = true;
        }
        _requestContentForUser(context: context, userRequested: _userProfileToDisplay);

        if (_isCurrentUser == false && _friendsRequested == false) {
          BlocProvider.of<FriendBloc>(context).getFriendsByUserId(_currentAuthUser.id);
          _friendsRequested = true;
        }
        return _buildUserProfileView(
            profileViewContext: context, authUser: _currentAuthUser, userRequested: widget.userRequested, isOwnProfile: _isCurrentUser);
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

  bool _isOwnerProfile({@required UserResponse authUser, @required UserResponse userRequested}) {
    return authUser.id == userRequested.id;
  }

  Widget _buildUserProfileView({BuildContext profileViewContext, UserResponse authUser, UserResponse userRequested, bool isOwnProfile}) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
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
                _statePanelMaxHeight = 100;
              } else {
                _statePanelMaxHeight = 300;
              }
            },
          ),
          BlocListener<ProfileAvatarBloc, ProfileAvatarState>(
            listener: (context, state) {
              if (state is ProfileAvatarDefault || state is ProfileAvatarOpenPanel) {
                _statePanelMaxHeight = 100;
              } else {
                _statePanelMaxHeight = 300;
              }
            },
          ),
          BlocListener<FriendBloc, FriendState>(
            listenWhen: (FriendState previous, FriendState current) => current != previous,
            listener: (context, state) {
              if (state is GetFriendsSuccess) {
                friendData = state.friendData;
                friendUsers = state.friendUsers;
                checkConnectionStatus(userRequested, friendData);
              }
            },
          ),
        ],
        child: SlidingUpPanel(
          onPanelOpened: () {
            setState(() {
              _panelMaxHeight = _statePanelMaxHeight;
            });
          },
          onPanelClosed: () {
            setState(() {
              _isNewCoverImage = false;
            });
            BlocProvider.of<ProfileAvatarBloc>(context).emitDefaultState();
            BlocProvider.of<ProfileCoverImageBloc>(context).emitDefaultState();
          },
          backdropEnabled: true,
          isDraggable: false,
          margin: const EdgeInsets.all(0),
          header: const SizedBox(),
          padding: EdgeInsets.zero,
          color: OlukoColors.black,
          minHeight: 0.0,
          maxHeight: _panelMaxHeight,
          collapsed: const SizedBox(),
          controller: _panelController,
          panel: _isNewCoverImage
              ? BlocBuilder<ProfileCoverImageBloc, ProfileCoverImageState>(builder: (context, state) {
                  Widget _contentForPanel = const SizedBox();
                  if (state is ProfileCoverImageOpen) {
                    _panelController.open();

                    _contentForPanel = ModalUploadOptions(contentFrom: UploadFrom.profileCoverImage);
                  }
                  if (state is ProfileCoverImageDefault) {
                    _contentForPanel = const SizedBox();
                    _panelController.isPanelOpen ? _panelController.close() : null;
                  }
                  if (state is ProfileCoverImageLoading) {
                    _contentForPanel = UploadingModalLoader(UploadFrom.profileCoverImage);
                  }
                  if (state is ProfileCoverSuccess) {
                    _contentForPanel = UploadingModalSuccess(goToPage: UploadFrom.profileImage, userRequested: _userProfileToDisplay);
                  }
                  if (state is ProfileCoverImageFailure) {
                    _panelController.close();
                  }
                  if (state is ProfileCoverRequirePermissions) {
                    _panelController.close().then((value) =>
                        DialogUtils.getDialog(profileViewContext, [OpenSettingsModal(profileViewContext)], showExitButton: false));
                  }
                  return _contentForPanel;
                })
              : BlocBuilder<ProfileAvatarBloc, ProfileAvatarState>(builder: (context, state) {
                  Widget _contentForPanel = const SizedBox();

                  if (state is ProfileAvatarOpenPanel) {
                    _panelController.open();
                    _contentForPanel = ModalUploadOptions(contentFrom: UploadFrom.profileImage);
                  }

                  if (state is ProfileAvatarDefault) {
                    _contentForPanel = const SizedBox();

                    _panelController.isPanelOpen ? _panelController.close() : null;
                  }
                  if (state is ProfileAvatarLoading) {
                    _contentForPanel = UploadingModalLoader(UploadFrom.profileImage);
                  }
                  if (state is ProfileAvatarSuccess) {
                    _contentForPanel = UploadingModalSuccess(goToPage: UploadFrom.profileImage, userRequested: _userProfileToDisplay);
                  }
                  if (state is ProfileAvatarFailure) {
                    _panelController.close();
                  }
                  if (state is ProfileAvatarRequirePermissions) {
                    _panelController.close().then((value) =>
                        DialogUtils.getDialog(profileViewContext, [OpenSettingsModal(profileViewContext)], showExitButton: false));
                  }
                  return _contentForPanel;
                }),
          body: Container(
            constraints: const BoxConstraints.expand(),
            child: ListView(
              clipBehavior: Clip.none,
              padding: const EdgeInsets.all(0),
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
                            ? const SizedBox()
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
                      ),
                      Positioned(
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
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (!_isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  friendModel.isFavorite = !_isFollow;
                                });
                                BlocProvider.of<FavoriteFriendBloc>(context).favoriteFriend(context, friendData, friendModel);
                                setState(() {
                                  _isFollow = !_isFollow;
                                });
                              },
                              child: Icon(_isFollow ? Icons.favorite : Icons.favorite_border, color: OlukoColors.primary),
                            ),
                            Container(
                              child: OlukoOutlinedButton(
                                  onPressed: () {
                                    switch (connectStatus) {
                                      case UserConnectStatus.connected:
                                        BlocProvider.of<FriendBloc>(context).removeFriend(friendData, userRequested.id);
                                        break;
                                      case UserConnectStatus.notConnected:
                                        BlocProvider.of<FriendBloc>(context).sendRequestOfConnect(friendData, userRequested.id);
                                        break;
                                      case UserConnectStatus.requestPending:
                                        BlocProvider.of<FriendBloc>(context).removeRequestSent(friendData, userRequested.id);
                                        break;
                                      default:
                                    }
                                    BlocProvider.of<FriendBloc>(context).getFriendsByUserId(_currentAuthUser.id);
                                  },
                                  title: OlukoLocalizations.of(context).find(_connectButtonTitle)),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(),
                    BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(builder: (context, state) {
                      if (state is GetUserTaskSubmissionSuccess) {
                        _assessmentVideosContent = state.taskSubmissions;
                      }

                      return _assessmentVideosContent.length != 0
                          ? _buildCarouselSection(
                              titleForSection: OlukoLocalizations.of(context).find('assessmentVideos'),
                              routeForSection: RouteEnum.profileAssessmentVideos,
                              contentForSection: TransformListOfItemsToWidget.getWidgetListFromContent(
                                  assessmentVideoData: _assessmentVideosContent, requestedFromRoute: ActualProfileRoute.userProfile))
                          : const SizedBox();
                    }),
                    BlocBuilder<TransformationJourneyBloc, TransformationJourneyState>(
                      builder: (context, state) {
                        if (state is TransformationJourneySuccess) {
                          _transformationJourneyContent = state.contentFromUser;
                        }
                        return _transformationJourneyContent.length != 0
                            ? _buildCarouselSection(
                                titleForSection: OlukoLocalizations.of(context).find('transformationJourney'),
                                routeForSection: RouteEnum.profileTransformationJourney,
                                contentForSection: TransformListOfItemsToWidget.getWidgetListFromContent(
                                    tansformationJourneyData: _transformationJourneyContent,
                                    requestedFromRoute: ActualProfileRoute.userProfile))
                            : const SizedBox();
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
                            ? buildCourseSection(context: context, contentForCourse: returnCoursesWidget(listOfCourses: _coursesToUse))
                            : const SizedBox();
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
                                titleForSection: OlukoLocalizations.of(context).find('upcomingChallenges'),
                                routeForSection: RouteEnum.profileChallenges,
                                contentForSection: TransformListOfItemsToWidget.getWidgetListFromContent(
                                    upcomingChallenges: _activeChallenges, requestedFromRoute: ActualProfileRoute.userProfile))
                            : const SizedBox();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _requestContentForUser({BuildContext context, UserResponse userRequested}) {
    if (PrivacyOptions().canShowDetails(
        isOwner: _isCurrentUser, currentUser: _currentAuthUser, userRequested: _userProfileToDisplay, connectStatus: connectStatus)) {
      BlocProvider.of<CourseEnrollmentListBloc>(context).getCourseEnrollmentsByUserId(userRequested.id);
      BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionByUserId(userRequested.id);
      BlocProvider.of<CourseBloc>(context).getUserEnrolled(userRequested.id);
      BlocProvider.of<TransformationJourneyBloc>(context).getContentByUserId(userRequested.id);
      BlocProvider.of<CourseEnrollmentBloc>(context).getChallengesForUser(userRequested.id);
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

  Padding _buildCarouselSection({RouteEnum routeForSection, String titleForSection, List<Widget> contentForSection}) {
    return Padding(
        padding: const EdgeInsets.only(top: 25),
        child: CarouselSmallSection(
            routeToGo: routeForSection,
            title: titleForSection,
            userToGetData: _userProfileToDisplay,
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
          frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
              ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, width: 120),
        ),
        progress: getCourseProgress(courseEnrollments: _courseEnrollmentList, course: courseInfo),
      ),
    );
  }

  double getCourseProgress({List<CourseEnrollment> courseEnrollments, Course course}) {
    double _completion = 0.0;
    for (CourseEnrollment courseEnrollment in courseEnrollments) {
      if (courseEnrollment.course.id == course.id) {
        _completion = courseEnrollment.completion / 100;
      }
    }
    return _completion;
  }

  checkConnectionStatus(UserResponse userRequested, Friend friendData) {
    if (friendData.friends.length != 0) {
      friendData.friends.forEach((friendFromList) {
        if (friendFromList.id == userRequested.id) {
          if (friendFromList.isFavorite) {
            setState(() {
              _isFollow = true;
              connectStatus = UserConnectStatus.connected;
              _connectButtonTitle = returnTitleForConnectButton(connectStatus);
            });
          } else {
            setState(() {
              connectStatus = UserConnectStatus.connected;
              _connectButtonTitle = returnTitleForConnectButton(connectStatus);
            });
          }
        } else {
          if (friendData.friendRequestSent.length != 0) {
            friendData.friendRequestSent.forEach((friendRequestSent) {
              if (friendRequestSent.id == userRequested.id) {
                setState(() {
                  connectStatus = UserConnectStatus.requestPending;
                  _connectButtonTitle = returnTitleForConnectButton(connectStatus);
                });
              } else {
                setState(() {
                  connectStatus = UserConnectStatus.notConnected;
                  _connectButtonTitle = returnTitleForConnectButton(connectStatus);
                });
              }
            });
          } else {
            setState(() {
              connectStatus = UserConnectStatus.notConnected;
              _connectButtonTitle = returnTitleForConnectButton(connectStatus);
            });
          }
        }
      });
    } else {
      if (friendData.friendRequestSent.length != 0) {
        friendData.friendRequestSent.forEach((friendRequestSent) {
          if (friendRequestSent.id == userRequested.id) {
            setState(() {
              connectStatus = UserConnectStatus.requestPending;
              _connectButtonTitle = returnTitleForConnectButton(connectStatus);
            });
          } else {
            setState(() {
              connectStatus = UserConnectStatus.notConnected;
              _connectButtonTitle = returnTitleForConnectButton(connectStatus);
            });
          }
        });
      } else {
        setState(() {
          connectStatus = UserConnectStatus.notConnected;
          _connectButtonTitle = returnTitleForConnectButton(connectStatus);
        });
      }
    }
  }

  String returnTitleForConnectButton(UserConnectStatus connectStatus) {
    switch (connectStatus) {
      case UserConnectStatus.connected:
        return 'remove';
      case UserConnectStatus.notConnected:
        return 'connect';
      case UserConnectStatus.requestPending:
        return 'cancelConnectionRequested';
      default:
        return 'fail';
    }
  }
}
