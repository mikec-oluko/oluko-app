import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/movement_info_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_image_bar.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/movement_items_bubbles_neumorphic.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class MovementIntro extends StatefulWidget {
  MovementSubmodel movementSubmodel;
  Movement movement;

  MovementIntro({Key key, this.movementSubmodel, this.movement}) : super(key: key);

  @override
  _MovementIntroState createState() => _MovementIntroState();
}

class _MovementIntroState extends State<MovementIntro> with TickerProviderStateMixin {
  final toolbarHeight = kToolbarHeight * 2;
  final tabs = ['Intro'];
  Map<String, bool> coursesBookmarked = {};

  //TODO Make Dynamic
  String backgroundImageUrl = 'https://c0.wallpaperflare.com/preview/26/779/700/fitness-men-sports-gym.jpg';
  String _secondTabVideoUrl =
      'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/production%20ID_4701508.mp4?alt=media&token=815819a5-72f9-4bec-bee0-59064c634c03';
  List<Movement> referenceMovements = [
    Movement(
      name: 'Airsquats',
      image: 'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/Airsquats.jpg?alt=media&token=641c2dff-ac0e-4b22-8a8d-aee9adbca3a1',
    ),
    Movement(
      name: 'Body Building',
      image:
          'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_16.png?alt=media&token=2528a228-cabf-49f1-a606-433b83508f42',
    ),
    Movement(
      name: 'Triceps',
      image:
          'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_17.png?alt=media&token=89e4809d-7cc8-40ac-88e0-eebac4ccc93a',
    ),
    Movement(
      name: 'Yoga',
      image:
          'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_3.png?alt=media&token=8918da2d-5f50-45a7-992e-41e3112678f6',
    ),
    Movement(
      name: 'Body Building',
      image:
          'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_16.png?alt=media&token=2528a228-cabf-49f1-a606-433b83508f42',
    ),
  ];
  List<Course> referenceCourses = [
    Course(
      id: '1',
      name: 'Builder Booty',
      image:
          'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_10.png?alt=media&token=e48354c6-6670-472a-9789-516287543cb4',
    ),
    Course(
      id: '2',
      name: 'Marathon Prep',
      image:
          'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_16.png?alt=media&token=2528a228-cabf-49f1-a606-433b83508f42',
    ),
  ];
  // ---------

  //Controllers
  TabController tabController;
  List<ChewieController> _videoControllers = [null];
  List<Key> _videoKeys = [GlobalKey()];
  MovementInfoSuccess _movementInfoSuccess;
  MovementSubmodel _movementSubmodel;

  @override
  void initState() {
    if (widget.movementSubmodel != null) {
      _movementSubmodel = widget.movementSubmodel;
    } else if (widget.movement != null) {
      _movementSubmodel = MovementSubmodel(id: widget.movement.id, name: widget.movement.name);
    }
    super.initState();
  }

