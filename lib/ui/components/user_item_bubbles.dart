import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/stories_item.dart';

class UserItemBubbles extends StatefulWidget {
  final List<UserResponse> content;
  final double width;
  final Function(BuildContext, UserResponse) onPressed;
  final String currentUserId;
  UserItemBubbles({this.content, this.width, this.onPressed, this.currentUserId});
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

  List<Widget> buildMovementItems() {
    List<Widget> users = widget.content
        .map((user) => _imageItem(context, user.avatarThumbnail, user.username,
            onPressed: (context) => widget.onPressed(context, user), itemUser: user, currentUserId: widget.currentUserId))
        .toList();
    return users;
  }

  Widget buildBubbles() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildMovementItems()
          //Prevent the last item to be overlayed by the carousel gradient
          ..add(const SizedBox(
            width: 180,
          )));
  }

  Widget buildBubbleGrid() {
    return GridView.count(crossAxisCount: 6, children: buildMovementItems());
  }

  Widget _imageItem(BuildContext context, String imageUrl, String username,
      {Function(BuildContext) onPressed, String currentUserId, UserResponse itemUser}) {
    return GestureDetector(
      onTap: () => onPressed(context),
      child: SizedBox(
        width: 85,
        height: 100,
        child: GestureDetector(
          onLongPress: () => _openUserModal(itemUser),
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
                itemUserId: itemUser.id,
                name: itemUser.firstName,
              ),
              Text(
                username,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openUserModal(UserResponse itemUser) {
    
  }
}
