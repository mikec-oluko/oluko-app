import 'dart:io';
import 'enum_collection.dart';

class ProfileOptions {
  final ProfileOptionsTitle option;
  final bool enable;
  ProfileOptions({this.option, this.enable = true});

  static List<ProfileOptions> profileOptions = [
    ProfileOptions(option: ProfileOptionsTitle.myAccount),
    ProfileOptions(option: ProfileOptionsTitle.assessmentVideos),
    ProfileOptions(option: ProfileOptionsTitle.transformationJourney),
    // ProfileOptions(option: ProfileOptionsTitle.subscription, enable: false),
    ProfileOptions(option: ProfileOptionsTitle.settings),
    if(Platform.isIOS || Platform.isMacOS) ProfileOptions(option: ProfileOptionsTitle.subscription),
    ProfileOptions(option: ProfileOptionsTitle.helpAndSupport),
    ProfileOptions(option: ProfileOptionsTitle.logout)
  ];
}