  @override
  void dispose() {
    _videoControllers.forEach((controller) {
      controller?.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<MovementInfoBloc>(context).get(_movementSubmodel.id);
    return Scaffold(
      appBar: OlukoNeumorphism.isNeumorphismDesign
          ? OlukoAppBar(
              title: _movementSubmodel.name,
              showTitle: true,
            )
          : OlukoImageBar(actions: [], movements: [_movementSubmodel], onPressedMovement: (context, movement) => {}),
      backgroundColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
      body: Container(
        decoration: OlukoNeumorphism.isNeumorphismDesign
            ? const BoxDecoration(color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark)
            : BoxDecoration(
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.94), BlendMode.darken),
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(backgroundImageUrl),
                ),
              ),
        width: ScreenUtils.width(context),
        height: OlukoNeumorphism.isNeumorphismDesign ? ScreenUtils.height(context) : ScreenUtils.height(context) - toolbarHeight,
        child: OlukoNeumorphism.isNeumorphismDesign ? _viewBodyNeumorphic() : _viewBody(),
      ),
    );
  }

  Widget _viewBody() {
    return BlocBuilder<MovementInfoBloc, MovementInfoState>(
      builder: (context, movementInfoState) {
        if (movementInfoState is MovementInfoSuccess && _movementSubmodel.id == movementInfoState.movement.id) {
          if (_movementInfoSuccess == null) {
            _movementInfoSuccess = movementInfoState;
            movementInfoState.movementVariants.forEach((element) {
              tabs.add(element.name);
              _videoKeys.add(GlobalKey());
              _videoControllers.add(null);
            });

            tabController = TabController(length: tabs.length, vsync: this);
          }
          return Container(
            child: ListView(
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MovementUtils.movementTitle(_movementSubmodel.name),
                                ),
                                const SizedBox(height: 25),
                                Column(
                                  children: [
                                    Container(
                                      width: ScreenUtils.width(context),
                                      decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Colors.white))),
                                      child: TabBar(
                                        isScrollable: true,
                                        onTap: (index) => setState(() {
                                          setState(() {
                                            tabController.index = index;
                                          });
                                        }),
                                        controller: tabController,
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        indicator: const BoxDecoration(color: Colors.white),
                                        tabs: _getTabs(),
                                      ),
                                    ),
                                  ],
                                ),
                                Builder(
                                  builder: (context) {
                                    if (tabController.index == 0) {
                                      return _firstTab(_movementInfoSuccess.movement);
                                    } else {
                                      return _firstTab(movementInfoState.movementVariants[tabController.index - 1]);
                                    }
                                  },
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return OlukoCircularProgressIndicator();
        }
      },
    );
  }

  Widget _viewBodyNeumorphic() {
    return BlocBuilder<MovementInfoBloc, MovementInfoState>(
      builder: (context, movementInfoState) {
        if (movementInfoState is MovementInfoSuccess && _movementSubmodel.id == movementInfoState.movement.id) {
          if (_movementInfoSuccess == null) {
            _movementInfoSuccess = movementInfoState;
            movementInfoState.movementVariants.forEach((element) {
              tabs.add(element.name);
              _videoKeys.add(GlobalKey());
              _videoControllers.add(null);
            });
            tabController = TabController(length: tabs.length, vsync: this);
          }
          return Container(
            child: ListView(
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: ScreenUtils.width(context),
                                      child: TabBar(
                                        isScrollable: true,
                                        onTap: (index) => setState(() {
                                          setState(() {
                                            tabController.index = index;
                                          });
                                        }),
                                        controller: tabController,
                                        indicatorSize: TabBarIndicatorSize.label,
                                        indicator:
                                            const BoxDecoration(border: Border(bottom: BorderSide(color: OlukoNeumorphismColors.initialGradientColorPrimary))),
                                        tabs: _getTabs(),
                                      ),
                                    ),
                                  ],
                                ),
                                Builder(
                                  builder: (context) {
                                    if (tabController.index == 0) {
                                      return _firstTab(_movementInfoSuccess.movement);
                                    } else {
                                      return _firstTab(movementInfoState.movementVariants[tabController.index - 1]);
                                    }
                                  },
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return OlukoCircularProgressIndicator();
        }
      },
    );
  }

  Widget courseRow(Course course) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_videoControllers[tabController.index] != null) {
                      _videoControllers[tabController.index].pause();
                    }
                    Navigator.pushNamed(
                      context,
                      routeLabels[RouteEnum.courseMarketing],
                      arguments: {'course': course, 'fromCoach': false, 'isCoachRecommendation': false},
                    );
                  },
                  child: Container(height: 100, child: CachedNetworkImage(imageUrl: course.image)),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Row(
                      children: [
                        Text(
                          course.name,
                          style: OlukoFonts.olukoBigFont(),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      coursesBookmarked[course.id] = !coursesBookmarked[course.id];
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          Icon(
                            coursesBookmarked[course.id] != null && coursesBookmarked[course.id] == true ? Icons.bookmark : Icons.bookmark_border,
                            size: 20,
                            color: Colors.white,
                          ),
                          Text(
                            OlukoLocalizations.get(context, 'bookMark'),
                            style: OlukoFonts.olukoBigFont(),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget neumorphicCourseRow(Course course) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        decoration: const BoxDecoration(color: OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor, borderRadius: BorderRadius.all(Radius.circular(5))),
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_videoControllers[tabController.index] != null) {
                      _videoControllers[tabController.index].pause();
                    }
                    Navigator.pushNamed(
                      context,
                      routeLabels[RouteEnum.courseMarketing],
                      arguments: {'course': course, 'fromCoach': false, 'isCoachRecommendation': false},
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    height: 150,
                    child: ClipRRect(borderRadius: BorderRadius.circular(5), child: CachedNetworkImage(imageUrl: course.image)),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _videoPlayer(String videoUrl, int index) {
    _clearUnusedVideoControllers(index);
    List<Widget> widgets = [];
    widgets.add(
      OlukoVideoPlayer(
        key: _videoKeys[index],
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) => setState(() {
          _videoControllers[index] = chewieController;
        }),
      ),
    );
    // if (_videoControllers[index] == null) {
    //   widgets.add(Center(child: CircularProgressIndicator()));
    // }
    return widgets;
  }

  _clearUnusedVideoControllers(num currentIndex) {
    for (var i = 0; i < _videoControllers.length; i++) {
      if (i != currentIndex && _videoControllers[i] != null) {
        _videoControllers[i] = null;
      }
    }
  }

  Widget _firstTab(Movement movement) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: OlukoNeumorphism.isNeumorphismDesign
                ? Container(
                    height: 180,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Stack(
                        children: _videoPlayer(
                          VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: movement.videoHls, videoUrl: movement.video),
                          tabController.index,
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: 200,
                    child: Stack(
                      children: _videoPlayer(
                        VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: movement.videoHls, videoUrl: movement.video),
                        tabController.index,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.all(15.0) : const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    movement.description,
                    style: OlukoNeumorphism.isNeumorphismDesign ? OlukoFonts.olukoMediumFont(customColor: Colors.grey) : OlukoFonts.olukoMediumFont(),
                  ),
                ),
                Row(
                  children: [
                    TitleBody(
                      OlukoLocalizations.get(context, 'referenceMovements'),
                      bold: true,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: [
                      MovementItemBubblesNeumorphic(
                        referenceMovementsSection: true,
                        onPressed: (context, movement) {
                          if (_videoControllers[tabController.index] != null) {
                            _videoControllers[tabController.index].pause();
                          }
                          Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement});
                        },
                        content: _movementInfoSuccess.relatedMovements,
                        width: ScreenUtils.width(context) / 1.2,
                      ),
                    ],
                  ),
                ),
                if (_existRelatedCourses)
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TitleBody(
                          OlukoLocalizations.get(context, 'referenceCourses'),
                          bold: true,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox.shrink(),
                if (OlukoNeumorphism.isNeumorphismDesign)
                  !_existRelatedCourses
                      ? const SizedBox.shrink()
                      : Container(
                          alignment: Alignment.centerLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _movementInfoSuccess.relatedCourses
                                  .map(
                                    (Course course) => Padding(
                                      padding: const EdgeInsets.only(right: 20.0),
                                      child: course != null ? neumorphicCourseRow(course) : const SizedBox(),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        )
                else
                  !_existRelatedCourses
                      ? const SizedBox.shrink()
                      : Column(
                          children: _movementInfoSuccess.relatedCourses.map((Course course) => courseRow(course)).toList(),
                        ),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool get _existRelatedCourses => _movementInfoSuccess.relatedCourses.isNotEmpty;

  _secondTab() {
    return Container(
      child: Column(
        children: [
          Container(height: 200, child: Stack(children: _videoPlayer(_secondTabVideoUrl, 1))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _movementInfoSuccess.movement.description,
                    style: OlukoFonts.olukoMediumFont(),
                  ),
                ),
                Row(
                  children: [
                    TitleBody(
                      OlukoLocalizations.get(context, 'referenceMovements'),
                      bold: true,
                    ),
                  ],
                ),
                /*Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    MovementItemBubbles(content: this.referenceMovements, width: ScreenUtils.width(context) / 1.2),
                  ],
                ),
              ),*/
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TitleBody(
                        OlukoLocalizations.get(context, 'referenceCourses'),
                        bold: true,
                      ),
                    ),
                  ],
                ),
                Column(children: referenceCourses.map((Course course) => courseRow(course)).toList()),
              ],
            ),
          )
        ],
      ),
    );
  }

  Tab _tabItem(String name, int index, {bool disabled = false}) {
    return Tab(
      child: Container(
        decoration: const BoxDecoration(),
        child: Text(
          OlukoNeumorphism.isNeumorphismDesign ? name : name.toUpperCase(),
          style: OlukoFonts.olukoMediumFont(
            customColor: disabled != null && disabled == true
                ? Colors.grey.shade700
                : tabController.index == index
                    ? OlukoNeumorphism.isNeumorphismDesign
                        ? Colors.white
                        : OlukoColors.black
                    : OlukoNeumorphism.isNeumorphismDesign
                        ? Colors.grey
                        : Colors.white,
          ),
        ),
      ),
    );
  }

  List<Tab> _getTabs() {
    List<Tab> tabItems = [];
    for (var i = 0; i < tabs.length; i++) {
      tabItems.add(_tabItem(tabs[i], i));
    }
    return tabItems;
  }

  Widget getVideoWidget(String video) {
    if (video != null) {
      return SizedBox(height: 200, child: Stack(children: _videoPlayer(video, tabController.index)));
    } else {
      return const SizedBox();
    }
  }
}
