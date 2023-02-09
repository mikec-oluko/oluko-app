import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/ui/components/hand_widget.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/stories_header.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/newDesignComponents/user_cover_image_component.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class HomeNeumorphicLatestDesign extends StatefulWidget {
  final String currentUserId;
  const HomeNeumorphicLatestDesign({this.currentUserId}) : super();

  @override
  State<HomeNeumorphicLatestDesign> createState() => _HomeNeumorphicLatestDesignState();
}

class _HomeNeumorphicLatestDesignState extends State<HomeNeumorphicLatestDesign> {
  UserResponse _currentAuthUser;
  final bool showLogo = true;
  bool showStories = false;
  UserStatistics userStats;

  @override
  void initState() {
    BlocProvider.of<StoryBloc>(context).hasStories(widget.currentUserId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          _currentAuthUser = authState.user;
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return _stories(authState);
              },
              body: Container(
                color: OlukoNeumorphismColors.appBackgroundColor,
                constraints: const BoxConstraints.expand(),
                child: ListView(
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    _userCoverAndProfileDetails(),
                    _enrolledCoursesAndPeople(),
                    _myListOfCourses(),
                    _friendsRecommended(),
                    _upcomingChallenges(),
                    _completedChallenges(),
                    _transformationPhotos(),
                    _assessmentVideos()
                  ],
                ),
              ),
            ),
          );
        } else {
          return OlukoCircularProgressIndicator();
        }
      },
    );
  }

  List<Widget> _stories(AuthSuccess authState) {
    return [
      if (showLogo) getLogo(authState) else const SliverToBoxAdapter(),
      if (GlobalConfiguration().getValue('showStories') == 'true') getStoriesBar(context),
    ];
  }

  Widget _userCoverAndProfileDetails() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtils.smallScreen(context) ? ScreenUtils.height(context) / 1.8 : ScreenUtils.height(context) / 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          UserCoverImageComponent(
            currentAuthUser: _currentAuthUser,
            isHomeImage: true,
          ),
          userInformationPanel(),
        ],
      ),
    );
  }

  Widget _enrolledCoursesAndPeople() {
    return Container();
  }

  Widget _myListOfCourses() {
    return Container();
  }

  Widget _friendsRecommended() {
    return Container();
  }

  Widget _upcomingChallenges() {
    return Container();
  }

  Widget _completedChallenges() {
    return Container();
  }

  Widget _transformationPhotos() {
    return Container();
  }

  Widget _assessmentVideos() {
    return Container();
  }

  // TODO: MOVE AS WIDGET
  SliverAppBar getLogo(AuthSuccess authState) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      stretch: true,
      pinned: true,
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      title: Container(
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              OlukoNeumorphism.mvtLogo,
              scale: 4,
            ),
            HandWidget(authState: authState, onTap: () {}),
          ],
        ),
      ),
    );
  }

// TODO: MOVE AS WIDGET
  Widget getStoriesBar(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, hasStories) {
        showStories = hasStories is HasStoriesSuccess && hasStories.hasStories && showLogo;
        return enrolledContent(showStories);
      },
    );
  }

// TODO: MOVE AS WIDGET
  Widget enrolledContent(bool showStories) {
    return SliverToBoxAdapter(
      child: Container(
        alignment: Alignment.centerLeft,
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        child: showStories
            ? StoriesHeader(
                _currentAuthUser.id,
                onTap: () {},
                maxRadius: 30,
                color: OlukoColors.userColor(_currentAuthUser.firstName, _currentAuthUser.lastName),
              )
            : const SizedBox(),
      ),
    );
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
                    userToDisplayInformation: _currentAuthUser,
                    actualRoute: ActualProfileRoute.userProfile,
                    currentUser: _currentAuthUser,
                    userStats: userStats,
                  );
                },
              ))),
    );
  }

  double getAdaptativeHeight() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? ScreenUtils.height(context) < 700
            ? ScreenUtils.height(context) / 2.5
            : ScreenUtils.height(context) / 2.8
        : ScreenUtils.height(context) / 5;
  }
}
