import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
// import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/bottom_navigation_bar.dart';
import 'package:oluko_app/ui/components/oluko_error_message_view.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/ui/screens/profile/profile_routes.dart';
import '../../constants/theme.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isTesting = false;
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
                color: OlukoColors.black,
                child: Stack(
                  children: [
                    userInformationSection(),
                    buildOptionsList(),
                  ],
                )),
            bottomNavigationBar: OlukoBottomNavigationBar()));
  }

  Widget userInformationSection() {
    Widget returnWidget;
    _isTesting == false
        ? returnWidget = Column(
            children: [
              GestureDetector(
                  onTap: () => Navigator.pushNamed(
                          context, ProfileRoutes.userInformationRoute)
                      .then((value) => onGoBack()),
                  child: UserProfileInformation(userInformation: profileInfo)),
              UserProfileProgress(
                  userChallenges: ProfileViewConstants.profileChallengesContent,
                  userFriends: ProfileViewConstants.profileFriendsContent)
            ],
          )
        : returnWidget = Center(child: OlukoErrorMessage());

    return returnWidget;
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
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, ProfileRoutes.returnRouteName(pageTitle)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(pageTitle, style: OlukoFonts.olukoMediumFont()),
                ),
              ),
              IconButton(
                  icon: Icon(Icons.arrow_forward_ios,
                      color: OlukoColors.grayColor),
                  onPressed: () => Navigator.pushNamed(
                          context, ProfileRoutes.returnRouteName(pageTitle))
                      .then((value) => onGoBack()))
            ],
          ),
        ],
      ),
    );
  }

  onGoBack() {
    setState(() {});
  }

  handleError(AsyncSnapshot snapshot) {}

  handleResult(AsyncSnapshot snapshot) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ProfileRoutes.returnToHome(context: context);
    });
  }

  Future<void> getProfileInfo() async {
    profileInfo = SignUpResponse.fromJson(
        (await AuthBloc().retrieveLoginData()).toJson());
    return profileInfo;
  }
}
