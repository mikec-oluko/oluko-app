import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/friend_modal_content.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/user_utils.dart';

class MessageBubble extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String userImage;
  final String authUserId;
  final String messageText;
  final bool isCurrentUser;
  final UserResponse user;

  const MessageBubble({
    @required this.firstName,
    @required this.lastName,
    @required this.userImage,
    @required this.authUserId,
    @required this.messageText,
    @required this.isCurrentUser,
    @required this.user,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            GestureDetector(onTap: () => friendModal(context), child: _buildUserAvatar()),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: _buildMessageContainer(),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8.0),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  friendModal(BuildContext context) {
    BottomDialogUtils.showBottomDialog(
      content: FriendModalContent(
          user,
          authUserId,
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

  Widget _buildUserAvatar() {
    final double avatarRadius = 16;
    return userImage == null
        ? UserUtils.avatarImageDefault(
            maxRadius: avatarRadius,
            name: firstName,
            lastname: lastName,
          )
        : CircleAvatar(
            backgroundImage: NetworkImage(userImage),
            radius: avatarRadius,
          );
  }

  Widget _buildMessageContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 87, 87, 87),
        borderRadius: isCurrentUser
            ? const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              )
            : const BorderRadius.only(
                topRight: Radius.circular(12.0),
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              ),
      ),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isCurrentUser ? 'You' : '$firstName $lastName',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            messageText,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
