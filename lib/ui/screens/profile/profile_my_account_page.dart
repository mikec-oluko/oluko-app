import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ProfileMyAccountPage extends StatefulWidget {
  @override
  _ProfileMyAccountPageState createState() => _ProfileMyAccountPageState();
}

class _ProfileMyAccountPageState extends State<ProfileMyAccountPage> {
  SignUpRequest _requestData = SignUpRequest();
  SignUpResponse profileInfo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getProfileInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return buildScaffoldPage(context);
          } else {
            return SizedBox();
          }
        });
  }

  Scaffold buildScaffoldPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: OlukoColors.grayColor),
              onPressed: () => Navigator.pop(context)),
          automaticallyImplyLeading: false,
          title: Text(ProfileViewConstants.profileMyAccountTitle,
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          actions: <Widget>[
            TextButton(
              onPressed: () {},
              child: Text("Save",
                  style: TextStyle(fontSize: 14.0, color: Colors.white)),
            ),
          ],
          bottom: PreferredSize(
              child: Container(
                color: OlukoColors.grayColor,
                height: 0.5,
              ),
              preferredSize: Size.fromHeight(4.0))),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: Column(
            children: [
              userImageSection(),
              userInformationSection(ProfileViewConstants.profileUserFirstName,
                  profileInfo.firstName),
              userInformationSection(ProfileViewConstants.profileUserLastName,
                  profileInfo.lastName),
              userInformationSection(
                  ProfileViewConstants.profileUserEmail, profileInfo.email),
              userInformationSection(ProfileViewConstants.profileUserMobile,
                  ProfileViewConstants.profileUserMobileContent),
            ],
          ),
        ),
      ),
    );
  }

  Widget userInformationSection(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(width: 1.0, color: OlukoColors.grayColor)),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: OlukoColors.grayColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      value,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget userImageSection() {
    return Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 50.0,
                child: IconButton(
                    icon:
                        Icon(Icons.linked_camera_outlined, color: Colors.white),
                    onPressed: () {}),
              ),
            )
          ],
        ));
  }

  Future<void> getProfileInfo() async {
    profileInfo = SignUpResponse.fromJson(
        (await AuthBloc().retrieveLoginData()).toJson());
    return profileInfo;
  }
}
