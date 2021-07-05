import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';
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
  List<Content> listOfContent = [];

  @override
  void initState() {
    setState(() {
      listOfContent = uploadListContent;
    });
    // BlocProvider.of<BlocToUse>(context).method();
    super.initState();
  }

  @override
  void dispose() {
    setState(() {
      listOfContent = [];
    });
    super.dispose();
  }

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
                // BlocListener<AssessmentBloc, AssessmentState>(
                //   listener: (context, state) {
                //     // TODO: implement listener
                //     if (state is AssessmentSuccess) {
                //       listOfContent = state.values;
                //     } else {
                //       listOfContent = uploadListContent;
                //     }
                //   },
                //   child: buildUserContentSection(
                //       titleForSection:
                //           ProfileViewConstants.profileOptionsAssessmentVideos,
                //       routeForSection: ProfileRoutes.goToAssessmentVideos(),
                //       contentForSection: listOfContent),
                // ),
                buildUserContentSection(
                    titleForSection:
                        ProfileViewConstants.profileOptionsAssessmentVideos,
                    routeForSection: ProfileRoutes.goToAssessmentVideos(),
                    contentForSection: returnContentForSection(listOfContent)),
                // BlocListener<SubjectBloc, SubjectState>(
                //   listener: (context, state) {
                //     // TODO: implement listener
                //   },
                //   child: buildUserContentSection(
                //     titleForSection: ProfileViewConstants
                //         .profileOptionsTransformationJourney,
                //     routeForSection: ProfileRoutes.goToTransformationJourney(),
                //   ),
                // ),
                buildUserContentSection(
                    titleForSection: ProfileViewConstants
                        .profileOptionsTransformationJourney,
                    routeForSection: ProfileRoutes.goToTransformationJourney(),
                    contentForSection: returnContentForSection(listOfContent)),
                BlocConsumer<CourseBloc, CourseState>(
                  listener: (context, state) {
                    // TODO: implement listener
                  },
                  builder: (context, state) {
                    return buildCourseSection(context);
                  },
                ),
                buildCourseSection(context),
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

  Padding buildCourseSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0).copyWith(bottom: 0),
      child: CarouselSection(
        height: 250,
        width: MediaQuery.of(context).size.width,
        title: ProfileViewConstants.profileOwnProfileActiveCourses,
        children: [
          _getCourseCard('assets/courses/course_sample_1.png', progress: 0.3),
          _getCourseCard('assets/courses/course_sample_2.png', progress: 0.7),
        ],
      ),
    );
  }

  Padding buildUserContentSection(
      {String routeForSection,
      String titleForSection,
      List<Widget> contentForSection}) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: CarouselSmallSection(
          routeToGo: routeForSection,
          title: titleForSection,
          children: contentForSection),
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
        width: 120,
        height: 120,
        imageCover: Image.asset(assetImage),
        progress: progress,
      ),
    );
  }

  Widget _getImageAndVideoCard(Content contentFromUser) {
    return ImageAndVideoContainer(
      assetImage: contentFromUser.imgUrl,
      isVideo: contentFromUser.isVideo,
    );
  }

  List<Widget> returnContentForSection(List<Content> listOfContent) {
    List<Widget> contentForSection = [];
    listOfContent.forEach((content) {
      contentForSection.add(_getImageAndVideoCard(content));
    });
    return contentForSection.toList();
  }
}
