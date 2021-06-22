import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ProfileSettingsPage extends StatefulWidget {
  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool _notification = false;
  bool _public = false;
  bool _restricted = false;
  bool _anonymous = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: OlukoColors.grayColor),
              onPressed: () => Navigator.pop(context)),
          automaticallyImplyLeading: false,
          title: Text(ProfileViewConstants.profileSettingsTitle,
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
        child: Column(
          children: [
            buildOptionSwitch(
                context,
                ProfileViewConstants.profileSettingsNotification,
                null,
                SettingsOptions.notification,
                false),
            buildOptionSwitch(
                context,
                ProfileViewConstants.profileSettingsPublic,
                ProfileViewConstants.profileSettingsPublicSubtitle,
                SettingsOptions.public,
                true),
            buildOptionSwitch(
                context,
                ProfileViewConstants.profileSettingsRestricted,
                ProfileViewConstants.profileSettingsRestrictedSubtitle,
                SettingsOptions.restricted,
                true),
            buildOptionSwitch(
                context,
                ProfileViewConstants.profileSettingsAnonymous,
                ProfileViewConstants.profileSettingsAnonymousSubtitle,
                SettingsOptions.anonymous,
                true),
          ],
        ),
      ),
    );
  }

  Container buildOptionSwitch(BuildContext context, String title,
      String subTitle, SettingsOptions optionToUse, bool subtitleStatus) {
    var valueToUse = returnValue(optionToUse);
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(width: 1.0, color: OlukoColors.grayColor))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MergeSemantics(
            child: ListTile(
                title: Text(title,
                    style: TextStyle(fontSize: 18.0, color: Colors.white)),
                subtitle: subtitleStatus
                    ? Text(subTitle,
                        style: TextStyle(
                            fontSize: 14.0, color: OlukoColors.grayColor))
                    : null,
                trailing: TextButton(
                    onPressed: () {
                      setValue(optionToUse, valueToUse);
                    },
                    child: valueToUse
                        ? Image.asset('assets/profile/switch-on.png',
                            filterQuality: FilterQuality.high)
                        : Image.asset('assets/profile/switch-off.png',
                            filterQuality: FilterQuality.high))),
          ),
        ],
      ),
    );
  }

  bool returnValue(SettingsOptions option) {
    switch (option) {
      case SettingsOptions.notification:
        return _notification;
      case SettingsOptions.public:
        return _public;
      case SettingsOptions.restricted:
        return _restricted;
      case SettingsOptions.anonymous:
        return _anonymous;
      default:
        return null;
    }
  }

  void setValue(SettingsOptions option, value) {
    switch (option) {
      case SettingsOptions.notification:
        setState(() {
          _notification = !value;
        });
        break;
      case SettingsOptions.public:
        setState(() {
          _public = !value;
        });
        break;
      case SettingsOptions.restricted:
        setState(() {
          _restricted = !value;
        });
        break;
      case SettingsOptions.anonymous:
        setState(() {
          _anonymous = !value;
        });
        break;
      default:
        break;
    }
  }
}
