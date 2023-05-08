import 'package:oluko_app/models/user_response.dart';
import 'enum_collection.dart';

class PrivacyOptions {
  SettingsPrivacyOptions title;
  SettingsPrivacyOptionsSubtitle subtitle;
  SettingsPrivacyOptions option;
  bool showSubtitle;
  bool isSwitch;
  PrivacyOptions({this.title, this.subtitle, this.option, this.showSubtitle = true, this.isSwitch = false});

  static List<PrivacyOptions> privacyOptionsList = [
    PrivacyOptions(
      title: SettingsPrivacyOptions.public,
      subtitle: SettingsPrivacyOptionsSubtitle.publicSubtitle,
      option: SettingsPrivacyOptions.public,
    ),
    PrivacyOptions(
      title: SettingsPrivacyOptions.restricted,
      subtitle: SettingsPrivacyOptionsSubtitle.restrictedSubtitle,
      option: SettingsPrivacyOptions.restricted,
    ),
    PrivacyOptions(
      title: SettingsPrivacyOptions.anonymous,
      subtitle: SettingsPrivacyOptionsSubtitle.anonymousSubtitle,
      option: SettingsPrivacyOptions.anonymous,
    ),
  ];

  static SettingsPrivacyOptions getPrivacyValue(int optionSelected) => privacyOptionsList.elementAt(optionSelected).option;

  SettingsPrivacyOptions currentUserPrivacyOption(UserResponse currentUser) {
    return PrivacyOptions.privacyOptionsList[currentUser.privacy].option;
  }

  static SettingsPrivacyOptions userRequestedPrivacyOption(UserResponse userToDisplayInformation) {
    return PrivacyOptions.privacyOptionsList[userToDisplayInformation.privacy].option;
  }

  bool canShowDetails({bool isOwner, UserResponse currentUser, UserResponse userRequested, UserConnectStatus connectStatus}) {
    final _currentUserPrivacyOption = currentUserPrivacyOption(currentUser);
    final _userRequestedPrivacyOption = userRequestedPrivacyOption(userRequested);
    if (isOwner) {
      return true;
    }
    switch (_currentUserPrivacyOption) {
      case SettingsPrivacyOptions.public:
        if (_userRequestedPrivacyOption == SettingsPrivacyOptions.public ||
            ((_userRequestedPrivacyOption == SettingsPrivacyOptions.restricted || _userRequestedPrivacyOption == SettingsPrivacyOptions.anonymous) &&
                connectStatus == UserConnectStatus.connected)) {
          return true;
        }
        return false;
      case SettingsPrivacyOptions.restricted:
        if (_userRequestedPrivacyOption == SettingsPrivacyOptions.public ||
            ((_userRequestedPrivacyOption == SettingsPrivacyOptions.restricted || _userRequestedPrivacyOption == SettingsPrivacyOptions.anonymous) &&
                connectStatus == UserConnectStatus.connected)) {
          return true;
        }
        return false;
      case SettingsPrivacyOptions.anonymous:
        if (_userRequestedPrivacyOption == SettingsPrivacyOptions.public ||
            (_userRequestedPrivacyOption == SettingsPrivacyOptions.restricted && connectStatus == UserConnectStatus.connected)) {
          return true;
        }
        return false;
      default:
        break;
        return false;
    }
  }
}
