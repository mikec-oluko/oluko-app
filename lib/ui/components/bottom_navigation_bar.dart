import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/chat_slider_messages_bloc.dart';
import 'package:oluko_app/blocs/coach_tab_notification.dart';
import 'package:oluko_app/blocs/community_tab_friend_notification_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_avatar_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/user_information_bottombar.dart';
import 'package:oluko_app/models/utils/oluko_bottom_navigation_bar_item.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class OlukoBottomNavigationBar extends StatefulWidget {
  final Function(num) onPressed;
  final List<Widget> actions;
  final int selectedIndex;
  final User loggedUser;

  OlukoBottomNavigationBar({this.onPressed, this.actions, this.selectedIndex, this.loggedUser});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<OlukoBottomNavigationBar> {
  @override
  void initState() {
    BlocProvider.of<ChatSliderMessagesBloc>(context).listenToMessages(widget.loggedUser.uid);
    BlocProvider.of<CommunityTabFriendNotificationBloc>(context).listenFriendRequestByUserId(userId: widget.loggedUser.uid);
    BlocProvider.of<CoachTabNotificationBloc>(context).listenAnnotationsByUserId(userId: widget.loggedUser.uid);
    BlocProvider.of<CoachTabNotificationBloc>(context).listenRecommendationsByUserId(userId: widget.loggedUser.uid);
    BlocProvider.of<CoachTabNotificationBloc>(context).listenWelcomeVideoByUserId(userId: widget.loggedUser.uid);
    BlocProvider.of<CoachTabNotificationBloc>(context).listenVideoMessagesVideoByUserId(userId: widget.loggedUser.uid);
  }

  UserInformationBottomBar userInformation;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          userInformation = UserInformationBottomBar(
            firstName: state.user.firstName,
            lastName: state.user.lastName,
            avatar: state.user.avatar,
          );
        }
        return OlukoNeumorphism.isNeumorphismDesign
            ? ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: OlukoNeumorphism.radiusValue,
                  topRight: OlukoNeumorphism.radiusValue,
                ),
                child: Container(
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: OlukoColors.grayColorFadeTop))), child: getBottomNavigationBar()))
            : getBottomNavigationBar();
      },
    );
  }

  BottomNavigationBar getBottomNavigationBar() {
    return BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.white,
        selectedItemColor: OlukoColors.black,
        type: BottomNavigationBarType.fixed,
        backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        onTap: (int index) => this.setState(() {
              final OlukoBottomNavigationBarItem selectedItem = getBottomNavigationBarItems()[index];
              if (selectedItem.disabled == false) {
                widget.onPressed(index);
              }
            }),
        items: getNavigationBarWidgets(selectedIndex: widget.selectedIndex));
  }

  Widget _menuIcon(OlukoBottomNavigationBarItem olukoBottomNavigationBarItem) {
    return BlocBuilder<CoachTabNotificationBloc, CoachTabNotificationState>(
      builder: (contextCoachNotification, stateCoachNotification) {
        return BlocBuilder<CommunityTabFriendNotificationBloc, CommunityTabFriendNotificationState>(
          builder: (context, state) {
            bool friendNotification = state is CommunityTabFriendsNotification && state.friendNotifications.isNotEmpty;
            if (olukoBottomNavigationBarItem.route == RouteEnum.friends || olukoBottomNavigationBarItem.route == RouteEnum.coach) {
              return BlocBuilder<ChatSliderMessagesBloc, ChatSliderMessagesState>(
                builder: (context, state) {
                  bool chatNotification = state is MessagesNotificationUpdated && state.quantity > 0;
                  bool hasFriendNotification = friendNotification || chatNotification;
                  bool hasCoachNotification = stateCoachNotification is CoachTabNotification &&
                      (stateCoachNotification.annotationsNotViewed.isNotEmpty ||
                          stateCoachNotification.recommendationsNotViewed.isNotEmpty ||
                          stateCoachNotification.welcomeVideoNotSeen ||
                          stateCoachNotification.coachVideoMessagesNotViewed.isNotEmpty);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ImageIcon(
                        AssetImage(olukoBottomNavigationBarItem.selected && olukoBottomNavigationBarItem.selectedAssetImageUrl != null
                            ? olukoBottomNavigationBarItem.selectedAssetImageUrl
                            : olukoBottomNavigationBarItem.disabledAssetImageUrl),
                        color: olukoBottomNavigationBarItem.selected && olukoBottomNavigationBarItem.selectedAssetImageUrl != null
                            ? OlukoColors.primary
                            : Colors.grey,
                      ),
                      if ((olukoBottomNavigationBarItem.route == RouteEnum.friends && hasFriendNotification) ||
                          (olukoBottomNavigationBarItem.route == RouteEnum.coach && hasCoachNotification))
                        Positioned(
                          top: 0,
                          left: 25,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            } else {
              return ImageIcon(
                AssetImage(olukoBottomNavigationBarItem.selected && olukoBottomNavigationBarItem.selectedAssetImageUrl != null
                    ? olukoBottomNavigationBarItem.selectedAssetImageUrl
                    : olukoBottomNavigationBarItem.disabledAssetImageUrl),
                color: olukoBottomNavigationBarItem.selected && olukoBottomNavigationBarItem.selectedAssetImageUrl != null ? OlukoColors.primary : Colors.grey,
              );
            }
          },
        );
      },
    );
  }

  BottomNavigationBarItem getBottomNavigationBarWidget(OlukoBottomNavigationBarItem olukoBottomNavigationBarItem) {
    double blockSize = MediaQuery.of(context).orientation == Orientation.portrait ? ScreenUtils.width(context) / 5 : ScreenUtils.width(context) / 5;
    return BottomNavigationBarItem(icon: buildBottomNavigationItem(olukoBottomNavigationBarItem, blockSize), label: '');
  }

  Widget buildBottomNavigationItem(OlukoBottomNavigationBarItem olukoBottomNavigationBarItem, double blockSize) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? BlocBuilder<ProfileAvatarBloc, ProfileAvatarState>(
            builder: (context, state) {
              if (state is ProfileAvatarSuccess) {
                userInformation.avatar = state.updatedUser.avatarThumbnail ?? state.updatedUser.avatar;
                // return _getUserInformationComponent(userToDisplay: currentUserLatestVersion);
              }
              return Container(
                  child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
                    ),
                    width: blockSize,
                    height: MediaQuery.of(context).orientation == Orientation.portrait ? blockSize : blockSize / 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (olukoBottomNavigationBarItem.route == RouteEnum.profile)
                          if (userInformation?.avatar != null)
                            CachedNetworkImage(
                              width: 30,
                              height: 30,
                              maxWidthDiskCache: 100,
                              maxHeightDiskCache: 100,
                              fit: BoxFit.cover,
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                backgroundImage: imageProvider,
                                maxRadius: 15,
                              ),
                              imageUrl: userInformation.avatar,
                            )
                          else
                            CircleAvatar(
                              backgroundColor:
                                  userInformation != null ? OlukoColors.userColor(userInformation.firstName, userInformation.lastName) : OlukoColors.black,
                              radius: 15.0,
                              child: SizedBox(
                                width: 25,
                                height: 25,
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(userInformation != null ? userInformation.loadProfileDefaultPicContent() : '',
                                      style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500)),
                                ),
                              ),
                            ),
                        if (olukoBottomNavigationBarItem.route != RouteEnum.profile) _menuIcon(olukoBottomNavigationBarItem),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            !olukoBottomNavigationBarItem.selected ? '' : olukoBottomNavigationBarItem.title,
                            style: OlukoFonts.olukoSmallFont(
                                customColor: olukoBottomNavigationBarItem.disabled
                                    ? Colors.grey.shade800
                                    : olukoBottomNavigationBarItem.selected
                                        ? OlukoColors.primary
                                        : Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ));
            },
          )
        : Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white24, width: 1)),
              color: olukoBottomNavigationBarItem.selected ? OlukoColors.primary : OlukoColors.black,
            ),
            width: blockSize,
            height: MediaQuery.of(context).orientation == Orientation.portrait ? blockSize : blockSize / 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageIcon(AssetImage(olukoBottomNavigationBarItem.selectedAssetImageUrl),
                    color: olukoBottomNavigationBarItem.disabled ? Colors.grey.shade800 : null),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    olukoBottomNavigationBarItem.title,
                    style: TextStyle(
                        color: olukoBottomNavigationBarItem.disabled
                            ? Colors.grey.shade800
                            : olukoBottomNavigationBarItem.selected
                                ? OlukoColors.black
                                : Colors.white),
                  ),
                )
              ],
            ),
          );
  }

  List<OlukoBottomNavigationBarItem> getBottomNavigationBarItems() {
    List<OlukoBottomNavigationBarItem> items = [
      OlukoBottomNavigationBarItem(
          title: OlukoLocalizations.get(context, 'home'),
          disabledAssetImageUrl: 'assets/bottom_navigation_bar/home.png',
          route: RouteEnum.root,
          selectedAssetImageUrl: 'assets/bottom_navigation_bar/selected_home.png'),
      OlukoBottomNavigationBarItem(
          title: OlukoLocalizations.get(context, 'coach'),
          disabledAssetImageUrl:
              OlukoNeumorphism.isNeumorphismDesign ? 'assets/bottom_navigation_bar/coach_neumorphic.png' : 'assets/bottom_navigation_bar/coach.png',
          selectedAssetImageUrl: 'assets/bottom_navigation_bar/selected_coach.png',
          route: RouteEnum.coach),
      //TODO: Item for testing (remove it later)
      /*OlukoBottomNavigationBarItem(
          title: "TEST",
          assetImageUrl: 'assets/bottom_navigation_bar/coach.png',
          route: '/segment-progress'),*/
      OlukoBottomNavigationBarItem(
          title: OlukoLocalizations.get(context, 'courses'),
          disabledAssetImageUrl:
              OlukoNeumorphism.isNeumorphismDesign ? 'assets/bottom_navigation_bar/course_neumorphic.png' : 'assets/bottom_navigation_bar/course.png',
          selectedAssetImageUrl: 'assets/bottom_navigation_bar/selected_courses.png',
          route: RouteEnum.courses),
      OlukoBottomNavigationBarItem(
        title: OlukoLocalizations.get(context, 'community'),
        disabledAssetImageUrl:
            OlukoNeumorphism.isNeumorphismDesign ? 'assets/bottom_navigation_bar/friends_neumorphic.png' : 'assets/bottom_navigation_bar/friends.png',
        selectedAssetImageUrl: 'assets/bottom_navigation_bar/selected_friends.png',
        route: RouteEnum.friends,
      ),
      OlukoBottomNavigationBarItem(
          title: OlukoLocalizations.get(context, 'profile'), selectedAssetImageUrl: 'assets/bottom_navigation_bar/profile.png', route: RouteEnum.profile),
    ];
    return items;
  }

  getIndexFromRoute() {
    String routeName = ModalRoute.of(context).settings.name;
    num routeIndex;
    getBottomNavigationBarItems().asMap().forEach((key, value) {
      if (value.route == routeName) {
        routeIndex = key;
      }
    });
    return routeIndex;
  }

  List<BottomNavigationBarItem> getNavigationBarWidgets({int selectedIndex = 0}) {
    List<OlukoBottomNavigationBarItem> items = getBottomNavigationBarItems();
    items[selectedIndex].selected = true;
    return items.map((item) => getBottomNavigationBarWidget(item)).toList();
  }
}
