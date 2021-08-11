import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';

class FriendRequestCard extends StatefulWidget {
  // final UserResponse userToDisplay;
  // final User userData;
  // FriendRequestCard({this.userToDisplay, this.userData});

  //Demo data
  final String name;
  final String lastName;
  final String userName;
  final String imageUser;
  FriendRequestCard({this.name, this.lastName, this.userName, this.imageUser});
  @override
  _FriendRequestCardState createState() => _FriendRequestCardState();
}

/**
 * TODO:
 * List of user from Friends bloc
 * get data to display (firstName, LastName, image)
 * attribute to set star button 
 */

class _FriendRequestCardState extends State<FriendRequestCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: OlukoColors.black,
          border: Border(
              bottom: BorderSide(width: 1.0, color: OlukoColors.grayColor))),
      height: 120,
      child: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    // backgroundImage: NetworkImage(widget.userData.photoURL),
                    backgroundImage: NetworkImage(widget.imageUser),
                    backgroundColor: Colors.red,
                    radius: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              // widget.userToDisplay.firstName,
                              widget.name,
                              style: OlukoFonts.olukoMediumFont(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                  // widget.userToDisplay.lastName,
                                  widget.lastName,
                                  style: OlukoFonts.olukoMediumFont()),
                            ),
                          ],
                        ),
                        Text(
                            // widget.userData.displayName,
                            widget.userName,
                            style: OlukoFonts.olukoMediumFont(
                                customColor: OlukoColors.grayColor)),
                      ],
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 30,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Confirm",
                          style: OlukoFonts.olukoMediumFont(
                              customColor: OlukoColors.black),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(OlukoColors.primary),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Container(
                        width: 120,
                        height: 30,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(color: OlukoColors.grayColor)),
                            onPressed: () {},
                            child: Text("Ignore",
                                style: OlukoFonts.olukoMediumFont(
                                    customColor: OlukoColors.grayColor))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
