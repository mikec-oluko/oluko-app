import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/bottom_navigation_bar.dart';
import 'package:oluko_app/ui/components/oluko_error_message_view.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/ui/screens/profile/profile_routes.dart';
import 'package:oluko_app/utils/app_navigator.dart';
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

  Widget profileOptions(ProfileOptions option) {
    return currentOption(option);
  }

  Container currentOption(ProfileOptions option) {
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
            onTap: option.enable
                ? () => Navigator.pushNamed(
                    context, ProfileRoutes.returnRouteName(option.option))
                : () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(option.option,
                      style: option.enable
                          ? OlukoFonts.olukoMediumFont()
                          : OlukoFonts.olukoMediumFont(
                              customColor: OlukoColors.grayColor)),
                ),
                IconButton(
                    icon: Icon(Icons.arrow_forward_ios,
                        color: OlukoColors.grayColor),
                    onPressed: option.enable
                        ? () => Navigator.pushNamed(context,
                                ProfileRoutes.returnRouteName(option.option))
                            .then((value) => onGoBack())
                        : () {})
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
