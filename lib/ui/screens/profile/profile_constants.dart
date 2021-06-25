import 'package:flutter/material.dart';

class ProfileViewConstants {
  static const profileTitle = "Profile";
  static const profileUserFirstName = "First Name";
  static const profileUserLastName = "Last Name";
  static const profileUserEmail = "Email";
  static const profileUserName = "Username";
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
  static const profileOwnProfileViewAll = "View All";
  static const profileOwnProfileActiveCourses = 'Active Courses';
  static const profileSubscriptionLogout = "Logout";

  static const List<String> profileOptions = [
    profileOptionsMyAccount,
    profileOptionsAssessmentVideos,
    profileOptionsTransformationJourney,
    profileOptionsSubscription,
    profileOptionsSettings,
    profileOptionsHelpAndSupport,
  ];
}

enum SettingsOptions { notification, public, restricted, anonymous }

class BasicTile {
  final String title;
  final List<BasicTile> tiles;
  bool isExpanded;

  BasicTile(
      {@required this.title, this.tiles = const [], this.isExpanded = false});
}

//Collection of help and support Tiles, if contains tiles = new tile, if not, title == content.
final basicTiles = <BasicTile>[
  BasicTile(title: "Top Queries", tiles: [
    BasicTile(title: "What is included in the memebership?", tiles: [
      BasicTile(
          title:
              " is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley"),
    ]),
    BasicTile(title: "How many courses do i get?", tiles: [
      BasicTile(
          title:
              " is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley"),
    ]),
    BasicTile(title: "Which classes are right for me?", tiles: [
      BasicTile(
          title:
              " is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley"),
    ]),
  ]),
  BasicTile(title: "Plans, Pricing and Payments", tiles: [
    BasicTile(title: "Plans", tiles: [
      BasicTile(title: "Plan 1", tiles: [
        BasicTile(
            title:
                " is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley"),
      ]),
      BasicTile(title: "Plan 2", tiles: [
        BasicTile(
            title:
                " is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley"),
      ]),
    ]),
  ])
];

class Challenge {
  String title;
  String subtitle;
  String type;
  bool isLocked;
  String imageCover;
  Challenge(
      {this.title, this.subtitle, this.type, this.isLocked, this.imageCover});
}

//Challenge example
final challengeDefault = Challenge(
    title: "20min EMOM challenge",
    subtitle: "Innterval traiinning",
    type: "Class",
    isLocked: false,
    imageCover: 'assets/courses/course_sample_1.png');
