import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/push_notification_bloc.dart';

import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/task_card_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_list_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';

import 'package:oluko_app/blocs/notification_bloc.dart';
import 'package:oluko_app/blocs/views_bloc/hi_five_bloc.dart';
import 'package:oluko_app/helpers/user_information_bottombar.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/services/push_notification_service.dart';
import 'package:oluko_app/ui/components/bottom_navigation_bar.dart';
import 'package:oluko_app/ui/screens/courses/courses.dart';
import 'package:oluko_app/ui/screens/friends/friends_page.dart';
import 'package:oluko_app/ui/screens/home.dart';
import 'package:oluko_app/ui/screens/profile/profile.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'coach/coach_main_page.dart';

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

  List<Widget> getTabs() {
    return [
      getHomeTab(),
      CoachMainPage(),
      FriendsPage(),
      Courses(
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
          BlocListener<VideoBloc, VideoState>(
            listener: (context, state) {
              updateVideo(state);
            },
          ),
          BlocListener<PushNotificationBloc, PushNotificationState>(
            listener: (context, state) {
              if (state is NewPushNotification) {
                if(ModalRoute.of(context).settings.name != routeLabels[RouteEnum.root] || widget.tab != 1) {
                  Navigator.pushNamed(
                  context,
                  routeLabels[RouteEnum.root],
                  arguments: {
                    'tab': 1,
                  },
                );
                }
              }
            },
          )
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthSuccess) {
              BlocProvider.of<NotificationBloc>(context).getStream(authState.user.id);
            }
            return Scaffold(
              body: Padding(
                padding: _isBottomTabActive ? const EdgeInsets.only(bottom: 75) : const EdgeInsets.only(bottom: 0),
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
                    )
                  : const SizedBox(),
            );
          },
        ));
  }

  taskSubmissionActions(VideoSuccess state) {
    BlocProvider.of<TaskSubmissionListBloc>(context)
        .updateTaskSubmissionVideo(state.assessmentAssignment, state.taskSubmission.id, state.video);
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
    BlocProvider.of<SegmentSubmissionBloc>(context).updateVideo(_segmentSubmission);
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
