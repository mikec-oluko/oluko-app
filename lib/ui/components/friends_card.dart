import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/user_utils.dart';

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
  bool _loadImageError = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: OlukoColors.black, border: Border(bottom: BorderSide(width: 1.0, color: OlukoColors.grayColor))),
      height: 100,
      child: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              CircleAvatar(
                  backgroundImage: getUserImg(widget.friendUser.avatarThumbnail),
                  onBackgroundImageError: _loadImageError
                      ? null
                      : (dynamic exception, StackTrace stackTrace) {
                          print("Error loading image! " + exception.toString());
                          setBackgroundImageAsError();
                        },
                  backgroundColor: OlukoColors.userColor(widget.friendUser.firstName, widget.friendUser.lastName),
                  radius: 30,
                  child: _loadImageError
                      ? Text(
                          widget.friendUser.firstName.characters.first.toString().toUpperCase(),
                          style: OlukoFonts.olukoBigFont(
                            customColor: OlukoColors.white,
                            custoFontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : const Text(' ')),
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
                              widget.friendUser.firstName ?? ' ',
                              style: OlukoFonts.olukoMediumFont(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              // child: Text(widget.userToDisplay.lastName,
                              //     style: OlukoFonts.olukoMediumFont()),
                              child: Text(widget.friendUser.lastName ?? ' ', style: OlukoFonts.olukoMediumFont()),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(UserHelper.printUsername(widget.friendUser.username, widget.friendUser.id) ?? '',
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor)),
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //Hidden star
              false //widget.friend != null
                  ? IconButton(
                      icon: Icon(
                        widget.friend != null && widget.friend.isFavorite != null && widget.friend.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: OlukoColors.primary,
                      ),
                      onPressed: () {
                        this.setState(() {
                          if (widget.friend != null) {
                            if (widget.friend.isFavorite == null) {
                              widget.friend.isFavorite = false;
                            }
                            widget.friend.isFavorite = !widget.friend.isFavorite;
                            widget.onFavoriteToggle(widget.friend);
                          }
                        });
                      })
                  : SizedBox(),
            ],
          )
        ]),
      ),
    );
  }

  void setBackgroundImageAsError() {
    setState(() {
      _loadImageError = true;
    });
  }

  ImageProvider<Object> getUserImg(String avatarUrl) {
    if (_loadImageError) {
      return null;
    } else if (avatarUrl == null) {
      setBackgroundImageAsError();
      return null;
    } else {
      return CachedNetworkImageProvider(avatarUrl);
    }
  }
}
