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
}
