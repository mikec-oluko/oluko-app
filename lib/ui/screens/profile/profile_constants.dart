import 'package:flutter/material.dart';

class ProfileViewConstants {
  //Constants used on Profile Feature
  static const profileTitle = "Profile";
  static const profileUserNameContent = "myUserName";
  static const profileSettingsTitle = "Settings";
  static const profileMyAccountTitle = "My Account";
  static const profileLevel = "Level 29";
  static const profileTrophiesTitle = "Trophies";
  static const profileChallengesTitle = "Challenges Completed";
  static const profileFriendsTitle = "Friends";
  static const profileTrophiesContent = "13";
  static const profileChallengesContent = "07";
  static const profileFriendsContent = "37";
  static const profileSettingsNotification = "Notification";
  static const profileSettingsPublic = "Public";
  static const profileSettingsRestricted = "Restricted";
  static const profileSettingsAnonymous = "Anonymous";
  static const profileSettingsAnonymousSubtitle = "Anonymous profile";
  static const profileSettingsPublicSubtitle = "Public profile";
  static const profileSettingsRestrictedSubtitle = "Restricted profile";
  static const profileOptionsMyAccount = "My Account";
  static const profileOptionsAssessmentVideos = "Assessment Videos";
  static const profileOptionsTransformationJourney = "Transformation Journey";
  static const profileOptionsSubscription = "Subscription";
  static const profileOptionsSettings = "Settings";
  static const profileOptionsHelpAndSupport = "Help and Support";
  static const profileSubscriptionMessage = "Recommended Upgrade";
  static const profileUpgradeText = "Upgrade";
  static const profileHelpAndSupportSubTitle = "Need more help?";
  static const profileHelpAndSupportButtonText = "Contact us";
  static const profileUpcomingChallengesTitle = "Upcoming Challenges";
  static const profileOwnProfileActiveCourses = 'Active Courses';
  static const profileChallengesPageTitle = "Challenges";
  static const profileChangePaymentMethodTitle = "Change Payment Method";
  static const profileUnsuscribeTitle = "Unsubscribe";
  static const profileSelectFromGalleryTitle = "Select from Gallery";

  //List of options for Profile settings.
  static List<ProfileOptions> profileOptions = [
    ProfileOptions(option: profileOptionsMyAccount),
    ProfileOptions(option: profileOptionsAssessmentVideos),
    ProfileOptions(option: profileOptionsTransformationJourney),
    ProfileOptions(option: profileOptionsSubscription, enable: false),
    ProfileOptions(option: profileOptionsSettings),
    ProfileOptions(option: profileOptionsHelpAndSupport),
  ];
}

class ProfileOptions {
  final String option;
  final bool enable;
  ProfileOptions({this.option, this.enable = true});
}

//Options to update on settings
enum SettingsOptions { notification, public, restricted, anonymous }

//Enum for modal, to update images
enum UploadFrom { profileImage, transformationJourney, profileCoverImage }

enum ActualProfileRoute { rootProfile, userProfile, userAssessmentVideos }

//Enum of options for upload content
enum DeviceContentFrom { camera, gallery }

//Basic model for Tile (Help and Support)
class BasicTile {
  final String title;
  final List<BasicTile> tiles;
  bool isExpanded;

  BasicTile(
      {@required this.title, this.tiles = const [], this.isExpanded = false});
}

//TODO:
//Collection of help and support Tiles,
//if contains tiles[] = new tile, if not, title == content.
//parentTile[childTile []] = new Tile, parentTile[!childTile[]] = Tile with content
final basicTiles = <BasicTile>[
  BasicTile(title: "Top Queries", tiles: [
    BasicTile(title: "What is included in the memebership?", tiles: [
      BasicTile(
          title:
              " No information to display, information will be added as soon as possible, check back later."),
    ]),
    BasicTile(title: "How many courses do i get?", tiles: [
      BasicTile(
          title:
              " No information to display, information will be added as soon as possible, check back later. "),
    ]),
    BasicTile(title: "Which classes are right for me?", tiles: [
      BasicTile(
          title:
              " No information to display, information will be added as soon as possible, check back later. "),
    ]),
  ]),
  BasicTile(title: "Plans, Pricing and Payments", tiles: [
    BasicTile(title: "Plans", tiles: [
      BasicTile(title: "Plan 1", tiles: [
        BasicTile(
            title:
                " No information to display, information will be added as soon as possible, check back later. "),
      ]),
      BasicTile(title: "Plan 2", tiles: [
        BasicTile(
            title:
                " No information to display, information will be added as soon as possible, check back later. "),
      ]),
    ]),
  ])
];
