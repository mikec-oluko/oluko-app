import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/carrousel_bloc.dart';
import 'package:oluko_app/blocs/class/class_subscription_bloc.dart';
import 'package:oluko_app/blocs/course/course_home_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart';
import 'package:oluko_app/blocs/users_selfies_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/hand_widget.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/selfies_grid.dart';
import 'package:oluko_app/ui/components/stories_header.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_custom_video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/ui/screens/courses/enrolled_course_list_of_classes.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeNeumorphicContent extends StatefulWidget {
  HomeNeumorphicContent({
    this.courseEnrollments,
    this.authState,
    this.courses,
    this.user,
    Key key,
    this.isFromHome = false,
    this.openEditScheduleOnInit = false,
    this.index = 0,
  }) : super(key: key);

  int index;
  final UserResponse user;
  final List<CourseEnrollment> courseEnrollments;
  final List<Course> courses;
  final AuthSuccess authState;
  final bool isFromHome;
  final bool openEditScheduleOnInit;

  @override
  _HomeNeumorphicContentState createState() => _HomeNeumorphicContentState();
}

class _HomeNeumorphicContentState extends State<HomeNeumorphicContent> {
  ScrollController horizontalScrollController;
  CarouselController carouselController = CarouselController();
  ChewieController _controller;
  bool isVideoVisible = false;
  String mediaURL;
  bool showStories = false;
  bool showLogo = false;
  int courseIndex = 0;
  bool _isVideoPlaying = false;
  bool _isBottomTabActive = true;
  List<Course> _activeCourses = [];
  List<Course> _growListOfCourses = [];
  final int _courseChunkMaxValue = 5;
  final bool _horizontalScrollingAvailable = false;

