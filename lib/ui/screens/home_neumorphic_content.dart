import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class/class_subscription_bloc.dart';
import 'package:oluko_app/blocs/course/course_home_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/hand_widget.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/stories_header.dart';
import 'package:oluko_app/ui/components/video_overlay.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/screens/courses/course_marketing.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class HomeNeumorphicContent extends StatefulWidget {
  HomeNeumorphicContent(this.courseEnrollments, this.authState, this.courses, this.user, {Key key, this.index = 0}) : super(key: key);

  int index;
  final User user;
  final List<CourseEnrollment> courseEnrollments;
  List<Course> courses;
  final AuthSuccess authState;

  ScrollController scrollController = ScrollController();
  CarouselController carouselController = CarouselController();

  @override
  _HomeNeumorphicContentState createState() => _HomeNeumorphicContentState();
}

class _HomeNeumorphicContentState extends State<HomeNeumorphicContent> {
  @override
  Widget build(BuildContext context) {
    return homeContainer();
  }

  Widget form() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: homeContainer(),
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
      BlocProvider.of<ClassSubscriptionBloc>(context).getStream();
      BlocProvider.of<StoryBloc>(context).hasStories(widget.user.uid);
      return Scaffold(
        backgroundColor: Colors.black,
        body: CarouselSlider.builder(
          carouselController: widget.carouselController,
          itemCount: widget.courseEnrollments.length,
          itemBuilder: (context, index) {
            if (widget.courses.length - 1 >= index) {
              if (widget.courses[index] != null) {
                return CustomScrollView(
                  slivers: <Widget>[
                    getLogo(),
                    getStoriesBar(context),
                    getTabBar(context, index),
                    getClassView(index, context),
                  ],
                );
              } else {
                return const SizedBox();
              }
            } else {
              return const SizedBox();
            }
          },
          options: CarouselOptions(
            disableCenter: true,
            height: ScreenUtils.height(context),
            initialPage: widget.index ?? 0,
            viewportFraction: 1,
            onPageChanged: (index, reason) => widget.scrollController.jumpTo(
              index * ScreenUtils.width(context) * 0.42,
            ),
          ),
        ),
      );
    } else {
      return OlukoCircularProgressIndicator();
    }
  }

  SliverToBoxAdapter getLogo() {
    return SliverToBoxAdapter(
      child: Container(
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 40),
          child: Align(
            alignment: Alignment.topLeft,
            child: Image.asset(
              'assets/home/mvt.png',
              scale: 4,
            ),
          ),
        ),
      ),
    );
  }

  MediaQuery getStoriesBar(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, hasStories) {
          final bool showStories = hasStories is HasStoriesSuccess && hasStories.hasStories;
          return SliverAppBar(
            automaticallyImplyLeading: false,
            stretch: true,
            toolbarHeight: showStories ? 110 : 50,
            backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            pinned: true,
            title: showStories
                ? Center(
                    child: StoriesHeader(
                      widget.user.uid,
                      maxRadius: 30,
                    ),
                  )
                : const SizedBox(),
          );
        },
      ),
    );
  }

  SliverList getClassView(int index, BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: OverlayVideoPreview(
            image: widget.courses[index].image,
            video: widget.courses[index].video,
            onBackPressed: () => Navigator.pop(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            widget.courses[index].name,
            style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, right: 15),
          child: Text(
            widget.courses[index].description ?? '',
            style: OlukoFonts.olukoBigFont(
              custoFontWeight: FontWeight.normal,
              customColor: OlukoColors.grayColor,
            ),
          ),
        ),
        BlocBuilder<ClassSubscriptionBloc, ClassSubscriptionState>(
          builder: (context, classState) {
            if (classState is ClassSubscriptionSuccess) {
              return CourseMarketing().buildClassEnrolledCards(
                context,
                classState.classes,
                outsideCourse: widget.courses[index],
                outsideCourseEnrollment: widget.courseEnrollments[index],
                outsideCourseIndex: index,
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ]),
    );
  }

  MediaQuery getTabBar(BuildContext context, int index) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: SliverAppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 47,
        backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        pinned: true,
        titleSpacing: 0,
        title: SingleChildScrollView(
          controller: widget.scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.courseEnrollments.map((course) {
              final i = widget.courseEnrollments.indexOf(course);
              return Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: GestureDetector(
                  onTap: () {
                    widget.carouselController.jumpToPage(i);
                    setState(() {
                      widget.index = i;
                    });
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Center(
                            child: Text(
                              course.course.name,
                              style: OlukoFonts.olukoBigFont(
                                custoFontWeight: FontWeight.normal,
                                customColor: i == index ? OlukoColors.white : OlukoColors.grayColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      getSelectedAndScroll(i, index),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget notEnrolled() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: OlukoAppBar(
        title: OlukoLocalizations.get(context, 'home'),
        showLogo: true,
        showBackButton: false,
        actions: [HandWidget(authState: widget.authState)],
        showDivider: true,
        showTitle: false,
      ),
      body: Stack(
        children: [
          ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
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
              height: ScreenUtils.height(context) - 200,
              width: ScreenUtils.width(context),
            ),
          ),
          Image.asset(
            'assets/home/degraded.png',
            // scale: 5,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          notErolledContent()
        ],
      ),
    );
  }

  Widget enrollButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 90),
      child: Row(
        children: [
          OlukoNeumorphicPrimaryButton(
            useBorder: true,
            title: OlukoLocalizations.get(context, 'enrollToACourse'),
            onPressed: () {
              Navigator.pushNamed(context, routeLabels[RouteEnum.courses], arguments: {'homeEnrollTocourse': 'true'});
            },
          )
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
          style: OlukoFonts.olukoSubtitleFont(custoFontWeight: FontWeight.bold, customColor: OlukoColors.white),
        ),
        const SizedBox(height: 25),
        Image.asset(
          'assets/home/mvt.png',
          scale: 2,
        ),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () async {
              final String mediaURL = await BlocProvider.of<IntroductionMediaBloc>(context).getVideo(IntroductionMediaTypeEnum.homeVideo);
              if (mediaURL != null) {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) => VideoOverlay(
                      videoUrl: mediaURL,
                    ),
                  ),
                );
              }
            },
            child: SizedBox(
              width: 65,
              height: 65,
              child: OlukoBlurredButton(
                childContent: Image.asset('assets/courses/play_arrow.png', scale: 3.5, color: OlukoColors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 100),
        enrollButton()
      ],
    );
  }

  Widget getSelectedAndScroll(int selected, int index) {
    if (isSelected(selected, index)) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: OlukoColors.primary,
          width: ScreenUtils.width(context) * 0.42,
          height: 2,
        ),
      );
    }
    return const SizedBox();
  }

  bool isSelected(int selected, int index) => (index != null && selected == index) || (index == null && selected == 0);
}
