import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/image_and_video_preview_card.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/ui/screens/profile/profile_routes.dart';

class ProfileOwnProfilePage extends StatefulWidget {
  @override
  _ProfileOwnProfilePageState createState() => _ProfileOwnProfilePageState();
}

class _ProfileOwnProfilePageState extends State<ProfileOwnProfilePage> {
  SignUpResponse profileInfo;

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

  _buildOwnProfileView(BuildContext context, SignUpResponse profileInfo) {
    return Scaffold(
      body: Container(
        color: OlukoColors.black,
        child: SafeArea(
          child: SingleChildScrollView(
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
                  userChallenges: ProfileViewConstants.profileChallengesContent,
                  userFriends: ProfileViewConstants.profileFriendsContent),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: CarouselSmallSection(
                  title: ProfileViewConstants.profileOptionsAssessmentVideos,
                  children: [
                    _getImageAndVideoCard('assets/courses/course_sample_3.png',
                        isVideo: true),
                    _getImageAndVideoCard('assets/courses/course_sample_5.png',
                        isVideo: true),
                    _getImageAndVideoCard('assets/courses/course_sample_4.png',
                        isVideo: true),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: CarouselSmallSection(
                  routeToGo: ProfileRoutes.goToTransformationJourney(),
                  title:
                      ProfileViewConstants.profileOptionsTransformationJourney,
                  children: [
                    _getImageAndVideoCard('assets/courses/course_sample_6.png',
                        isVideo: false),
                    _getImageAndVideoCard('assets/courses/course_sample_7.png',
                        isVideo: false),
                    _getImageAndVideoCard('assets/courses/course_sample_8.png',
                        isVideo: false),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0).copyWith(bottom: 0),
                child: CarouselSection(
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
    );
  }

  Future<void> _getProfileInfo() async {
    profileInfo = SignUpResponse.fromJson(
        (await AuthBloc().retrieveLoginData()).toJson());
    return profileInfo;
  }

  Widget _getCourseCard(String assetImage, {double progress}) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: CourseCard(
        imageCover: Image.asset(assetImage),
        progress: progress,
      ),
    );
  }

  Widget _getImageAndVideoCard(String assetImage, {bool isVideo}) {
    return Container(
      color: OlukoColors.black,
      child: ImageAndVideoPreviewCard(
        imageCover: Image.asset(
          assetImage,
          height: 120,
          width: 100,
        ),
        isVideo: isVideo,
      ),
    );
  }
}
