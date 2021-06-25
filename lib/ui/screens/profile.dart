import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
// import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import '../../constants/Theme.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  SignUpResponse profileInfo;
  final String profileTitle = ProfileViewConstants.profileTitle;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getProfileInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return profileHomeView();
          } else {
            return SizedBox();
          }
        });
  }

  Widget profileHomeView() {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: OlukoAppBar(
                title: ProfileViewConstants.profileTitle, showSearchBar: false),
            body: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    userInformationSection(),
                    buildOptionsList(),
                  ],
                ))));
  }

  Widget userInformationSection() {
    return Column(
      children: [
        GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, '/profile-view-own-profile')
                    .then((value) => onGoBack()),
            child: UserProfileInformation(userInformation: profileInfo)),
        UserProfileProgress(
            userChallenges: ProfileViewConstants.profileChallengesContent,
            userFriends: ProfileViewConstants.profileFriendsContent)
      ],
    );
  }

  Padding buildOptionsList() {
    return Padding(
      padding: const EdgeInsets.only(top: 150),
      child: ListView.builder(
          itemCount: ProfileViewConstants.profileOptions.length,
          itemBuilder: (_, index) =>
              profileOptions(ProfileViewConstants.profileOptions[index])),
    );
  }

  Widget profileOptions(String pageTitle) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(width: 1.0, color: OlukoColors.grayColor))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(pageTitle,
                    style: TextStyle(fontSize: 14.0, color: Colors.white)),
              ),
              IconButton(
                  icon: Icon(Icons.arrow_forward_ios,
                      color: OlukoColors.grayColor),
                  onPressed: () =>
                      Navigator.pushNamed(context, returnRouteName(pageTitle))
                          .then((value) => onGoBack()))
            ],
          ),
        ],
      ),
    );
  }

  String returnRouteName(String pageTitle) {
    switch (pageTitle) {
      case ProfileViewConstants.profileOptionsMyAccount:
        return '/profile-my-account';
      case ProfileViewConstants.profileOptionsAssessmentVideos:
        return '/';
      case ProfileViewConstants.profileOptionsTransformationJourney:
        return '/';
      case ProfileViewConstants.profileOptionsSubscription:
        return '/profile-subscription';
      case ProfileViewConstants.profileOptionsSettings:
        return '/profile-settings';
      case ProfileViewConstants.profileOptionsHelpAndSupport:
        return '/profile-help-and-support';
      default:
        return '/';
    }
  }

  onGoBack() {
    setState(() {});
  }

  handleError(AsyncSnapshot snapshot) {}

  handleResult(AsyncSnapshot snapshot) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      returnToHome();
    });
  }

  Future<void> getProfileInfo() async {
    profileInfo = SignUpResponse.fromJson(
        (await AuthBloc().retrieveLoginData()).toJson());
    return profileInfo;
  }

  Future<void> returnToHome() async {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }
}
