import 'package:flutter/material.dart';
import 'package:mvt_fitness/blocs/auth_bloc.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/models/sign_up_response.dart';
import 'package:mvt_fitness/models/user_response.dart';
import 'package:mvt_fitness/ui/components/carousel_section.dart';
import 'package:mvt_fitness/ui/components/carousel_small_section.dart';
import 'package:mvt_fitness/ui/components/challenges_card.dart';
import 'package:mvt_fitness/ui/components/course_card.dart';
import 'package:mvt_fitness/ui/components/image_and_video_container.dart';
import 'package:mvt_fitness/ui/components/user_profile_information.dart';
import 'package:mvt_fitness/ui/components/user_profile_progress.dart';
import 'package:mvt_fitness/ui/screens/profile/profile_constants.dart';
import 'package:mvt_fitness/ui/screens/profile/profile_routes.dart';

class ProfileOwnProfilePage extends StatefulWidget {
  @override
  _ProfileOwnProfilePageState createState() => _ProfileOwnProfilePageState();
}

class _ProfileOwnProfilePageState extends State<ProfileOwnProfilePage> {
  UserResponse profileInfo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getProfileInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildOwnProfileView(context, profileInfo);
          } else {
            return SizedBox();
          }
        });
  }

  _buildOwnProfileView(BuildContext context, UserResponse profileInfo) {
    return Scaffold(
      body: Container(
        color: OlukoColors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Flexible(
              child: Column(children: [
                ListTile(
                  leading: Transform.translate(
                    offset: Offset(-20, 0),
                    child: IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        size: 35,
                        color: OlukoColors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  title: Transform.translate(
                      offset: Offset(-40, 0),
                      child:
                          UserProfileInformation(userInformation: profileInfo)),
                ),
                UserProfileProgress(
                    userChallenges:
                        ProfileViewConstants.profileChallengesContent,
                    userFriends: ProfileViewConstants.profileFriendsContent),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: CarouselSmallSection(
                    routeToGo: ProfileRoutes.goToAssessmentVideos(),
                    title: ProfileViewConstants.profileOptionsAssessmentVideos,
                    children: [
                      _getImageAndVideoCard(
                          'assets/courses/course_sample_3.png',
                          isVideo: true),
                      _getImageAndVideoCard(
                          'assets/courses/course_sample_5.png',
                          isVideo: true),
                      _getImageAndVideoCard(
                          'assets/courses/course_sample_4.png',
                          isVideo: true),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: CarouselSmallSection(
                    routeToGo: ProfileRoutes.goToTransformationJourney(),
                    title: ProfileViewConstants
                        .profileOptionsTransformationJourney,
                    children: [
                      _getImageAndVideoCard(
                          'assets/courses/course_sample_6.png',
                          isVideo: false),
                      _getImageAndVideoCard(
                          'assets/courses/course_sample_7.png',
                          isVideo: false),
                      _getImageAndVideoCard(
                          'assets/courses/course_sample_8.png',
                          isVideo: false),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0).copyWith(bottom: 0),
                  child: CarouselSection(
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                    title: ProfileViewConstants.profileOwnProfileActiveCourses,
                    children: [
                      _getCourseCard('assets/courses/course_sample_1.png',
                          progress: 0.3),
                      _getCourseCard('assets/courses/course_sample_2.png',
                          progress: 0.7),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0).copyWith(top: 0),
                  child: ChallengesCard(
                    challenge: challengeDefault,
                    routeToGo: ProfileRoutes.goToChallenges(),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getProfileInfo() async {
    profileInfo =
        UserResponse.fromJson((await AuthBloc().retrieveLoginData()).toJson());
    return profileInfo;
  }

  Widget _getCourseCard(String assetImage, {double progress}) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: CourseCard(
        width: 120,
        height: 120,
        imageCover: Image.asset(assetImage),
        progress: progress,
      ),
    );
  }

  Widget _getImageAndVideoCard(String assetImage, {bool isVideo}) {
    return ImageAndVideoContainer(
      assetImage: assetImage,
      isVideo: isVideo,
    );
  }
}
