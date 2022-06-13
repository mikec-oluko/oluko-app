import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
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

  ModalPeopleEnrolled({this.userId, this.userProgressListBloc, this.userProgressStreamBloc, this.users, this.favorites});

  @override
  _ModalPeopleEnrolledState createState() => _ModalPeopleEnrolledState();
}

class _ModalPeopleEnrolledState extends State<ModalPeopleEnrolled> {
  Map<String, UserProgress> _usersProgess = {};

  @override
  void initState() {
    widget.userProgressListBloc.get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/courses/gray_background.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      width: MediaQuery.of(context).size.width,
      height: 150,
      child: BlocConsumer<UserProgressListBloc, UserProgressListState>(
          bloc: widget.userProgressListBloc,
          listener: (context, userProgressListState) {
            if (userProgressListState is GetUserProgressSuccess) {
              setState(() {
                _usersProgess = userProgressListState.usersProgress;
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
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ListView(
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
            usersGrid(widget.users)
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
                            userProgress: _usersProgess[user.id],
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
                            imageUrl: user.avatar.toString(),
                            stories: user is UserSubmodel && user.stories?.stories != null ? user.stories.stories : [],
                          ),
                          Text('${user.firstName ?? ''} ${user.lastName ?? ''}',
                              textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: OlukoFonts.olukoMediumFont()),
                          const SizedBox(height: 1),
                          Text(user.username?.toString() ?? '',
                              style: OlukoFonts.olukoSmallFont(customColor: Colors.grey), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ))
              .toList());
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: TitleBody(OlukoLocalizations.get(context, 'noUsers')),
        ),
      );
    }
  }

  showFriendModal(dynamic friendUser) {
    if (friendUser is UserResponse) {
      BottomDialogUtils.showBottomDialog(
        content: FriendModalContent(
            friendUser,
            widget.userId,
            null,
            BlocProvider.of<FriendBloc>(context),
            BlocProvider.of<FriendRequestBloc>(context),
            BlocProvider.of<HiFiveSendBloc>(context),
            BlocProvider.of<HiFiveReceivedBloc>(context),
            BlocProvider.of<UserStatisticsBloc>(context),
            BlocProvider.of<FavoriteFriendBloc>(context),
            BlocProvider.of<UserProgressStreamBloc>(context)),
        context: context,
      );
    }
  }
}
