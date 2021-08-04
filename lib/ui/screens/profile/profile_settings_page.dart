import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
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
      appBar: OlukoAppBar(
        title: ProfileViewConstants.profileSettingsTitle,
        showSearchBar: false,
      ),
      body: Container(
        color: OlukoColors.black,
        child: _buildOptions(context),
      ),
    );
  }

  Column _buildOptions(BuildContext context) {
    return Column(
      children: [
        _optionSwitch(context, ProfileViewConstants.profileSettingsNotification,
            null, SettingsPrivacyAndNotificationOptions.notification, false),
        _optionSwitch(
            context,
            ProfileViewConstants.profileSettingsPublic,
            ProfileViewConstants.profileSettingsPublicSubtitle,
            SettingsPrivacyAndNotificationOptions.public,
            true),
        _optionSwitch(
            context,
            ProfileViewConstants.profileSettingsRestricted,
            ProfileViewConstants.profileSettingsRestrictedSubtitle,
            SettingsPrivacyAndNotificationOptions.restricted,
            true),
        _optionSwitch(
            context,
            ProfileViewConstants.profileSettingsAnonymous,
            ProfileViewConstants.profileSettingsAnonymousSubtitle,
            SettingsPrivacyAndNotificationOptions.anonymous,
            true),
      ],
    );
  }

  Container _optionSwitch(BuildContext context, String title, String subTitle,
      SettingsPrivacyAndNotificationOptions optionToUse, bool subtitleStatus) {
    var valueToUse = _returnValue(optionToUse);
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
                title: Text(title, style: OlukoFonts.olukoBigFont()),
                subtitle: subtitleStatus
                    ? Text(subTitle,
                        style: OlukoFonts.olukoMediumFont(
                            customColor: OlukoColors.grayColor))
                    : null,
                trailing: Switch(
                  value: false,
                  // onChanged: (bool value) => _setValue(optionToUse, value),
                  onChanged: (bool value) => {},
                  trackColor: MaterialStateProperty.all(OlukoColors.grayColor),
                  activeColor: OlukoColors.primary,
                )),
          ),
        ],
      ),
    );
  }

  bool _returnValue(SettingsPrivacyAndNotificationOptions option) {
    switch (option) {
      case SettingsPrivacyAndNotificationOptions.notification:
        return _notification;
      case SettingsPrivacyAndNotificationOptions.public:
        return _public;
      case SettingsPrivacyAndNotificationOptions.restricted:
        return _restricted;
      case SettingsPrivacyAndNotificationOptions.anonymous:
        return _anonymous;
      default:
        return null;
    }
  }

  void _setValue(SettingsPrivacyAndNotificationOptions option, value) {
    switch (option) {
      case SettingsPrivacyAndNotificationOptions.notification:
        setState(() {
          _notification = value;
        });
        break;
      case SettingsPrivacyAndNotificationOptions.public:
        setState(() {
          _public = value;
        });
        break;
      case SettingsPrivacyAndNotificationOptions.restricted:
        setState(() {
          _restricted = value;
        });
        break;
      case SettingsPrivacyAndNotificationOptions.anonymous:
        setState(() {
          _anonymous = value;
        });
        break;
      default:
        break;
    }
  }
}
