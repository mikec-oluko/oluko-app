import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class UserProfileProgress extends StatefulWidget {
  final String userChallenges;
  final String userFriends;
  const UserProfileProgress({this.userChallenges, this.userFriends}) : super();

  @override
  _UserProfileProgressState createState() => _UserProfileProgressState();
}

class _UserProfileProgressState extends State<UserProfileProgress> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileAccomplishments(ProfileViewConstants.profileChallengesTitle,
                widget.userChallenges),
            VerticalDivider(color: OlukoColors.grayColor),
            profileAccomplishments(
                ProfileViewConstants.profileFriendsTitle, widget.userFriends),
          ],
        ),
      ),
    );
  }

  Widget profileAccomplishments(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: OlukoFonts.olukoMediumFont(
                  customColor: OlukoColors.grayColor)),
          SizedBox(height: 5.0),
          Text(
            value,
            style: OlukoFonts.olukoBigFont(
              custoFontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
