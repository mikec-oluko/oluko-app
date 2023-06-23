import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/friend_modal_content.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/user_utils.dart';

class ModalPeopleEnrolled extends StatefulWidget {
  String userId;
  List<dynamic> users;
  List<dynamic> favorites;
  UserProgressListBloc userProgressListBloc;
  UserProgressStreamBloc userProgressStreamBloc;
  FriendBloc blocFriends;
  FriendRequestBloc friendRequestBloc;
  HiFiveSendBloc blocHifiveSend;
  HiFiveReceivedBloc blocHifiveReceived;
  UserStatisticsBloc blocUserStatistics;
  FavoriteFriendBloc blocFavoriteFriend;
  Map<String, UserProgress> usersProgess;
  PointsCardBloc blocPointsCard;

  ModalPeopleEnrolled(
      {this.userId,
      this.userProgressListBloc,
      this.userProgressStreamBloc,
      this.users,
      this.favorites,
      this.blocFriends,
      this.friendRequestBloc,
      this.blocHifiveSend,
      this.blocHifiveReceived,
      this.blocUserStatistics,
      this.blocFavoriteFriend,
      this.blocPointsCard});

  @override
  _ModalPeopleEnrolledState createState() => _ModalPeopleEnrolledState();
}

class _ModalPeopleEnrolledState extends State<ModalPeopleEnrolled> {
  Map<String, UserProgress> _usersProgress = {};
  List<UserSubmodel> _usersSubModelList = [];
  List<UserResponse> _userResponseList = [];

  @override
  void initState() {
    widget.userProgressListBloc.get(widget.userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        gradient: OlukoNeumorphism.olukoNeumorphicGradientDark(),
      ),
      width: MediaQuery.of(context).size.width,
      height: 150,
      child: BlocConsumer<UserProgressListBloc, UserProgressListState>(
          bloc: widget.userProgressListBloc,
          listener: (context, userProgressListState) {
            if (userProgressListState is GetUserProgressSuccess) {
              setState(() {
                _usersProgress = userProgressListState.usersProgress;
              });
            }
          },
          builder: (context, userProgressListState) {
            return body();
          }),
    );
  }

  Widget body() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          physics: OlukoNeumorphism.listViewPhysicsEffect,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: TitleBody(OlukoLocalizations.get(context, 'favorites')),
                ),
              ],
            ),
            usersGrid(widget.favorites),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: TitleBody(OlukoLocalizations.get(context, 'everyoneElse')),
                ),
              ],
            ),
            BlocListener<UserProgressStreamBloc, UserProgressStreamState>(
                listener: (context, userProgressStreamState) {
                  blocConsumerCondition(userProgressStreamState);
                },
                child: usersGrid(widget.users))
          ],
        ));
  }

  Widget usersGrid(List<dynamic> users) {
    if (users != null && users.isNotEmpty) {
      return GridView.count(
          childAspectRatio: 0.7,
          crossAxisCount: 4,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: users
              .map((user) => GridTile(
                    child: GestureDetector(
                      onTap: () => showFriendModal(user),
                      child: Column(
                        children: [
                          StoriesItem(
                            showUserProgress: true,
                            userProgressStreamBloc: widget.userProgressStreamBloc,
                            userProgress: _usersProgress[user.id],
                            itemUserId: user.id?.toString() ?? '',
                            name: (() {
                              if (user.username != null) {
                                return UserHelper.printUsername(user.username.toString(), user.id.toString());
                              } else {
                                return user.firstName?.toString() ?? '';
                              }
                            })(),
                            currentUserId: widget.userId,
                            maxRadius: 35,
                            imageUrl: user.getAvatarThumbnail()?.toString(),
                            stories: user is UserSubmodel && user.stories?.stories != null ? user.stories.stories : [],
                          ),
                          Text(user.getFullName()?.toString(),
                              textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: OlukoFonts.olukoMediumFont()),
                          const SizedBox(height: 1),
                          Text(user.username?.toString() ?? '', style: OlukoFonts.olukoSmallFont(customColor: Colors.grey), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ))
              .toList());
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: TitleBody(
            OlukoLocalizations.get(context, 'noUsers'),
            customColor: OlukoColors.grayColor,
          ),
        ),
      );
    }
  }

  showFriendModal(dynamic friendUser) {
    if (friendUser is UserResponse) {
      BottomDialogUtils.showBottomDialog(
        content: FriendModalContent(friendUser, widget.userId, _usersProgress, widget.blocFriends, widget.friendRequestBloc, widget.blocHifiveSend,
            widget.blocHifiveReceived, widget.blocUserStatistics, widget.blocFavoriteFriend, widget.blocPointsCard, widget.userProgressStreamBloc),
        context: context,
      );
    }
  }

  void blocConsumerCondition(UserProgressStreamState userProgressStreamState) {
    if (userProgressStreamState is UserProgressUpdate) {
      setState(() {
        _usersProgress[userProgressStreamState.obj.id] = userProgressStreamState.obj;
      });
    } else if (userProgressStreamState is UserProgressAdd) {
      setState(() {
        _usersProgress[userProgressStreamState.obj.id] = userProgressStreamState.obj;
      });
    } else if (userProgressStreamState is UserProgressRemove) {
      setState(() {
        _usersProgress[userProgressStreamState.obj.id].progress = 0;
      });
    }
  }
}
