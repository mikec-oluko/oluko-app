import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_visibility_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/internet_connection_bloc.dart';
import 'package:oluko_app/blocs/push_notification_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/task_card_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_list_bloc.dart';
import 'package:oluko_app/blocs/user/user_plan_subscription_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/blocs/notification_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/bottom_tab_enum.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/services/push_notification_service.dart';
import 'package:oluko_app/services/route_service.dart';
import 'package:oluko_app/ui/components/bottom_navigation_bar.dart';
import 'package:oluko_app/ui/newDesignComponents/change_plan_popup_content.dart';
import 'package:oluko_app/ui/screens/courses/courses.dart';
import 'package:oluko_app/ui/screens/friends/friends_page.dart';
import 'package:oluko_app/ui/screens/home.dart';
import 'package:oluko_app/ui/screens/profile/profile.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/ui/screens/coach/coach_main_page.dart';

class MainPage extends StatefulWidget {
  MainPage({this.classIndex, this.index, this.tab, Key key}) : super(key: key);
  final int index;
  final int classIndex;
  int tab;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  GlobalService _globalService = GlobalService();

  SegmentSubmission _segmentSubmission;

  bool _isBottomTabActive = true;
  Function showBottomTab;
  List<Widget> tabs = [];
  TabController tabController;
  final AuthBloc _authBloc = AuthBloc();
  User loggedUser;

  List<Widget> getTabs() {
    return [
      getHomeTab(),
      CoachMainPage(),
      Courses(
        showBottomTab: () => setState(() {
          _isBottomTabActive = !_isBottomTabActive;
        }),
      ),
      FriendsPage(
        showBottomTab: () => setState(() {
          _isBottomTabActive = !_isBottomTabActive;
        }),
      ),
      ProfilePage()
    ];
  }

  Widget getHomeTab() {
    if (widget.classIndex != null && widget.index != null) {
      return Home(index: widget.index, classIndex: widget.classIndex);
    } else if (widget.index != null) {
      return Home(index: widget.index);
    } else {
      return Home();
    }
  }

  @override
  void initState() {
    super.initState();
    tabs = getTabs();
    loggedUser = AuthRepository.getLoggedUser();
    BlocProvider.of<AssessmentVisibilityBloc>(context).assignmentSeen(loggedUser.uid);
    BlocProvider.of<InternetConnectionBloc>(context).getConnectivityType();
    tabController = TabController(length: this.tabs.length, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    PushNotificationService.listenPushNotifications(context);
    if (widget.tab != null) {
      this.tabController.index = widget.tab;
      tabController.animateTo(widget.tab);
      widget.tab = null;
    }
    return MultiBlocListener(
      listeners: [
        BlocListener<InternetConnectionBloc, InternetConnectionState>(
          listener: (context, internetState) {
            if (internetState is InternetConnectionConnectedStatus) {
              if (!_globalService.hasInternetConnection) {
                _globalService.setInternetConnection = true;
                _globalService.setConnectivityType = internetState.connectivityResult;
              }
            }
            if (internetState is InternetConnectionDisconnectedStatus) {
              if (!_globalService.hasInternetConnection) {
                Navigator.pushNamed(context, routeLabels[RouteEnum.noInternetConnection]);
              } else {
                _globalService.setInternetConnection = false;
                _globalService.setConnectivityType = ConnectivityResult.none;
                Navigator.pushNamed(context, routeLabels[RouteEnum.noInternetConnection]);
              }
            }
          },
        ),
        BlocListener<VideoBloc, VideoState>(
          listener: (context, state) {
            updateVideo(state);
          },
        ),
        BlocListener<PushNotificationBloc, PushNotificationState>(
          listener: (context, state) {
            if (state is NewPushNotification) {
              if (ModalRoute.of(context).settings.name != routeLabels[RouteEnum.root] || widget.tab != 1) {
                Navigator.pushNamed(
                  context,
                  routeLabels[RouteEnum.root],
                  arguments: {
                    'tab': state.type,
                  },
                );
              }
            }
          },
        ),
        BlocListener<UserPlanSubscriptionBloc, UserPlanSubscriptionState>(
            listenWhen: (UserPlanSubscriptionState previous, UserPlanSubscriptionState current) => previous != current,
            listener: (context, state) async {
              if (state is UserChangedPlan) {
                final String nextRouteForUser = await _userPlanChangedActions(context, state);
                _showPopUp(context, nextRouteForUser, state);
              }
            }),
        BlocListener<AssessmentVisibilityBloc, AssessmentVisibilityState>(
          listener: (context, state) async {
            if (state is UnSeenAssignmentSuccess && state.user.currentPlan > 0) {
              Navigator.pushNamed(context, routeLabels[RouteEnum.assessmentVideos]);
            }
          },
        )
      ],
      child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
        if (authState is AuthSuccess) {
          BlocProvider.of<CourseEnrollmentBloc>(context).getStream(authState.user.id);
          BlocProvider.of<NotificationBloc>(context).getStream(authState.user.id);
          BlocProvider.of<UserProgressStreamBloc>(context).getStream(authState.user.id);
          BlocProvider.of<UserPlanSubscriptionBloc>(context).getPlanSubscriptionStream(authState.user.id);
        }
        return BlocBuilder<AssessmentVisibilityBloc, AssessmentVisibilityState>(
          builder: (context, state) {
            if (state is AssessmentVisibilityLoading || state is UnSeenAssignmentSuccess && state.user.currentPlan > 0) {
              return Scaffold(
                body: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/home/splash_screen.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            } else {
              return Scaffold(
                backgroundColor: OlukoNeumorphismColors.appBackgroundColor,
                body: Padding(
                  padding: _isBottomTabActive && _isNotCourseOrFriendsTab(tabController.index)
                      ? EdgeInsets.only(bottom: ScreenUtils.smallScreen(context) ? ScreenUtils.width(context) / 5.5 : ScreenUtils.width(context) / 6.55)
                      : const EdgeInsets.only(bottom: 0),
                  child: TabBarView(
                    //physics this is setup to stop swiping from tab to tab
                    physics: const NeverScrollableScrollPhysics(),
                    controller: this.tabController,
                    children: tabs,
                  ),
                ),
                extendBody: true,
                bottomNavigationBar: _isBottomTabActive
                    ? OlukoBottomNavigationBar(
                        selectedIndex: this.tabController.index,
                        onPressed: (index) => this.setState(() {
                          this.tabController.animateTo(index as int);
                        }),
                        loggedUser: loggedUser,
                      )
                    : const SizedBox(),
              );
            }
          },
        );
      }),
    );
  }

