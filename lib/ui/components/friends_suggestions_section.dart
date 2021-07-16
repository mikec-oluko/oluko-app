import 'package:flutter/material.dart';
import 'package:mvt_fitness/constants/Theme.dart';

class FriendSuggestionSection extends StatefulWidget {
  final String name;
  final String lastName;
  final String userName;
  final String imageUser;
  FriendSuggestionSection(
      {this.name, this.lastName, this.userName, this.imageUser});
  @override
  _FriendSuggestionSectionState createState() =>
      _FriendSuggestionSectionState();
}

/**
 * TODO: Need to recive list of firend suggestions, on friends_page show only one, whuen tap on view All show the full list.
 */

class _FriendSuggestionSectionState extends State<FriendSuggestionSection> {
  final String _suggestionText = "Suggestions For You";
  final String _viewAllText = "View All";

  //TODO: Use suggestionFriendList[0];
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(_suggestionText, style: OlukoFonts.olukoBigFont()),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  _viewAllText,
                  style: OlukoFonts.olukoMediumFont(
                      customColor: OlukoColors.primary),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
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
                  padding: const EdgeInsets.only(left: 10),
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
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
