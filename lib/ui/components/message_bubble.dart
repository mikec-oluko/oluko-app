import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/utils/user_utils.dart';

class MessageBubble extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String userImage;
  final String messageText;
  final bool isCurrentUser;

  const MessageBubble({
    @required this.firstName,
    @required this.lastName,
    @required this.userImage,
    @required this.messageText,
    @required this.isCurrentUser,
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
            _buildUserAvatar(),
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
