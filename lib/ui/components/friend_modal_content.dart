import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class FriendModalContent extends StatefulWidget {
  String currentUserId;
  UserResponse user;
  FriendBloc blocFriends;
  FriendRequestBloc friendRequestBloc;
  HiFiveSendBloc blocHifiveSend;
  HiFiveReceivedBloc blocHifiveReceived;
  UserStatisticsBloc blocUserStatistics;
  FavoriteFriendBloc blocFavoriteFriend;
  FriendModalContent(
    this.user,
    this.currentUserId,
    this.blocFriends,
    this.friendRequestBloc,
    this.blocHifiveSend,
    this.blocHifiveReceived,
    this.blocUserStatistics,
    this.blocFavoriteFriend,
  );
  @override
  _FriendModalContentState createState() => _FriendModalContentState();
}

class _FriendModalContentState extends State<FriendModalContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.blocFriends.getFriendsByUserId(widget.currentUserId);
    widget.blocHifiveReceived.get(context, widget.user.id, widget.currentUserId);
    widget.blocUserStatistics.getUserStatistics(widget.user.id);
    return BlocListener<FavoriteFriendBloc, FavoriteFriendState>(
      bloc: widget.blocFavoriteFriend,
      listener: (favoriteFriendContext, favoriteState) {
        _handleFriendFavoriteState(favoriteState);
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Container(
      height: ScreenUtils.height(context) * 0.47,
      width: ScreenUtils.width(context),
      decoration: const BoxDecoration(
        borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(20)),
        image: DecorationImage(
          image: AssetImage('assets/courses/dialog_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          children: [
            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: StoriesItem(
                    maxRadius: 40,
                    imageUrl: widget.user.avatarThumbnail ?? widget.user.avatar,
                    name: widget.user.firstName,
                    lastname: widget.user.lastName,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.user.firstName} ${widget.user.lastName}',
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.w700),
                        ),
                        _getUserInfo()
                      ],
                    ),
                  ),
                ),
                BlocBuilder<HiFiveReceivedBloc, HiFiveReceivedState>(
                  bloc: widget.blocHifiveReceived,
                  builder: (hiFiveReceivedContext, hiFiveReceivedState) {
                    return widget.user.privacy == 0
                        ? Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    widget.blocHifiveSend.set(context, widget.currentUserId, widget.user.id);
                                    AppMessages().showHiFiveSentDialog(context);
                                  },
                                  child: BlocListener<HiFiveSendBloc, HiFiveSendState>(
                                    bloc: widget.blocHifiveSend,
                                    listener: (hiFiveSendContext, hiFiveSendState) {
                                      if (hiFiveSendState is HiFiveSendSuccess) {
                                        AppMessages.clearAndShowSnackbar(
                                          context,
                                          hiFiveSendState.hiFive
                                              ? OlukoLocalizations.get(context, 'hiFiveSent')
                                              : OlukoLocalizations.get(context, 'hiFiveRemoved'),
                                        );
                                      }
                                      if (hiFiveSendState is HiFiveSendSuccess) {
                                        widget.blocHifiveReceived.get(context, widget.user.id, widget.currentUserId);
                                      }
                                    },
                                    child: SizedBox(width: 80, height: 80, child: Image.asset('assets/profile/hiFive.png')),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox();
                  },
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: OlukoNeumorphicDivider(
                isFadeOut: true,
              ),
            ),
            Expanded(
              child: BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
                bloc: widget.blocUserStatistics,
                builder: (userStatisticsContext, userStats) {
                  return userStats is StatisticsSuccess && widget.user.privacy == 0
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                profileAccomplishments(
                                  achievementTitle: OlukoLocalizations.get(context, 'challengesCompleted'),
                                  achievementValue: userStats.userStats.completedChallenges.toString(),
                                ),
                                Container(
                                  width: 2.5,
                                  height: 2.5,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                                  ),
                                ),
                                profileAccomplishments(
                                  achievementTitle: OlukoLocalizations.get(context, 'coursesCompleted'),
                                  achievementValue: userStats.userStats.completedCourses.toString(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            profileAccomplishments(
                              achievementTitle: OlukoLocalizations.get(context, 'classesCompleted'),
                              achievementValue: userStats.userStats.completedClasses.toString(),
                            ),
                          ],
                        )
                      : const SizedBox();
                },
              ),
            ),
            BlocBuilder<FriendBloc, FriendState>(
              bloc: widget.blocFriends,
              builder: (context, friendState) {
                final bool userIsFriend =
                    friendState is GetFriendsSuccess && friendState.friendUsers.map((e) => e.id).toList().contains(widget.user.id);
                final bool connectionRequested = friendState is GetFriendsSuccess &&
                    friendState.friendData.friendRequestSent.map((f) => f.id).toList().contains(widget.user.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Visibility(
                        visible:
                            friendState is GetFriendsSuccess && friendState.friendUsers.map((e) => e.id).toList().contains(widget.user.id),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: OlukoNeumorphicSecondaryButton(
                            title: '',
                            isExpanded: false,
                            onPressed: () {
                              if (friendState is GetFriendsSuccess) {
                                final bool userIsFriend = friendState.friendUsers.map((e) => e.id).toList().contains(widget.user.id);
                                final FriendModel friendModel =
                                    friendState.friendData.friends.where((element) => element.id == widget.user.id).first;
                                if (userIsFriend) {
                                  widget.blocFavoriteFriend.favoriteFriend(context, friendState.friendData, friendModel);
                                }
                              }
                            },
                            icon: SizedBox(
                              height: 25,
                              width: 25,
                              child: Image.asset(
                                friendState is GetFriendsSuccess &&
                                        friendState.friendData.friends.where((e) => e.id == widget.user.id).toList().isNotEmpty &&
                                        friendState.friendData.friends.where((e) => e.id == widget.user.id).toList()[0].isFavorite
                                    ? 'assets/icon/heart_filled.png'
                                    : 'assets/icon/heart.png',
                              ),
                            ),
                            onlyIcon: true,
                          ),
                        ),
                      ),
                      _getButtons(connectionRequested, friendState, userIsFriend),
                      _getViewProfileButton(userIsFriend),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget profileAccomplishments({String achievementTitle, String achievementValue}) {
    return Row(
      children: [
        Text(
          achievementValue,
          style: OlukoFonts.olukoBigFont(),
        ),
        const SizedBox(width: 8),
        Text(
          achievementTitle,
          style: OlukoFonts.olukoMediumFont(customColor: Colors.grey),
        ),
      ],
    );
  }

  Widget _getUserInfo() {
    if (widget.user.privacy == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            UserHelper.printUsername(widget.user.username, widget.user.id),
            style: OlukoFonts.olukoMediumFont(customColor: Colors.grey),
          ),
          _getUserLocation(),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          OlukoLocalizations.get(context, 'private').toLowerCase(),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
  }

  Widget _getUserLocation() {
    String city = '';
    String country = '';
    if (widget.user.city != null && widget.user.city != 'null') {
      city = widget.user.city;
    }
    if (widget.user.country != null && widget.user.country != 'null') {
      if (city != null) {
        country = ', ';
      }
      country += widget.user.country;
    }
    if (city.isEmpty && country.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Text(
            city,
            style: const TextStyle(color: OlukoColors.primary, fontSize: 15),
          ),
          Text(
            country,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          )
        ],
      ),
    );
  }

  void _handleFriendFavoriteState(FavoriteFriendState favoriteState) {
    if (favoriteState is FavoriteFriendSuccess) {
      widget.blocFriends.getFriendsByUserId(widget.currentUserId);
      AppMessages.clearAndShowSnackbar(context, 'Friend updated.');
    } else if (favoriteState is FavoriteFriendFailure) {
      AppMessages.clearAndShowSnackbar(context, 'Error updating Friend.');
    }
  }

  void _showRemoveConfirmationPopup(Friend friend) {
    BottomDialogUtils.showBottomDialog(
      content: Container(
        height: ScreenUtils.height(context) * 0.3,
        decoration: const BoxDecoration(
          borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(20)),
          image: DecorationImage(
            image: AssetImage('assets/courses/dialog_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      OlukoLocalizations.get(context, 'removeThisPerson'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      OlukoLocalizations.get(context, 'removeThisPersonBody1') +
                          widget.user.username +
                          OlukoLocalizations.get(context, 'removeThisPersonBody2'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 80,
                          child: OlukoNeumorphicSecondaryButton(
                            isExpanded: false,
                            thinPadding: true,
                            textColor: Colors.grey,
                            onPressed: () => Navigator.pop(context),
                            title: OlukoLocalizations.get(context, 'no'),
                          ),
                        ),
                        const SizedBox(width: 25),
                        SizedBox(
                          width: 80,
                          child: OlukoNeumorphicPrimaryButton(
                            isExpanded: false,
                            thinPadding: true,
                            onPressed: () {
                              widget.blocFriends.removeFriend(widget.currentUserId, friend, widget.user.id);
                              Navigator.pop(context);
                            },
                            title: OlukoLocalizations.get(context, 'yes'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      context: context,
    );
  }

  Widget _getButtons(bool connectionRequested, FriendState friendState, bool userIsFriend) {
    if (connectionRequested) {
      return Container(
        width: 115,
        alignment: Alignment.topRight,
        child: OlukoNeumorphicPrimaryButton(
          isExpanded: false,
          thinPadding: true,
          title: OlukoLocalizations.of(context).find('cancel'),
          onPressed: () {
            if (friendState is GetFriendsSuccess) {
              widget.friendRequestBloc.removeRequestSent(widget.currentUserId, friendState.friendData, widget.user.id);
            }
          },
        ),
      );
    } else if (userIsFriend) {
      return SizedBox(
        width: 115,
        child: OlukoNeumorphicSecondaryButton(
          thinPadding: true,
          isExpanded: false,
          textColor: Colors.grey,
          title: OlukoLocalizations.of(context).find('remove'),
          onPressed: () {
            if (friendState is GetFriendsSuccess) {
              _showRemoveConfirmationPopup(friendState.friendData);
            }
          },
        ),
      );
    } else {
      return Container(
        width: 115,
        alignment: Alignment.topRight,
        child: OlukoNeumorphicPrimaryButton(
          isExpanded: false,
          thinPadding: true,
          title: OlukoLocalizations.of(context).find('connect'),
          onPressed: () {
            if (friendState is GetFriendsSuccess) {
              widget.friendRequestBloc.sendRequestOfConnect(widget.currentUserId, friendState.friendData, widget.user.id);
            }
          },
        ),
      );
    }
  }

  Widget _getViewProfileButton(bool userIsFriend) {
    if (widget.user.privacy == 0) {
      return SizedBox(
        width: 115,
        child: OlukoNeumorphicPrimaryButton(
          isExpanded: false,
          thinPadding: true,
          title: OlukoLocalizations.of(context).find('viewProfile'),
          onPressed: () {
            Navigator.pushNamed(
              context,
              routeLabels[RouteEnum.profileViewOwnProfile],
              arguments: {'userRequested': widget.user, 'isFriend': userIsFriend},
            );
          },
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