  void _showPopUp(BuildContext context, String route, UserChangedPlan state) {
    DialogUtils.getDialog(
        context,
        [
          ChangePlanPopUpContent(
            primaryPress: () => _needLogoutAction(route) ? _authBloc.logout(context) : goToRoute(context, route),
            isPlanCanceled: _userIsUnsubscribe(state),
          )
        ],
        showExitButton: false);
  }

  bool _userIsUnsubscribe(UserChangedPlan state) => state.userDataUpdated.currentPlan < 0 || state.userDataUpdated.currentPlan == null;

  bool _isNotCourseOrFriendsTab(int index) {
    return index != BottomTabEnum.courses.index && index != BottomTabEnum.community.index;
  }

  Future<String> _userPlanChangedActions(BuildContext context, UserChangedPlan state) async {
    final User alreadyLoggedUser = await AuthBloc.checkCurrentUserStatic();
    BlocProvider.of<AuthBloc>(context).updateAuthSuccess(state.userDataUpdated, alreadyLoggedUser);
    final String route = await RouteService.getInitialRoute(alreadyLoggedUser, false, state.userDataUpdated);
    if (!_needLogoutAction(route)) _authBloc.storeUpdatedLoginData(state);
    return route;
  }

  void goToRoute(BuildContext context, String route) => Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );

  bool _needLogoutAction(String route) => route == routeLabels[RouteEnum.loginNeumorphic] || route == routeLabels[RouteEnum.signUp];

  taskSubmissionActions(VideoSuccess state) async {
    // BlocProvider.of<TaskSubmissionListBloc>(context).updateTaskSubmissionVideo(state.assessmentAssignment, state.taskSubmission.id, state.video);
    await BlocProvider.of<TaskSubmissionListBloc>(context)
        .saveTaskSubmissionWithVideo(state.assessmentAssignment, state.taskSubmission, state.video, state.isLastTask);
    BlocProvider.of<TaskSubmissionListBloc>(context).checkCompleted(state.assessmentAssignment, state.assessment);
    BlocProvider.of<TaskCardBloc>(context).taskFinished(state.taskSubmission.task.id);
    BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionOfTask(state.assessmentAssignment, state.taskSubmission.task.id);
    BlocProvider.of<TaskSubmissionListBloc>(context).get(state.assessmentAssignment);
  }

  void updateVideo(VideoState state) {
    if (state is VideoSuccess && state.segmentSubmission != null) {
      _globalService.videoProcessing = false;
      saveUploadedState(state);
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'uploadSuccessful'));
    } else if (state is VideoSuccess && state.assessment != null) {
      _globalService.videoProcessing = false;
      taskSubmissionActions(state);
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'uploadSuccessful'));
    } else if (state is VideoFailure) {
      _globalService.videoProcessing = false;

      saveErrorState(state);
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'uploadError'));
    }
  }

  void saveUploadedState(VideoSuccess state) {
    setState(() {
      _segmentSubmission = state.segmentSubmission;
      _segmentSubmission.video = state.video;
    });
    // BlocProvider.of<SegmentSubmissionBloc>(context).updateVideo(_segmentSubmission);
    BlocProvider.of<SegmentSubmissionBloc>(context).saveSegmentSubmissionWithVideo(_segmentSubmission, state.coachRequest);
  }

  void saveErrorState(VideoFailure state) {
    if (state.segmentSubmission != null) {
      setState(() {
        _segmentSubmission = state.segmentSubmission;
        _segmentSubmission.videoState.error = state.exceptionMessage;
      });
      BlocProvider.of<SegmentSubmissionBloc>(context).updateStateToError(_segmentSubmission);
    }
  }
}