  @override
  void initState() {
    BlocProvider.of<ClassSubscriptionBloc>(context).getStream();
    if (_horizontalScrollingAvailable) {
      horizontalScrollController = ScrollController(initialScrollOffset: widget.index != null ? widget.index * ScreenUtils.width(context) * 0.42 : 0);
    }
    BlocProvider.of<StoryBloc>(context).hasStories(widget.user.id);
    if (_existsCourses()) {
      setState(() {
        _activeCourses = widget.courses;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (horizontalScrollController != null) {
      horizontalScrollController.dispose();
    }
    if (_controller != null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {}
        return homeContainer();
      },
    );
  }

  Widget homeContainer() {
    if (mounted) {
      BlocProvider.of<CarouselBloc>(context).widgetIsHiden(false, widgetIndex: courseIndex);
    }
    if (widget.courseEnrollments.isNotEmpty) {
      return BlocBuilder<CourseHomeBloc, CourseHomeState>(
        builder: (context, courseState) {
          if (courseState is GetByCourseEnrollmentsSuccess) {
            _activeCourses = courseState.courses;
            _addFirstChunkOfCourses();
            if (_activeCourses.isNotEmpty) {
              return enrolled();
            } else {
              returnToHome(context);
              return const SizedBox.shrink();
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

  void returnToHome(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 20), () {
      Navigator.popAndPushNamed(context, routeLabels[RouteEnum.root], arguments: {
        'tab': 0,
      });
    });
  }

  void _addFirstChunkOfCourses() {
    if (_activeCourses.length >= _courseChunkMaxValue) {
      _growListOfCourses = _activeCourses.getRange(0, _courseChunkMaxValue).toList();
    } else {
      _growListOfCourses = _activeCourses;
    }
  }

  bool _existsCourses() => widget.courses != null && widget.courses.isNotEmpty && widget.courses.any((element) => element != null);

  Widget enrolled() {
    if (widget.courseEnrollments.length == _activeCourses.length) {
      return Scaffold(
        extendBody: true,
        backgroundColor: OlukoColors.black,
        body: Container(
          color: OlukoNeumorphismColors.appBackgroundColor,
          child: NestedScrollView(
            physics: OlukoNeumorphism.listViewPhysicsEffect,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 0.0001,
                  ),
                ),
                if (GlobalConfiguration().getString('showStories') == 'true') getStoriesBar(context),
              ];
            },
            body: !_horizontalScrollingAvailable
                ? _getCourseContentView(0, context)
                : CarouselSlider.builder(
                    carouselController: carouselController,
                    itemCount: widget.courseEnrollments.length + 1,
                    itemBuilder: (context, index, int) {
                      _populateGrowListOfCourses(index);
                      if (_growListOfCourses.length - 1 >= index) {
                        if (_growListOfCourses[index] != null) {
                          return _getCourseContentView(index, context);
                        } else {
                          return const SizedBox();
                        }
                      } else {
                        return _getEnrollAndPlusButtonContent(context);
                      }
                    },
                    options: CarouselOptions(
                      scrollPhysics: OlukoNeumorphism.listViewPhysicsEffect,
                      disableCenter: true,
                      enableInfiniteScroll: false,
                      height: ScreenUtils.height(context),
                      initialPage: widget.index ?? 0,
                      viewportFraction: 1,
                      onPageChanged: (index, reason) {
                        if (index <= _activeCourses.length - 1) {
                          courseIndex = index;
                          if (mounted) {
                            BlocProvider.of<CarouselBloc>(context).widgetIsHiden(false, widgetIndex: index);
                          }
                          if (!showLogo) {
                            setState(() {
                              showLogo = true;
                            });
                          }
                        } else {
                          courseIndex = _activeCourses.length + 1;
                          setState(() {
                            showLogo = false;
                          });
                        }
                        if (horizontalScrollController.hasClients) {
                          horizontalScrollController.jumpTo(
                            index * ScreenUtils.width(context) * 0.42,
                          );
                        }
                      },
                    ),
                  ),
          ),
        ),
      );
    } else {
      return OlukoCircularProgressIndicator();
    }
  }

  CustomScrollView _getCourseContentView(int index, BuildContext context) {
    return CustomScrollView(
      cacheExtent: 105.0 * _growListOfCourses[index].classes.length,
      slivers: <Widget>[
        SliverStack(
          children: [
            getClassView(index, context),
            if (_horizontalScrollingAvailable) getTabBar(context, index),
          ],
        ),
      ],
    );
  }

  Container _getEnrollAndPlusButtonContent(BuildContext context) {
    return Container(
      color: OlukoNeumorphismColors.appBackgroundColor,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(top: ScreenUtils.height(context) * 0.15),
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
                  context,
                  routeLabels[RouteEnum.courses],
                  arguments: {
                    'homeEnrollTocourse': true,
                    'showBottomTab': () => setState(() {
                          _isBottomTabActive = !_isBottomTabActive;
                        })
                  },
                );
              },
              child: Neumorphic(
                style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
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

  void _populateGrowListOfCourses(int index) {
    List<Course> newBatchOfCourses = [];
    if (_growListOfCourses.length - 1 == index) {
      if (_growListNewLength < _activeCourses.length) {
        if ((_activeCourses.length - _growListNewLength) >= _courseChunkMaxValue) {
          newBatchOfCourses = _activeCourses.getRange(_growListOfCourses.length, _growListNewLength).toList();
        } else {
          newBatchOfCourses = _activeCourses.getRange(_growListOfCourses.length, _activeCourses.length).toList();
        }
        _growListOfCourses.addAll(newBatchOfCourses);
      } else {
        if (_growListNewLength == _activeCourses.length) {
          _growListOfCourses = _activeCourses;
        }
      }
    }
  }

  int get _growListNewLength => _growListOfCourses.length + _courseChunkMaxValue;

  SliverAppBar getLogo() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      stretch: true,
      backgroundColor: Colors.transparent,
      title: Container(
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker,
                      width: 52,
                      height: 52,
                      child: Image.asset(
                        'assets/courses/left_back_arrow.png',
                        scale: 3.5,
                      )),
                )),
            if (showLogo)
              Image.asset(
                OlukoNeumorphism.mvtLogo,
                scale: 4,
              ),
            if (!widget.isFromHome) HandWidget(authState: widget.authState, onTap: closeVideo),
          ],
        ),
      ),
    );
  }

  Widget getStoriesBar(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, hasStories) {
        showStories = hasStories is HasStoriesSuccess && hasStories.hasStories && showLogo;
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
                widget.user.id,
                onTap: closeVideo,
                maxRadius: 30,
                color: OlukoColors.userColor(widget.authState.user.firstName, widget.authState.user.lastName),
              )
            : const SizedBox(),
      ),
    );
  }

  SliverList getClassView(int index, BuildContext context) {
    BlocProvider.of<VideoBloc>(context).getAspectRatio(_activeCourses[index].video);
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
              key: Key('video$index'),
              onVisibilityChanged: (VisibilityInfo info) {
                if (info.visibleFraction < 0.1 && mounted && courseIndex == index && !_isVideoPlaying && courseIndex <= _activeCourses.length) {
                  BlocProvider.of<CarouselBloc>(context).widgetIsHiden(true, widgetIndex: index);
                } else {
                  if (mounted) {
                    BlocProvider.of<CarouselBloc>(context).widgetIsHiden(false, widgetIndex: index);
                  }
                }
              },
              child: OlukoVideoPreview(
                showBackButton: true,
                image: _activeCourses[index].image,
                video: VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: _activeCourses[index].videoHls, videoUrl: _activeCourses[index].video),
                onBackPressed: () => Navigator.pop(context),
                onPlay: () => isVideoPlaying(),
                videoVisibilty: _isVideoPlaying,
                fromHomeContent: widget.isFromHome,
                bottomWidgets: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      _activeCourses[index].name,
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
            _activeCourses[index].description ?? '',
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
                child: CourseClassCardsList(
                  isFromHome: true,
                  openEditScheduleOnInit: widget.openEditScheduleOnInit ?? false,
                  course: _activeCourses[index],
                  courseEnrollment: widget.courseEnrollments[index],
                  classes: classState.classes,
                  courseIndex: index,
                  closeVideo: closeVideo,
                  onPressed: () => Future.delayed(const Duration(milliseconds: 500), () {
                    BlocProvider.of<CarouselBloc>(context).widgetIsHiden(true, widgetIndex: index);
                  }),
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
    if (horizontalScrollController.hasClients) {
      horizontalScrollController.jumpTo(
        index * ScreenUtils.width(context) * 0.42,
      );
    }
  }

  SliverPinnedHeader tabBarContent(int index) {
    List<GlobalKey> _keys = [];
    return SliverPinnedHeader(
      child: VisibilityDetector(
        key: const Key('tabBar'),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction == 1) {
            horizontalScrollController.position.ensureVisible(
              _keys[index].currentContext.findRenderObject(),
              alignment: 0,
              duration: const Duration(milliseconds: 800),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.only(top: ScreenUtils.smallScreen(context) ? ScreenUtils.height(context) * 0.08 : ScreenUtils.height(context) * 0.06),
          child: Container(
            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            child: SingleChildScrollView(
              physics: OlukoNeumorphism.listViewPhysicsEffect,
              controller: horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.courseEnrollments.map((course) {
                  final i = widget.courseEnrollments.indexOf(course);
                  _keys.add(GlobalKey(debugLabel: i.toString()));
                  return Padding(
                    key: _keys[i],
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
                    child: GestureDetector(
                      onTap: () {
                        carouselController.jumpToPage(i);
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
    if (GlobalConfiguration().getString('showStories') == 'true') {
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
    BlocProvider.of<UsersSelfiesBloc>(context).get();
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
                      padding: EdgeInsets.only(left: 20, top: 20, bottom: showStories ? 0 : 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          OlukoNeumorphism.mvtLogo,
                          scale: 4.5,
                        ),
                      ),
                    ),
                  ),
                  HandWidget(authState: widget.authState, onTap: closeVideo),
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
                    ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  child: SizedBox(
                    height: ScreenUtils.height(context) -
                        (showStories
                            ? ScreenUtils.smallScreen(context)
                                ? ScreenUtils.height(context) * 0.38
                                : ScreenUtils.height(context) * 0.35
                            : ScreenUtils.height(context) * 0.255),
                    width: ScreenUtils.width(context),
                    child: BlocBuilder<UsersSelfiesBloc, UsersSelfiesState>(
                      builder: (context, state) {
                        if (state is UsersSelfiesSuccess) {
                          return SelfiesGrid(images: state.usersSelfies.selfies);
                        } else {
                          return OlukoCircularProgressIndicator();
                        }
                      },
                    ),
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
    return SizedBox(
      width: ScreenUtils.width(context),
      height: showStories ? ScreenUtils.height(context) * 0.72 : ScreenUtils.height(context) * 0.77,
      child: OlukoCustomVideoPlayer(
        videoUrl: videoUrl,
        storiesGap: showStories,
        useOverlay: true,
        isOlukoControls: true,
        closeVideoPlayer: () => setState(() {
          _controller = null;
          isVideoVisible = !isVideoVisible;
        }),
        onVideoFinished: () => setState(() {
          _controller = null;
          isVideoVisible = !isVideoVisible;
        }),
        whenInitialized: (ChewieController chewieController) => setState(() {
          _controller = chewieController;
        }),
      ),
    );
  }

  Widget notEnrolledStoriesHeader(bool showStories) {
    if (showStories) {
      return Align(
        alignment: Alignment.centerLeft,
        child: StoriesHeader(
          widget.user.id,
          onTap: closeVideo,
          maxRadius: 30,
          color: OlukoColors.userColor(widget.authState.user.firstName, widget.authState.user.lastName),
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
              Navigator.pushNamed(
                context,
                routeLabels[RouteEnum.courses],
                arguments: {
                  'backButtonWithFilters': true,
                  'showBottomTab': () => setState(() {
                        _isBottomTabActive = !_isBottomTabActive;
                      })
                },
              );
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
        SizedBox(height: showStories ? ScreenUtils.height(context) * 0.1 : ScreenUtils.height(context) * 0.15),
        GestureDetector(
          onTap: () async {
            final videoUrl = await BlocProvider.of<IntroductionMediaBloc>(context).getVideo(IntroductionMediaTypeEnum.homeVideo);
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
              childContent: Image.asset('assets/courses/play_arrow.png', scale: 3.5, color: OlukoColors.white),
            ),
          ),
        ),
        SizedBox(height: showStories ? ScreenUtils.height(context) * 0.1 : ScreenUtils.height(context) * 0.15),
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
