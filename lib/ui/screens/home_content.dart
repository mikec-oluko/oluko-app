import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course/course_home_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/course_section.dart';
import 'package:oluko_app/ui/components/hand_widget.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/stories_header.dart';
import 'package:oluko_app/ui/components/video_overlay.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class HomeContent extends StatefulWidget {
  HomeContent(this.classIndex, this.index, this.courseEnrollments, this.authState, this.courses, this.user, {Key key}) : super(key: key);

  final int index;
  final int classIndex;
  final UserResponse user;
  final List<CourseEnrollment> courseEnrollments;
  List<Course> courses;
  final AuthSuccess authState;

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final bool showStories = GlobalConfiguration().getString('showStories') == 'true';
  @override
  Widget build(BuildContext context) {
    return form();
  }

  Widget form() {
    return Scaffold(
      backgroundColor: OlukoColors.black,
      appBar: OlukoAppBar(
        title: OlukoLocalizations.get(context, 'home'),
        showLogo: true,
        showBackButton: false,
        actions: [HandWidget(authState: widget.authState)],
        showDivider: false,
        showTitle: false,
      ),
      body: ListView(
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        children: [
          Center(child: StoriesHeader(widget.user.id)),
          WillPopScope(
            onWillPop: () => AppNavigator.onWillPop(context),
            child: OrientationBuilder(
              builder: (context, orientation) {
                return homeContainer();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget homeContainer() {
    if (widget.courseEnrollments.isNotEmpty) {
      return BlocBuilder<CourseHomeBloc, CourseHomeState>(
        builder: (context, courseState) {
          if (courseState is GetByCourseEnrollmentsSuccess) {
            widget.courses = courseState.courses;
            if (widget.courses != null && widget.courses.isNotEmpty && widget.courses.any((element) => element != null)) {
              return enrolled();
            } else {
              return notEnrolled();
            }
          } else {
            return notEnrolled();
          }
        },
      );
    } else {
      return notEnrolled();
    }
  }

  Widget enrolled() {
    if (widget.courseEnrollments.length == widget.courses.length) {
      return CarouselSlider(
        items: courseSectionList(),
        options: CarouselOptions(
          height: ScreenUtils.height(context) - 140,
          disableCenter: true,
          enableInfiniteScroll: false,
          initialPage: widget.index ?? 0,
          viewportFraction: 1,
        ),
      );
    } else {
      return OlukoCircularProgressIndicator();
    }
  }

  List<Widget> courseSectionList() {
    final List<Widget> widgets = [];

    for (var i = 0; i < widget.courseEnrollments.length; i++) {
      if (widget.courses.length - 1 < i) {
        // do nothing
      } else {
        if (widget.courses[i] != null) {
          widgets.add(
            CourseSection(
              classIndex: widget.index == null
                  ? 0
                  : i == widget.index
                      ? widget.classIndex
                      : 0,
              qtyCourses: widget.courses.length,
              courseIndex: i,
              course: widget.courses[i],
              courseEnrollment: widget.courseEnrollments[i],
            ),
          );
        }
      }
    }
    return widgets;
  }

  Widget notEnrolled() {
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (rect) {
            return const LinearGradient(
              stops: [
                0.2,
                0.5,
                0.8,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: OlukoNeumorphismColors.homeGradientColorList,
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.dstIn,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/courses/profile_photos.png'),
                fit: BoxFit.cover,
              ),
            ),
            height: ScreenUtils.height(context) - (showStories ? 200 : 140),
            width: ScreenUtils.width(context),
          ),
        ),
        notErolledContent()
      ],
    );
  }

  Widget enrollButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 90),
      child: Row(
        children: [
          OlukoPrimaryButton(
            title: OlukoLocalizations.get(context, 'enrollInACourse'),
            onPressed: () {
              Navigator.pushNamed(context, routeLabels[RouteEnum.courses], arguments: {'homeEnrollTocourse': 'true'});
            },
          ),
        ],
      ),
    );
  }

  Widget notErolledContent() {
    return Column(
      children: [
        const SizedBox(height: 85),
        Text(
          OlukoLocalizations.get(context, 'welcomeTo'),
          style: OlukoFonts.olukoSubtitleFont(customFontWeight: FontWeight.bold, customColor: OlukoColors.white),
        ),
        const SizedBox(height: 25),
        Image.asset(
          OlukoNeumorphism.mvtLogo,
          scale: 2,
        ),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () async {
              final String mediaURL = await BlocProvider.of<IntroductionMediaBloc>(context).getVideo(IntroductionMediaTypeEnum.homeVideo);
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => VideoOverlay(
                    videoUrl: mediaURL,
                  ),
                ),
              );
            },
            child: Align(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Stack(
                    children: [
                      Align(child: Image.asset('assets/courses/play_ellipse.png', height: 85, width: 85)),
                      Align(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: Image.asset(
                            'assets/courses/play_arrow.png',
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
        enrollButton()
      ],
    );
  }
}
