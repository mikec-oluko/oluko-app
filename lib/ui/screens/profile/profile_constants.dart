import 'package:flutter/material.dart';
import 'package:mvt_fitness/ui/components/dialog.dart';

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
  static const List<String> profileOptions = [
    profileOptionsMyAccount,
    profileOptionsAssessmentVideos,
    profileOptionsTransformationJourney,
    profileOptionsSubscription,
    profileOptionsSettings,
    profileOptionsHelpAndSupport,
  ];
}

//Options to update on settings
enum SettingsOptions { notification, public, restricted, anonymous }

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

//Basic model of Challenge, used on profile/Challenges
class ChallengeStatic {
  String title;
  String subtitle;
  String type;
  bool isLocked;
  String imageCover;
  ChallengeStatic(
      {this.title, this.subtitle, this.type, this.isLocked, this.imageCover});
}

//Basic model for Content uploade for user, image/video
class Content {
  String imgUrl;
  bool isVideo;
  Content({this.imgUrl, this.isVideo});
}

//Challenges examples
final challengeDefault = ChallengeStatic(
    title: "20min EMOM challenge",
    subtitle: "Innterval traiinning",
    type: "Class",
    isLocked: false,
    imageCover: 'assets/courses/course_sample_1.png');

final _secondChallenge = ChallengeStatic(
    title: "Fish Arms",
    subtitle: "Abdominal Crunches",
    type: "Class",
    isLocked: false,
    imageCover: 'assets/courses/course_sample_2.png');

final _lockedChallenge = ChallengeStatic(
    title: "Screaming Squat Challenge",
    subtitle: "Drop and give me 20!",
    type: "Class",
    isLocked: true,
    imageCover: 'assets/courses/course_sample_3.png');

//List of challenges, (Challenges)
final List<ChallengeStatic> challengeCollection = [
  challengeDefault,
  _secondChallenge,
  _lockedChallenge
];

//List of content (Displayed on Transformation Journey)
final List<Content> uploadListContent = [
  Content(imgUrl: 'assets/courses/course_sample_3.png', isVideo: true),
  Content(imgUrl: 'assets/courses/course_sample_5.png', isVideo: true),
  Content(imgUrl: 'assets/courses/course_sample_4.png', isVideo: true),
  Content(imgUrl: 'assets/courses/course_sample_6.png', isVideo: false),
  Content(imgUrl: 'assets/courses/course_sample_7.png', isVideo: false),
  Content(imgUrl: 'assets/courses/course_sample_8.png', isVideo: false),
];
