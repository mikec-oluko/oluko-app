import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/friends_request_card.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';

class FriendsRequestPage extends StatefulWidget {
  @override
  _FriendsRequestPageState createState() => _FriendsRequestPageState();
}

class _FriendsRequestPageState extends State<FriendsRequestPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: OlukoColors.black,
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column(
                //     children: widget.friends
                //         .map((friend) => FriendCard(
                //               userData: friend,
                //             ))
                //         .toList()),
                Column(
                  children: [FriendRequestCard(), FriendRequestCard()],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: OlukoOutlinedButton(
                    title: "See All Requests",
                    onPressed: () {},
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Suggestions For You",
                            style: OlukoFonts.olukoBigFont()),
                        Text(
                          "View all",
                          style: OlukoFonts.olukoMediumFont(
                              customColor: OlukoColors.primary),
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
                                          "Name",
                                          style: OlukoFonts.olukoMediumFont(),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Text(
                                              // widget.userToDisplay.lastName,
                                              "LastName",
                                              style:
                                                  OlukoFonts.olukoMediumFont()),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 120,
                                                height: 30,
                                                child: TextButton(
                                                  onPressed: () {},
                                                  child: Text(
                                                    "Confirm",
                                                    style: OlukoFonts
                                                        .olukoMediumFont(
                                                            customColor:
                                                                OlukoColors
                                                                    .black),
                                                  ),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(OlukoColors
                                                                .primary),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                        // widget.userData.displayName,
                                        "UserName",
                                        style: OlukoFonts.olukoMediumFont(
                                            customColor:
                                                OlukoColors.grayColor)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
