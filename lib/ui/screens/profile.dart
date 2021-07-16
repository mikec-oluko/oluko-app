import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mvt_fitness/blocs/auth_bloc.dart';
import 'package:mvt_fitness/models/user_response.dart';
import 'package:mvt_fitness/ui/components/black_app_bar.dart';
import 'package:mvt_fitness/ui/components/bottom_navigation_bar.dart';
import 'package:mvt_fitness/ui/components/oluko_error_message_view.dart';
import 'package:mvt_fitness/ui/components/user_profile_information.dart';
import 'package:mvt_fitness/ui/components/user_profile_progress.dart';
import 'package:mvt_fitness/ui/screens/profile/profile_constants.dart';
import 'package:mvt_fitness/ui/screens/profile/profile_routes.dart';
import 'package:mvt_fitness/utils/app_navigator.dart';
import '../../constants/theme.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isTesting = false;
  UserResponse profileInfo;
  final String profileTitle = ProfileViewConstants.profileTitle;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getProfileInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return profileHomeView();
          } else {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.red,
            );
          }
        });
  }

  Widget profileHomeView() {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: OlukoAppBar(
                showBackButton: false,
                title: ProfileViewConstants.profileTitle,
                showSearchBar: false),
            body: WillPopScope(
              onWillPop: () => AppNavigator.onWillPop(context),
              child: Container(
                  color: OlukoColors.black,
                  child: Stack(
                    children: [
                      userInformationSection(),
                      buildOptionsList(),
                    ],
                  )),
            ),
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
          InkWell(
            onTap: () => Navigator.pushNamed(
                context, ProfileRoutes.returnRouteName(pageTitle)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(pageTitle, style: OlukoFonts.olukoMediumFont()),
                ),
                IconButton(
                    icon: Icon(Icons.arrow_forward_ios,
                        color: OlukoColors.grayColor),
                    onPressed: () => Navigator.pushNamed(
                            context, ProfileRoutes.returnRouteName(pageTitle))
                        .then((value) => onGoBack()))
              ],
            ),
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
    UserResponse user = (await AuthBloc().retrieveLoginData());
    if (user != null) {
      profileInfo = UserResponse.fromJson(user.toJson());
      return profileInfo;
    }
    return null;
  }
}
