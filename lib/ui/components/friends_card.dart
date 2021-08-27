import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/user_response.dart';

class FriendCard extends StatefulWidget {
  // final UserResponse userToDisplay;
  // final User userData;
  // FriendCard({this.userToDisplay, this.userData});
  final UserResponse friendUser;
  final FriendModel friend;
  Function(FriendModel) onFavoriteToggle;
  FriendCard({this.friendUser, this.friend, this.onFavoriteToggle});
  @override
  _FriendCardState createState() => _FriendCardState();
}

/**
 * TODO:
 * List of user from Friends bloc
 * get data to display (firstName, LastName, image)
 * attribute to set star button 
 */

class _FriendCardState extends State<FriendCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: OlukoColors.black,
          border: Border(
              bottom: BorderSide(width: 1.0, color: OlukoColors.grayColor))),
      height: 100,
      child: Padding(
        padding: const EdgeInsets.only(left: 5),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              CircleAvatar(
                // backgroundImage: NetworkImage(widget.userData.photoURL),
                backgroundImage: NetworkImage(widget.friendUser.avatar),
                backgroundColor: Colors.red,
                radius: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Text(
                              // widget.userToDisplay.firstName,
                              widget.friendUser.firstName,
                              style: OlukoFonts.olukoMediumFont(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              // child: Text(widget.userToDisplay.lastName,
                              //     style: OlukoFonts.olukoMediumFont()),
                              child: Text(widget.friendUser.lastName,
                                  style: OlukoFonts.olukoMediumFont()),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(widget.friendUser.username,
                        style: OlukoFonts.olukoMediumFont(
                            customColor: OlukoColors.grayColor)),
                    // Text(widget.userData.displayName,
                    //     style: OlukoFonts.olukoMediumFont(
                    //         customColor: OlukoColors.grayColor)),
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  icon: Icon(
                    widget.friend.isFavorite != null && widget.friend.isFavorite
                        ? Icons.star
                        : Icons.star_outline,
                    color: OlukoColors.primary,
                  ),
                  onPressed: () {
                    this.setState(() {
                      if (widget.friend.isFavorite == null) {
                        widget.friend.isFavorite = false;
                      }
                      widget.friend.isFavorite = !widget.friend.isFavorite;
                      widget.onFavoriteToggle(widget.friend);
                    });
                  }),
            ],
          )
        ]),
      ),
    );
  }
}
