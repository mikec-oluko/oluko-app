import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
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
  UserProgressStreamBloc userProgressStreamBloc;
  Map<String, UserProgress> usersProgess;
  PointsCardBloc blocPointsCard;

  FriendModalContent(this.user, this.currentUserId, this.usersProgess, this.blocFriends, this.friendRequestBloc, this.blocHifiveSend, this.blocHifiveReceived,
      this.blocUserStatistics, this.blocFavoriteFriend, this.blocPointsCard,
      [this.userProgressStreamBloc]);
  @override
  _FriendModalContentState createState() => _FriendModalContentState();
}

class _FriendModalContentState extends State<FriendModalContent> {
  bool userIsFriend = false;
  bool connectionRequested = false;
  List<UserResponse> friendUsers = [];
  List<FriendModel> friendModelList = [];
  FriendModel friendModel;
  Friend friend;
  String _buttonTextContent = '';
  Widget friendButton = const SizedBox.shrink();
  @override
  void initState() {
    widget.blocFriends.getFriendsByUserId(widget.currentUserId);
    widget.blocHifiveReceived.get(context, widget.user.id, widget.currentUserId);
    widget.blocUserStatistics.getUserStatistics(widget.user.id);
    widget.blocPointsCard.getUserCards(widget.user.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            _getTopSection(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: OlukoNeumorphicDivider(
                isFadeOut: true,
              ),
            ),
            _getStatisticsSection(),
            BlocBuilder<FriendBloc, FriendState>(
              bloc: widget.blocFriends,
              builder: (context, friendState) {
                if (friendState is GetFriendsSuccess) {
                  friendUsers = friendState.friendUsers;
                  friend = friendState.friendData;
                  userIsFriend = friendUsers.where((friend) => friend.id == widget.user.id).toList().isNotEmpty;
                  friendModelList = friend.friends.where((element) => element.id == widget.user.id).toList();
                  friendModel = friendModelList.isNotEmpty ? friendModelList.first : null;
                  connectionRequested = friend.friendRequestSent.where((friendRequest) => friendRequest.id == widget.user.id).toList().isNotEmpty;
                  friendButton = _getLeftButton(connectionRequested, friendState, userIsFriend);
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: ScreenUtils.smallScreen(context) ? 3 : 35, left: userIsFriend ? 0 : 25, right: userIsFriend ? 0 : 25),
                  child: Row(
                    mainAxisAlignment: userIsFriend ? MainAxisAlignment.spaceAround : MainAxisAlignment.start,
                    children: [
                      Visibility(visible: userIsFriend, child: _getFavoriteButton()),
                      friendButton,
                      userIsFriend ? SizedBox() : Expanded(child: SizedBox()),
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

  Widget _getFavoriteButton() {
    return SizedBox(
      height: 50,
      width: 50,
      child: OlukoNeumorphicSecondaryButton(
        title: '',
        isExpanded: false,
        onPressed: () {
          if (userIsFriend && friendModel != null) {
            widget.blocFavoriteFriend.favoriteFriend(context, friend, friendModel);
          }
        },
        icon: SizedBox(
          height: 25,
          width: 25,
          child: Image.asset(
            friendModel != null && friendModel.isFavorite ? 'assets/icon/heart_filled.png' : 'assets/icon/heart.png',
          ),
        ),
        onlyIcon: true,
      ),
    );
  }

  Widget _getStatisticsSection() {
    return Expanded(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        profileAccomplishments(
                          achievementTitle: OlukoLocalizations.get(context, 'classesCompleted'),
                          achievementValue: userStats.userStats.completedClasses.toString(),
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
                        BlocBuilder<PointsCardBloc, PointsCardState>(
                          bloc: widget.blocPointsCard,
                          builder: (pointsCardContext, pointsCards) {
                            return pointsCards is PointsCardSuccess
                                ? profileAccomplishments(
                                    achievementTitle: OlukoLocalizations.get(context, 'mvt') + ' ' + OlukoLocalizations.get(context, 'points'),
                                    achievementValue: pointsCards.userPoints.toString(),
                                  )
                                : const SizedBox();
                          },
                        )
                      ],
                    )
                  ],
                )
              : const SizedBox();
        },
      ),
    );
  }

  Widget _getTopSection() {
    return Row(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: StoriesItem(
            showUserProgress: true,
            itemUserId: widget.user.id,
            userProgress: widget.usersProgess != null ? widget.usersProgess[widget.user.id] : null,
            maxRadius: 40,
            imageUrl: widget.user.getAvatarThumbnail(),
            name: widget.user.firstName,
            lastname: widget.user.lastName,
            userProgressStreamBloc: widget.userProgressStreamBloc,
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.user.getFullName(),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.w700),
                ),
                _getUserInfo()
              ],
            ),
          ),
        ),
        _getHiFive(),
      ],
    );
  }

  Widget _getHiFive() {
    return BlocBuilder<HiFiveReceivedBloc, HiFiveReceivedState>(
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
                              hiFiveSendState.hiFive ? OlukoLocalizations.get(context, 'hiFiveSent') : OlukoLocalizations.get(context, 'hiFiveRemoved'),
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
          if (GlobalService().showUserLocation) _getUserLocation(),
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
    String state = '';
    if (widget.user.city != null && widget.user.city != 'null') {
      city = widget.user.city;
    }
    if (widget.user.state != null && widget.user.state != 'null') {
      if (city != null) {
        state = ', ';
      }
      state += '${widget.user.state} ';
    }
    if (widget.user.country != null && widget.user.country != 'null') {
      country = widget.user.country;
    }
    if (city.isEmpty && country.isEmpty) {
      return const SizedBox();
    }
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Text(
              city,
              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary),
            ),
            Text(
              state,
              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor),
            ),
            Text(
              country,
              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor),
            )
          ],
        ),
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
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
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

  Widget _getLeftButton(bool connectionRequested, FriendState friendState, bool userIsFriend) {
    if (connectionRequested) {
      _buttonTextContent = OlukoLocalizations.of(context).find('connectionRequestCancelled');
      return Container(
        alignment: Alignment.topRight,
        child: OlukoNeumorphicPrimaryButton(
          isExpanded: false,
          title: _buttonTextContent,
          onPressed: () {
            if (friendState is GetFriendsSuccess) {
              widget.friendRequestBloc.removeRequestSent(widget.currentUserId, friendState.friendData, widget.user.id);
              setState(() {
                _buttonTextContent = OlukoLocalizations.of(context).find('connect');
              });
            }
          },
        ),
      );
    } else if (userIsFriend) {
      _buttonTextContent = OlukoLocalizations.of(context).find('remove');
      return SizedBox(
        child: OlukoNeumorphicSecondaryButton(
          isExpanded: false,
          textColor: Colors.grey,
          title: _buttonTextContent,
          onPressed: () {
            if (friendState is GetFriendsSuccess) {
              BottomDialogUtils.removeConfirmationPopup(widget.currentUserId, widget.user, friendState.friendData, context, widget.blocFriends);
              setState(() {
                _buttonTextContent = OlukoLocalizations.of(context).find('connect');
              });
            }
          },
        ),
      );
    } else {
      _buttonTextContent = OlukoLocalizations.of(context).find('connect');
      return Container(
        width: 115,
        alignment: Alignment.topRight,
        child: OlukoNeumorphicPrimaryButton(
          isExpanded: false,
          thinPadding: true,
          title: _buttonTextContent,
          onPressed: () {
            if (friendState is GetFriendsSuccess) {
              widget.friendRequestBloc.sendRequestOfConnect(widget.currentUserId, friendState.friendData, widget.user.id);
              setState(() {
                _buttonTextContent = OlukoLocalizations.of(context).find('connectionRequestCancelled');
              });
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
