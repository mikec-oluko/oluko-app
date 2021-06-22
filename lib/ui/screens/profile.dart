import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import '../../constants/Theme.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  SignUpRequest _requestData = SignUpRequest();
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
            appBar: AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                automaticallyImplyLeading: false,
                title: Text(ProfileViewConstants.profileTitle,
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.black,
                actions: [],
                bottom: PreferredSize(
                    child: Container(
                      color: OlukoColors.grayColor,
                      height: 0.5,
                    ),
                    preferredSize: Size.fromHeight(4.0))),
            body: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    userInformationSection(),
                    Padding(
                      padding: const EdgeInsets.only(top: 150),
                      child: ListView.builder(
                          itemCount: ProfileViewConstants.profileOptions.length,
                          itemBuilder: (_, index) => profileOptions(
                              ProfileViewConstants.profileOptions[index])),
                    ),
                  ],
                ))));
  }

  Widget userInformationSection() {
    return Container(
      color: Colors.black,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 4,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            this.profileInfo.firstName,
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              this.profileInfo.lastName,
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Text(ProfileViewConstants.profileLevel,
                          style: TextStyle(
                              fontSize: 14.0, color: OlukoColors.grayColor))
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileAccomplishments(
                      ProfileViewConstants.profileTrophiesTitle,
                      ProfileViewConstants.profileTrophiesContent),
                  applyVerticalDivider(),
                  profileAccomplishments(
                      ProfileViewConstants.profilePersonalRecordTitle,
                      ProfileViewConstants.profilePersonalRecordContent),
                  applyVerticalDivider(),
                  profileAccomplishments(
                      ProfileViewConstants.profileFriendsTitle,
                      ProfileViewConstants.profileFriendsContent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  VerticalDivider applyVerticalDivider() =>
      VerticalDivider(color: OlukoColors.grayColor);

  Column profileAccomplishments(String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 14.0, color: OlukoColors.grayColor)),
        Text(
          value,
          style: TextStyle(
              fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ],
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
                      Navigator.pushNamed(context, '/profile-settings')
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
