import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/blocs/views_bloc/hi_five_bloc.dart';
import 'package:oluko_app/helpers/user_information_bottombar.dart';
import 'package:oluko_app/models/segment_submission.dart';
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
    tabs = getTabs();
    tabController = TabController(length: this.tabs.length, vsync: this);
    super.initState();
    tabController.addListener(() {
      this.setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    UserInformationBottomBar userInformation;
    if (widget.tab != null) {
      this.tabController.index = widget.tab;
      tabController.animateTo(widget.tab);
      widget.tab = null;
    }
    return BlocListener<VideoBloc, VideoState>(listener: (context, state) {
      updateSegment(state);
    }, child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          BlocProvider.of<HiFiveBloc>(context).get(authState.user.id);
          userInformation = UserInformationBottomBar(
              firstName: authState.user.firstName,
              lastName: authState.user.lastName,
              avatarThumbnail: authState.user.avatarThumbnail,
              profileDefaultPicContent:
                  '${authState.user.firstName.characters.first.toUpperCase()}${authState.user.lastName.characters.first.toUpperCase()}');
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
                  userInformation: userInformation,
                  selectedIndex: this.tabController.index,
                  onPressed: (index) => this.setState(() {
                    this.tabController.animateTo(index as int);
                  }),
                )
              : SizedBox(),
        );
      },
    ));
  }

  void updateSegment(VideoState state) {
    if (state is VideoSuccess && state.segmentSubmission != null) {
      saveUploadedState(state);
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'segmentUploadedSuccessfully'));
    } else if (state is VideoFailure) {
      saveErrorState(state);
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'uploadedWithErrors'));
    }
    //}
  }

  void saveUploadedState(VideoSuccess state) {
    setState(() {
      _segmentSubmission = state.segmentSubmission;
      _segmentSubmission.video = state.video;
    });
    BlocProvider.of<SegmentSubmissionBloc>(context).updateVideo(_segmentSubmission);
  }

  void saveErrorState(VideoFailure state) {
    setState(() {
      _segmentSubmission = state.segmentSubmission;
      _segmentSubmission.videoState.error = state.exceptionMessage;
    });
    BlocProvider.of<SegmentSubmissionBloc>(context).updateStateToError(_segmentSubmission);
  }
}
