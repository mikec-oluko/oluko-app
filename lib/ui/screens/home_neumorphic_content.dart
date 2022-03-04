import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
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
import 'package:oluko_app/ui/components/hand_widget.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/stories_header.dart';
import 'package:oluko_app/ui/components/video_overlay.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/screens/courses/enrolled_course.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class HomeNeumorphicContent extends StatefulWidget {
  HomeNeumorphicContent(this.courseEnrollments, this.authState, this.courses, this.user, {Key key, this.index = 0}) : super(key: key);

  int index;
  final User user;
  final List<CourseEnrollment> courseEnrollments;
  List<Course> courses;
  final AuthSuccess authState;

  ScrollController scrollController;
  CarouselController carouselController = CarouselController();

  @override
  _HomeNeumorphicContentState createState() => _HomeNeumorphicContentState();
}

class _HomeNeumorphicContentState extends State<HomeNeumorphicContent> {
  @override
  Widget build(BuildContext context) {
    widget.scrollController =
        ScrollController(initialScrollOffset: widget.index != null ? widget.index * ScreenUtils.width(context) * 0.42 : 0);
    BlocProvider.of<StoryBloc>(context).hasStories(widget.user.uid);
    return homeContainer();
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
            return OlukoCircularProgressIndicator();
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
      return Scaffold(
        backgroundColor: OlukoColors.black,
        body: CarouselSlider.builder(
          carouselController: widget.carouselController,
          itemCount: widget.courseEnrollments.length,
          itemBuilder: (context, index) {
            if (widget.courses.length - 1 >= index) {
              if (widget.courses[index] != null) {
                return CustomScrollView(
                  slivers: <Widget>[
                    getLogo(),
                    if (GlobalConfiguration().getValue('showStories') == 'true') getStoriesBar(context),
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
            enableInfiniteScroll: false,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/home/mvt.png',
                scale: 4,
              ),
              HandWidget(authState: widget.authState),
            ],
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
          return enrolledContent(showStories);
        },
      ),
    );
  }

  SliverAppBar enrolledContent(bool showStories) {
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
  }

  SliverList getClassView(int index, BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        GestureDetector(
          onLongPress: () => Navigator.pushNamed(context, routeLabels[RouteEnum.homeLongPress],
              arguments: {'courseEnrollments': widget.courseEnrollments, 'index': index}),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: OverlayVideoPreview(
              image: widget.courses[index].posterImage ?? widget.courses[index].image,
              video: widget.courses[index].video,
              onBackPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            widget.courses[index].name,
            style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, right: 15, left: 15),
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: EnrolledCourse().buildClassEnrolledCards(
                  context,
                  classState.classes,
                  outsideCourse: widget.courses[index],
                  outsideCourseEnrollment: widget.courseEnrollments[index],
                  outsideCourseIndex: index,
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ]),
    );
  }

  Widget getTabBar(BuildContext context, int index) {
    if (GlobalConfiguration().getValue('showStories') == 'true') {
      return MediaQuery.removePadding(context: context, removeTop: true, child: tabBarContent(index));
    } else {
      return tabBarContent(index);
    }
  }

  SliverAppBar tabBarContent(int index) {
    return SliverAppBar(
      bottom: const PreferredSize(
        preferredSize: Size(double.infinity, 5),
        child: OlukoNeumorphicDivider(),
      ),
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
    );
  }

  Widget notEnrolled() {
    if (GlobalConfiguration().getValue('showStories') == 'true') {
      return BlocBuilder<StoryBloc, StoryState>(
        builder: (context, hasStories) {
          final bool showStories = hasStories is HasStoriesSuccess && hasStories.hasStories;
          return getNotEnrolledContent(showStories, context);
        },
      );
    } else {
      return getNotEnrolledContent(false, context);
    }
  }

  Scaffold getNotEnrolledContent(bool showStories, BuildContext context) {
    return Scaffold(
      backgroundColor: OlukoColors.black,
      body: Column(
        children: [
          Container(
            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, top: 40, bottom: showStories ? 0 : 40),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            'assets/home/mvt.png',
                            scale: 4,
                          ),
                        ),
                      ),
                    ),
                    HandWidget(authState: widget.authState),
                  ],
                ),
                notEnrolledStoriesHeader(showStories),
              ],
            ),
          ),
          Stack(
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
                //blendMode: BlendMode.dstIn,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/courses/profile_photos.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: ScreenUtils.height(context) - (showStories ? 240 : 181),
                  width: ScreenUtils.width(context),
                ),
              ),
              Center(child: notErolledContent(showStories))
            ],
          ),
        ],
      ),
    );
  }

  Widget notEnrolledStoriesHeader(bool showStories) {
    if (showStories) {
      return StoriesHeader(
        widget.user.uid,
        maxRadius: 30,
      );
    } else {
      return const SizedBox();
    }
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

  Widget notErolledContent(bool showStories) {
    return Column(
      children: [
        SizedBox(
          height: showStories ? 40 : 80,
        ),
        Text(
          OlukoLocalizations.get(context, 'welcomeTo'),
          style: OlukoFonts.olukoSubtitleFont(custoFontWeight: FontWeight.bold, customColor: OlukoColors.white),
        ),
        const SizedBox(height: 15),
        Image.asset(
          'assets/home/mvt.png',
          scale: 2,
        ),
        const SizedBox(height: 80),
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
        const SizedBox(height: 30),
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
