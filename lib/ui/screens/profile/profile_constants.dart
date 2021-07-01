import 'package:flutter/material.dart';
import 'package:oluko_app/ui/components/dialog.dart';

class ProfileViewConstants {
  //Constants used on Profile Feature
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
  static const profileChallengesPageTitle = "Challenges";

  //List of options for Profile settings.
  static const List<String> profileOptions = [
    profileOptionsMyAccount,
    profileOptionsAssessmentVideos,
    profileOptionsTransformationJourney,
    profileOptionsSubscription,
    profileOptionsSettings,
    profileOptionsHelpAndSupport,
  ];

  //Function handler Dialog/Modal
  static dialogContent(
      {BuildContext context, List<Widget> content, bool closeButton = false}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext _) {
          if (closeButton == true) {
            content.insert(
                0,
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: 10,
                    child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                  ),
                ));
          }

          return DialogWidget(content: content);
        });
  }
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

//Basic model of Challenge, used on profile/Challenges
class Challenge {
  String title;
  String subtitle;
  String type;
  bool isLocked;
  String imageCover;
  Challenge(
      {this.title, this.subtitle, this.type, this.isLocked, this.imageCover});
}

//Basic model for Content uploade for user, image/video
class Content {
  String imgUrl;
  bool isVideo;
  Content({this.imgUrl, this.isVideo});
}

//Challenges examples
final challengeDefault = Challenge(
    title: "20min EMOM challenge",
    subtitle: "Innterval traiinning",
    type: "Class",
    isLocked: false,
    imageCover: 'assets/courses/course_sample_1.png');

final _secondChallenge = Challenge(
    title: "Fish Arms",
    subtitle: "Abdominal Crunches",
    type: "Class",
    isLocked: false,
    imageCover: 'assets/courses/course_sample_2.png');

final _lockedChallenge = Challenge(
    title: "Screaming Squat Challenge",
    subtitle: "Drop and give me 20!",
    type: "Class",
    isLocked: true,
    imageCover: 'assets/courses/course_sample_3.png');

//List of challenges, (Challenges)
final List<Challenge> challengeCollection = [
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
