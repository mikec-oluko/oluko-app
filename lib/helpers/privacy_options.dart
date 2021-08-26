import 'package:oluko_app/models/user_response.dart';

import 'enum_collection.dart';

class PrivacyOptions {
  SettingsPrivacyOptions title;
  SettingsPrivacyOptionsSubtitle subtitle;
  SettingsPrivacyOptions option;
  bool showSubtitle;
  bool isSwitch;
  PrivacyOptions(
      {this.title,
      this.subtitle,
      this.option,
      this.showSubtitle = true,
      this.isSwitch = false});

  static List<PrivacyOptions> privacyOptionsList = [
    PrivacyOptions(
        title: SettingsPrivacyOptions.public,
        subtitle: SettingsPrivacyOptionsSubtitle.publicSubtitle,
        option: SettingsPrivacyOptions.public),
    PrivacyOptions(
        title: SettingsPrivacyOptions.restricted,
        subtitle: SettingsPrivacyOptionsSubtitle.restrictedSubtitle,
        option: SettingsPrivacyOptions.restricted),
    PrivacyOptions(
        title: SettingsPrivacyOptions.anonymous,
        subtitle: SettingsPrivacyOptionsSubtitle.anonymousSubtitle,
        option: SettingsPrivacyOptions.anonymous),
  ];

  static SettingsPrivacyOptions getPrivacyValue(num optionSelected) =>
      privacyOptionsList.elementAt(optionSelected).option;

  static bool canShowDetails(
      {bool isOwner,
      UserResponse currentUser,
      UserResponse userRequested,
      UserConnectStatus connectStatus}) {
    if (isOwner) {
      return true;
    } else {
      if (currentUserPrivacyOption(currentUser) ==
          SettingsPrivacyOptions.public) {
        if (userRequestedPrivacyOption(userRequested) ==
            SettingsPrivacyOptions.public) {
          return true;
        } else if (userRequestedPrivacyOption(userRequested) ==
                SettingsPrivacyOptions.restricted &&
            connectStatus == UserConnectStatus.connected) {
          return true;
        } else if (userRequestedPrivacyOption(userRequested) ==
                SettingsPrivacyOptions.anonymous &&
            connectStatus == UserConnectStatus.connected) {
          return true;
        } else {
          return false;
        }
      }
      if (currentUserPrivacyOption(currentUser) ==
          SettingsPrivacyOptions.restricted) {
        if (userRequestedPrivacyOption(userRequested) ==
            SettingsPrivacyOptions.public) {
          return true;
        } else if (userRequestedPrivacyOption(userRequested) ==
                SettingsPrivacyOptions.restricted &&
            connectStatus == UserConnectStatus.connected) {
          return true;
        } else if (userRequestedPrivacyOption(userRequested) ==
                SettingsPrivacyOptions.anonymous &&
            connectStatus == UserConnectStatus.connected) {
          return true;
        } else {
          return false;
        }
      }
      if (currentUserPrivacyOption(currentUser) ==
          SettingsPrivacyOptions.anonymous) {
        if (userRequestedPrivacyOption(userRequested) ==
            SettingsPrivacyOptions.public) {
          return true;
        } else if (userRequestedPrivacyOption(userRequested) ==
                SettingsPrivacyOptions.restricted &&
            connectStatus == UserConnectStatus.connected) {
          return true;
        }
      }
    }
  }

  static SettingsPrivacyOptions currentUserPrivacyOption(
      UserResponse currentUser) {
    return PrivacyOptions.privacyOptionsList[currentUser.privacy].option;
  }

  static SettingsPrivacyOptions userRequestedPrivacyOption(
      UserResponse userToDisplayInformation) {
    return PrivacyOptions
        .privacyOptionsList[userToDisplayInformation.privacy].option;
  }
}
