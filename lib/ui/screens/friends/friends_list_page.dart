import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/friends_card.dart';

class FriendsListPage extends StatefulWidget {
  final List<User> friends;
  FriendsListPage({this.friends});
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final _title = "Starred";
  final _firstName = "FirstName";
  final _lastName = "LastName";
  final _userName = "UserName";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: OlukoColors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_title, style: OlukoFonts.olukoBigFont()),
            ),
            // Column(
            //     children: widget.friends
            //         .map((friend) => FriendCard(
            //               userData: friend,
            //             ))
            //         .toList()),
            Column(
              children: [card(), card()],
            )
          ],
        ),
      ),
    );
  }

  //TODO: changed to widget FriendCard, still function to show view
  Container card() {
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
                              _firstName,
                              style: OlukoFonts.olukoMediumFont(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(_lastName,
                                  style: OlukoFonts.olukoMediumFont()),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(_userName,
                        style: OlukoFonts.olukoMediumFont(
                            customColor: OlukoColors.grayColor)),
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
                    Icons.star,
                    color: OlukoColors.primary,
                  ),
                  onPressed: () {}),
            ],
          )
        ]),
      ),
    );
  }
}
