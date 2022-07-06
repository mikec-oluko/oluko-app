import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/carrousel_bloc.dart';
import 'package:oluko_app/blocs/class/class_subscription_bloc.dart';
import 'package:oluko_app/blocs/course/course_home_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/hand_widget.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/segment_step_section.dart';
import 'package:oluko_app/ui/components/stories_header.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/ui/screens/courses/enrolled_course.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeNeumorphicContent extends StatefulWidget {
  HomeNeumorphicContent(
      this.courseEnrollments, this.authState, this.courses, this.user,
      {Key key, this.index = 0})
      : super(key: key);

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
  ChewieController _controller;
  bool isVideoVisible = false;
  String mediaURL;
  bool showStories = false;
  bool showLogo = true;
  int courseIndex = 0;
  bool _isVideoPlaying = false;
  bool _isBottomTabActive = true;

  @override
  Widget build(BuildContext context) {
    widget.scrollController = ScrollController(
        initialScrollOffset: widget.index != null
            ? widget.index * ScreenUtils.width(context) * 0.42
            : 0);
    BlocProvider.of<StoryBloc>(context).hasStories(widget.user.uid);
    return homeContainer();
  }

  Widget homeContainer() {
    if (mounted) {
      BlocProvider.of<CarouselBloc>(context)
          .widgetIsHiden(false, widgetIndex: courseIndex);
    }
    if (widget.courseEnrollments.isNotEmpty) {
      return BlocBuilder<CourseHomeBloc, CourseHomeState>(
        builder: (context, courseState) {
          if (courseState is GetByCourseEnrollmentsSuccess) {
            widget.courses = courseState.courses;
            if (widget.courses != null &&
                widget.courses.isNotEmpty &&
                widget.courses.any((element) => element != null)) {
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
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              showLogo ? getLogo() : SliverToBoxAdapter(),
              if (GlobalConfiguration().getValue('showStories') == 'true')
                getStoriesBar(context),
            ];
          },
          body: CarouselSlider.builder(
            carouselController: widget.carouselController,
            itemCount: widget.courseEnrollments.length + 1,
            itemBuilder: (context, index) {
              if (widget.courses.length - 1 >= index) {
                if (widget.courses[index] != null) {
                  return CustomScrollView(
                    cacheExtent: 105.0 * widget.courses[index].classes.length,
                    slivers: <Widget>[
                      SliverStack(children: [
                        getClassView(index, context),
                        getTabBar(context, index),
                      ]),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              } else {
                return Container(
                  color: OlukoNeumorphismColors.appBackgroundColor,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: ScreenUtils.height(context) * 0.15),
                        child: Image.asset(
                          OlukoNeumorphism.mvtLogo,
                          scale: 2,
                        ),
                      ),
                      Positioned(
                        bottom: ScreenUtils.height(context) * 0.1,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, routeLabels[RouteEnum.courses],
                                arguments: {
                    'homeEnrollTocourse': 'true',
                    'showBottomTab': () => setState(() {
                          _isBottomTabActive = !_isBottomTabActive;
                        })
                  });
                          },
                          child: Neumorphic(
                            style: OlukoNeumorphism
                                .getNeumorphicStyleForCircleElement(),
                            child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Image.asset(
                                'assets/home/plus.png',
                                scale: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            options: CarouselOptions(
              disableCenter: true,
              enableInfiniteScroll: false,
              height: ScreenUtils.height(context),
              initialPage: widget.index ?? 0,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                if (index <= widget.courses.length - 1) {
                  courseIndex = index;
                  if (mounted) {
                    BlocProvider.of<CarouselBloc>(context)
                        .widgetIsHiden(false, widgetIndex: index);
                  }
                  if (!showLogo) {
                    setState(() {
                      showLogo = true;
                    });
                  }
                } else {
                  courseIndex = widget.courses.length + 1;
                  setState(() {
                    showLogo = false;
                  });
                }
                if (widget.scrollController.hasClients) {
                  widget.scrollController.jumpTo(
                    index * ScreenUtils.width(context) * 0.42,
                  );
                }
              },
            ),
          ),
        ),
      );
    } else {
      return OlukoCircularProgressIndicator();
    }
  }

  SliverAppBar getLogo() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      stretch: true,
      pinned: true,
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      title: Container(
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              OlukoNeumorphism.mvtLogo,
              scale: 4,
            ),
            HandWidget(authState: widget.authState),
          ],
        ),
      ),
    );
  }

  Widget getStoriesBar(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, hasStories) {
        showStories = hasStories is HasStoriesSuccess &&
            hasStories.hasStories &&
            showLogo;
        return enrolledContent(showStories);
      },
    );
  }

  Widget enrolledContent(bool showStories) {
    return SliverToBoxAdapter(
        child: Container(
      alignment: Alignment.centerLeft,
      color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      child: showStories
          ? StoriesHeader(
              widget.user.uid,
              maxRadius: 30,
              color: OlukoColors.userColor(widget.authState.user.firstName,
                  widget.authState.user.lastName),
            )
          : const SizedBox(),
    ));
  }

  SliverList getClassView(int index, BuildContext context) {
    BlocProvider.of<VideoBloc>(context)
        .getAspectRatio(widget.courses[index].video);
    return SliverList(
      delegate: SliverChildListDelegate([
        GestureDetector(
          onLongPress: () => Navigator.pushNamed(
            context,
            routeLabels[RouteEnum.homeLongPress],
            arguments: {'courseEnrollments': widget.courseEnrollments, 'index': index, 'currentUser': widget.authState.user},
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: VisibilityDetector(
              key: Key('video${index}'),
              onVisibilityChanged: (VisibilityInfo info) {
                if (info.visibleFraction < 0.1 &&
                    mounted &&
                    courseIndex == index &&
                    !_isVideoPlaying &&
                    courseIndex <= widget.courses.length) {
                  BlocProvider.of<CarouselBloc>(context)
                      .widgetIsHiden(true, widgetIndex: index);
                } else {
                  if (mounted) {
                    BlocProvider.of<CarouselBloc>(context)
                        .widgetIsHiden(false, widgetIndex: index);
                  }
                }
              },
              child: OlukoVideoPreview(
                image: widget.courses[index].image,
                video: widget.courses[index].video,
                onBackPressed: () => Navigator.pop(context),
                onPlay: () => isVideoPlaying(),
                videoVisibilty: _isVideoPlaying,
                bottomWidgets: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      widget.courses[index].name,
                      style: OlukoFonts.olukoTitleFont(customFontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, right: 15, left: 15),
          child: Text(
            widget.courses[index].description ?? '',
            style: OlukoFonts.olukoBigFont(
              customFontWeight: FontWeight.normal,
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
                  outSideCloseVideo: closeVideo,
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

  void pauseVideo() {
    if (_controller != null) {
      _controller.pause();
    }
  }

  void isVideoPlaying() {
    return setState(() {
      _isVideoPlaying = !_isVideoPlaying;
    });
  }

  void closeVideo() {
    setState(() {
      if (_isVideoPlaying) {
        _isVideoPlaying = !_isVideoPlaying;
      }
    });
  }

  Widget getTabBar(BuildContext context, int index) {
    return BlocBuilder<CarouselBloc, CarouselState>(
      builder: (context, state) {
        if (state is CarouselSuccess && state.widgetIndex == index) {
          return tabBarContent(index);
        } else {
          return const SliverToBoxAdapter(child: SizedBox());
        }
      },
    );
  }

  void jumpToTab(int index) {
    if (widget.scrollController.hasClients) {
      widget.scrollController.jumpTo(
        index * ScreenUtils.width(context) * 0.42,
      );
    }
  }

  SliverPinnedHeader tabBarContent(int index) {
    List<GlobalKey> _keys = [];
    return SliverPinnedHeader(
      child: VisibilityDetector(
        key: Key('tabBar'),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction == 1) {
            widget.scrollController.position.ensureVisible(
              _keys[index].currentContext.findRenderObject(),
              alignment: 0,
              duration: const Duration(milliseconds: 800),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
              top: ScreenUtils.smallScreen(context)
                  ? ScreenUtils.height(context) * 0.08
                  : ScreenUtils.height(context) * 0.06),
          child: Container(
            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            child: SingleChildScrollView(
              controller: widget.scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.courseEnrollments.map((course) {
                  final i = widget.courseEnrollments.indexOf(course);
                  _keys.add(GlobalKey(debugLabel: i.toString()));
                  return Padding(
                    key: _keys[i],
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 15, bottom: 15),
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
                                    customFontWeight: FontWeight.normal,
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
        ),
      ),
    );
  }

  Widget notEnrolled() {
    if (GlobalConfiguration().getValue('showStories') == 'true') {
      return BlocBuilder<StoryBloc, StoryState>(
        builder: (context, hasStories) {
          final bool showStories =
              hasStories is HasStoriesSuccess && hasStories.hasStories;
          return getNotEnrolledContent(showStories, context);
        },
      );
    } else {
      return getNotEnrolledContent(false, context);
    }
  }

  Scaffold getNotEnrolledContent(bool showStories, BuildContext context) {
    return Scaffold(
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      body: Column(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 20, top: 20, bottom: showStories ? 0 : 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          OlukoNeumorphism.mvtLogo,
                          scale: 4.5,
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
          if (isVideoVisible)
            Container(
              width: ScreenUtils.width(context),
              color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
              child: Padding(
                padding: EdgeInsets.only(bottom: isVideoVisible ? 0 : 16),
                child: Stack(
                  children: [
                    showVideoPlayer(mediaURL, showStories),
                  ],
                ),
              ),
            )
          else
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
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/courses/profile_photos.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: ScreenUtils.height(context) -
                        (showStories
                            ? ScreenUtils.smallScreen(context)
                                ? ScreenUtils.height(context) * 0.43
                                : ScreenUtils.height(context) * 0.35
                            : ScreenUtils.height(context) * 0.24),
                    width: ScreenUtils.width(context),
                  ),
                ),
                Center(child: notErolledContent(showStories))
              ],
            )
        ],
      ),
    );
  }

  Widget showVideoPlayer(String videoUrl, bool showStories) {
    final List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    }
    widgets.add(
      OlukoVideoPlayer(
        isOlukoControls: true,
        videoUrl: videoUrl,
        onVideoFinished: () => setState(() {
          _controller = null;
          isVideoVisible = !isVideoVisible;
        }),
        whenInitialized: (ChewieController chewieController) => setState(() {
          _controller = chewieController;
        }),
      ),
    );
    return SizedBox(
      width: ScreenUtils.width(context),
      height: showStories
          ? ScreenUtils.height(context) * 0.72
          : ScreenUtils.height(context) * 0.77,
      child: Stack(
        children: widgets +
            [
              Positioned(
                top: showStories ? 25 : 15,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller = null;
                      isVideoVisible = !isVideoVisible;
                    });
                  },
                  child: SizedBox(
                    height: 46,
                    width: 46,
                    child: OlukoBlurredButton(
                      childContent: Image.asset(
                        'assets/courses/white_cross.png',
                        scale: 3.5,
                      ),
                    ),
                  ),
                ),
              )
            ],
      ),
    );
  }

  Widget notEnrolledStoriesHeader(bool showStories) {
    if (showStories) {
      return Align(
        alignment: Alignment.centerLeft,
        child: StoriesHeader(
          widget.user.uid,
          maxRadius: 30,
          color: OlukoColors.userColor(
              widget.authState.user.firstName, widget.authState.user.lastName),
        ),
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
            title: OlukoLocalizations.get(context, 'enrollInACourse'),
            onPressed: () {
              Navigator.pushNamed(context, routeLabels[RouteEnum.courses],
                  arguments: {
                    'homeEnrollTocourse': 'true',
                    'showBottomTab': () => setState(() {
                          _isBottomTabActive = !_isBottomTabActive;
                        })
                  });
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
          height: showStories
              ? ScreenUtils.smallScreen(context)
                  ? 0
                  : ScreenUtils.height(context) * 0.1
              : ScreenUtils.height(context) * 0.05,
        ),
        Text(
          OlukoLocalizations.get(context, 'welcomeTo'),
          style: OlukoFonts.olukoSubtitleFont(customFontWeight: FontWeight.bold, customColor: OlukoColors.white),
        ),
        const SizedBox(height: 15),
        Image.asset(
          OlukoNeumorphism.mvtLogo,
          scale: 2.5,
        ),
        SizedBox(
            height: showStories
                ? ScreenUtils.height(context) * 0.1
                : ScreenUtils.height(context) * 0.15),
        GestureDetector(
          onTap: () async {
            final videoUrl =
                await BlocProvider.of<IntroductionMediaBloc>(context)
                    .getVideo(IntroductionMediaTypeEnum.homeVideo);
            if (videoUrl != null) {
              setState(() {
                mediaURL = videoUrl;
                isVideoVisible = true;
              });
            }
          },
          child: SizedBox(
            width: 65,
            height: 65,
            child: OlukoBlurredButton(
              childContent: Image.asset('assets/courses/play_arrow.png',
                  scale: 3.5, color: OlukoColors.white),
            ),
          ),
        ),
        SizedBox(
            height: showStories
                ? ScreenUtils.height(context) * 0.1
                : ScreenUtils.height(context) * 0.15),
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

  bool isSelected(int selected, int index) =>
      (index != null && selected == index) || (index == null && selected == 0);
}
