import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ProfileOwnProfilePage extends StatefulWidget {
  @override
  _ProfileOwnProfilePageState createState() => _ProfileOwnProfilePageState();
}

class _ProfileOwnProfilePageState extends State<ProfileOwnProfilePage> {
  SignUpResponse profileInfo;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getProfileInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return buildOwnProfileView(context, profileInfo);
          } else {
            return SizedBox();
          }
        });
  }

  buildOwnProfileView(BuildContext context, SignUpResponse profileInfo) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(children: [
          SafeArea(
            child: ListTile(
              leading: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  size: 35,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: UserProfileInformation(userInformation: profileInfo),
            ),
          ),
          UserProfileProgress(
              userChallenges: ProfileViewConstants.profileChallengesContent,
              userFriends: ProfileViewConstants.profileFriendsContent)
        ]),
      ),
    );
  }

  Future<void> getProfileInfo() async {
    profileInfo = SignUpResponse.fromJson(
        (await AuthBloc().retrieveLoginData()).toJson());
    return profileInfo;
  }
}
