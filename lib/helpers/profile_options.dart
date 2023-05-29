import 'package:oluko_app/helpers/enum_collection.dart';
import 'dart:io';

class ProfileOptions {
  final ProfileOptionsTitle option;
  final bool enable;
  ProfileOptions({this.option, this.enable = true});

  static List<ProfileOptions> profileOptions = [
    ProfileOptions(option: ProfileOptionsTitle.myAccount),
    ProfileOptions(option: ProfileOptionsTitle.maxWeights),
    ProfileOptions(option: ProfileOptionsTitle.assessmentVideos),
    ProfileOptions(option: ProfileOptionsTitle.transformationPhotos),
    // ProfileOptions(option: ProfileOptionsTitle.transformationJourney),
    ProfileOptions(option: ProfileOptionsTitle.settings),
    if (Platform.isIOS || Platform.isMacOS) ProfileOptions(option: ProfileOptionsTitle.subscription),
    ProfileOptions(option: ProfileOptionsTitle.helpAndSupport),
    ProfileOptions(option: ProfileOptionsTitle.logout)
  ];
}
