import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/ui/components/black_app_bar.dart';
import 'package:mvt_fitness/ui/screens/profile/profile_constants.dart';

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
            null, SettingsOptions.notification, false),
        _optionSwitch(
            context,
            ProfileViewConstants.profileSettingsPublic,
            ProfileViewConstants.profileSettingsPublicSubtitle,
            SettingsOptions.public,
            true),
        _optionSwitch(
            context,
            ProfileViewConstants.profileSettingsRestricted,
            ProfileViewConstants.profileSettingsRestrictedSubtitle,
            SettingsOptions.restricted,
            true),
        _optionSwitch(
            context,
            ProfileViewConstants.profileSettingsAnonymous,
            ProfileViewConstants.profileSettingsAnonymousSubtitle,
            SettingsOptions.anonymous,
            true),
      ],
    );
  }

  Container _optionSwitch(BuildContext context, String title, String subTitle,
      SettingsOptions optionToUse, bool subtitleStatus) {
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
                  value: valueToUse,
                  onChanged: (bool value) => _setValue(optionToUse, value),
                  trackColor: MaterialStateProperty.all(Colors.grey),
                  activeColor: OlukoColors.primary,
                )),
          ),
        ],
      ),
    );
  }

  bool _returnValue(SettingsOptions option) {
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

  void _setValue(SettingsOptions option, value) {
    switch (option) {
      case SettingsOptions.notification:
        setState(() {
          _notification = value;
        });
        break;
      case SettingsOptions.public:
        setState(() {
          _public = value;
        });
        break;
      case SettingsOptions.restricted:
        setState(() {
          _restricted = value;
        });
        break;
      case SettingsOptions.anonymous:
        setState(() {
          _anonymous = value;
        });
        break;
      default:
        break;
    }
  }
}
