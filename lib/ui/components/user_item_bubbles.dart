import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/friend_modal_content.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';

class UserItemBubbles extends StatefulWidget {
  final List<UserResponse> content;
  final double width;
  final String currentUserId;
  final Map<String, UserProgress> usersProgess;
  UserProgressListBloc userProgressListBloc;

  UserItemBubbles({this.userProgressListBloc, this.content, this.width, this.currentUserId, this.usersProgess});
  @override
  _UserItemBubblesState createState() => _UserItemBubblesState();
}

class _UserItemBubblesState extends State<UserItemBubbles> {
  Map<String, UserProgress> _usersProgress = {};
  List<UserResponse> _growingUserList = [];
  final _listController = ScrollController();
  final int _batchMaxRange = 10;

  @override
  void initState() {
    _usersProgress = widget.usersProgess;
    widget.userProgressListBloc.get(widget.currentUserId);

    _growingUserList =
        widget.content.isNotEmpty ? [...widget.content.getRange(0, widget.content.length > _batchMaxRange ? _batchMaxRange : widget.content.length)] : [];
    _listController.addListener(() {
      if (_listController.position.atEdge) {
        if (_listController.position.pixels > 0) {
          if (_growingUserList.length != widget.content.length) {
            _getMoreUsers();
            setState(() {});
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  void _getMoreUsers() => _growingUserList = widget.content.isNotEmpty
      ? [
          ...widget.content
              .getRange(0, widget.content.length > _growingUserList.length + _batchMaxRange ? _growingUserList.length + _batchMaxRange : widget.content.length)
        ]
      : [];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: widget.width,
      child: scrollableBubbles(),
    );
  }

  Widget scrollableBubbles() {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.center,
          colors: [Colors.black, Colors.transparent],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: SingleChildScrollView(scrollDirection: Axis.horizontal, controller: _listController, child: buildBubbles()),
    );
  }

  List<Widget> buildUserItems() {
    List<Widget> users =
        _growingUserList.map((user) => _imageItem(context, user?.avatar, user?.username, itemUser: user, currentUserId: widget.currentUserId)).toList();

    if (users != null && users.isNotEmpty) {
      users.add(
        const SizedBox(
          width: 180,
        ),
      );
    }
    return users;
  }

  Widget buildBubbles() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: buildUserItems());
  }

  Widget buildBubbleGrid() {
    return GridView.count(crossAxisCount: 6, children: buildUserItems());
  }

  Widget _imageItem(BuildContext context, String imageUrl, String username, {String currentUserId, UserResponse itemUser}) {
    return BlocListener<UserProgressStreamBloc, UserProgressStreamState>(
        listener: (context, userProgressStreamState) {
          blocConsumerCondition(userProgressStreamState);
        },
        child: SizedBox(
          width: 85,
          height: 100,
          child: GestureDetector(
            onTap: () => BottomDialogUtils.showBottomDialog(
              content: FriendModalContent(
                  itemUser,
                  currentUserId,
                  _usersProgress,
                  BlocProvider.of<FriendBloc>(context),
                  BlocProvider.of<FriendRequestBloc>(context),
                  BlocProvider.of<HiFiveSendBloc>(context),
                  BlocProvider.of<HiFiveReceivedBloc>(context),
                  BlocProvider.of<UserStatisticsBloc>(context),
                  BlocProvider.of<FavoriteFriendBloc>(context),
                  BlocProvider.of<UserProgressStreamBloc>(context)),
              context: context,
            ),
            child: Column(
              children: [
                StoriesItem(
                  showUserProgress: true,
                  userProgress: _usersProgress[itemUser?.id],
                  from: StoriesItemFrom.longPressHome,
                  maxRadius: 25,
                  imageUrl: imageUrl,
                  currentUserId: currentUserId,
                  itemUserId: itemUser?.id,
                  name: itemUser?.firstName,
                ),
                Text(
                  username ?? itemUser?.username ?? '',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor),
                )
              ],
            ),
          ),
        ));
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
