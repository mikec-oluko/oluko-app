import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/friend_modal_content.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';

class UserItemBubbles extends StatefulWidget {
  final List<UserResponse> content;
  final double width;
  final String currentUserId;
  UserItemBubbles({this.content, this.width, this.currentUserId});
  @override
  _UserItemBubblesState createState() => _UserItemBubblesState();
}

class _UserItemBubblesState extends State<UserItemBubbles> {
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
      child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: buildBubbles()),
    );
  }

  List<Widget> buildUserItems() {
    List<Widget> users = widget.content
        .map((user) => _imageItem(context, user?.avatarThumbnail, user?.username, itemUser: user, currentUserId: widget.currentUserId))
        .toList();

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: buildUserItems(),
    );
  }

  Widget buildBubbleGrid() {
    return GridView.count(crossAxisCount: 6, children: buildUserItems());
  }

  Widget _imageItem(BuildContext context, String imageUrl, String username, {String currentUserId, UserResponse itemUser}) {
    return SizedBox(
      width: 85,
      height: 100,
      child: GestureDetector(
        onLongPress: () => BottomDialogUtils.showBottomDialog(
          content: FriendModalContent(
            itemUser,
            currentUserId,
            FriendBloc(),
            HiFiveSendBloc(),
            HiFiveReceivedBloc(),
            UserStatisticsBloc(),
            FavoriteFriendBloc(),
          ),
          context: context,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StoriesItem(
              from: StoriesItemFrom.longPressHome,
              maxRadius: 25,
              imageUrl: imageUrl,
              bloc: StoryListBloc(),
              getStories: true,
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
    );
  }
}
