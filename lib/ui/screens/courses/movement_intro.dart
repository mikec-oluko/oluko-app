import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/movement_info_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/oluko_image_bar.dart';
import 'package:oluko_app/ui/components/movement_item_bubbles.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class MovementIntro extends StatefulWidget {
  Movement movement;

  MovementIntro({Key key, this.movement}) : super(key: key);

  @override
  _MovementIntroState createState() => _MovementIntroState();
}

class _MovementIntroState extends State<MovementIntro> with TickerProviderStateMixin {
  final toolbarHeight = kToolbarHeight * 2;
  final tabs = ['Intro'];
  Map<String, bool> coursesBookmarked = {};

  //TODO Make Dynamic
  Movement movement2 = Movement(
      image:
          'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/Airsquats.jpg?alt=media&token=641c2dff-ac0e-4b22-8a8d-aee9adbca3a1',
      video:
          'https://oluko-mvt.s3.us-west-1.amazonaws.com/assessments/85b2f81c1fe74f9cb5e804c57db30137/85b2f81c1fe74f9cb5e804c57db30137_2.mp4',
      description:
          'Learn practical exercises to gain confidence in yourself, improve your core and focus on strengthening and toning your midsection. You wont regret after these 6 weeks and everybody will notice your effort and your selflove. ',
      name: "Airsquats");
  String backgroundImageUrl = 'https://c0.wallpaperflare.com/preview/26/779/700/fitness-men-sports-gym.jpg';
  String _secondTabVideoUrl =
      'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/production%20ID_4701508.mp4?alt=media&token=815819a5-72f9-4bec-bee0-59064c634c03';
  List<Movement> referenceMovements = [
    Movement(
        name: 'Airsquats',
        image:
            'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/Airsquats.jpg?alt=media&token=641c2dff-ac0e-4b22-8a8d-aee9adbca3a1'),
    Movement(
        name: 'Body Building',
        image:
            'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_16.png?alt=media&token=2528a228-cabf-49f1-a606-433b83508f42'),
    Movement(
        name: 'Triceps',
        image:
            'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_17.png?alt=media&token=89e4809d-7cc8-40ac-88e0-eebac4ccc93a'),
    Movement(
        name: 'Yoga',
        image:
            'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_3.png?alt=media&token=8918da2d-5f50-45a7-992e-41e3112678f6'),
    Movement(
        name: 'Body Building',
        image:
            'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_16.png?alt=media&token=2528a228-cabf-49f1-a606-433b83508f42'),
  ];
  List<Course> referenceCourses = [
    Course(
        id: '1',
        name: 'Builder Booty',
        image:
            'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_10.png?alt=media&token=e48354c6-6670-472a-9789-516287543cb4'),
    Course(
        id: '2',
        name: 'Marathon Prep',
        image:
            'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_16.png?alt=media&token=2528a228-cabf-49f1-a606-433b83508f42'),
  ];
  // ---------

  //Controllers
  TabController tabController;
  List<ChewieController> _videoControllers = [null, null];
  List<Key> _videoKeys = [GlobalKey(), GlobalKey()];
  MovementInfoSuccess _movementInfoSuccess;

  @override
  void initState() {
    // tabController =
    //     TabController(initialIndex: 0, length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<MovementInfoBloc>(context).get(widget.movement.id);
    return Scaffold(
      appBar: OlukoImageBar(actions: [], movements: [widget.movement], onPressedMovement: (context, movement) => {}),
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.94), BlendMode.darken),
                fit: BoxFit.cover,
                image: NetworkImage(backgroundImageUrl))),
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context) - toolbarHeight,
        child: _viewBody(),
      ),
    );
  }

  Widget _viewBody() {
    return BlocBuilder<MovementInfoBloc, MovementInfoState>(builder: (context, movementInfoState) {
      // if (_movementInfoSuccess == null && !(movementInfoState is MovementInfoSuccess)) {
      // }
      if (movementInfoState is MovementInfoSuccess) {
        if (_movementInfoSuccess == null) {
          _movementInfoSuccess = movementInfoState;
          movementInfoState.movementVariants.forEach((element) {
            tabs.add(element.name);
          });
          tabController = TabController(initialIndex: 0, length: tabs.length, vsync: this);
        }
        return Container(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MovementUtils.movementTitle(widget.movement.name),
                          ),
                          SizedBox(height: 25),
                          Column(
                            children: [
                              Container(
                                width: ScreenUtils.width(context),
                                decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Colors.white))),
                                child: TabBar(
                                  isScrollable: true,
                                  onTap: (index) => this.setState(() {
                                    this.setState(() {
                                      tabController.index = index;
                                    });
                                  }),
                                  controller: tabController,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(color: Colors.white),
                                  tabs: _getTabs(),
                                ),
                              ),
                            ],
                          ),
                          Builder(builder: (context) {
                            if (tabController.index == 0) {
                              return _firstTab(widget.movement);
                            } else {
                              return _firstTab(movementInfoState.movementVariants[tabController.index - 1]);
                            }
                          })
                        ],
                      ),
                    )
                  ]),
                ]),
              ),
            ],
          ),
        );
      } else {
        return SizedBox();
      }
    });
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
                      Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],arguments: {'course': course, 'fromCoach': false});
                    },
                    child: Container(height: 100, child: Image.network(course.image)))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
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
                    onTap: () => this.setState(() {
                      coursesBookmarked[course.id] = !coursesBookmarked[course.id];
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            this.coursesBookmarked[course.id] != null && this.coursesBookmarked[course.id] == true
                                ? Icons.bookmark
                                : Icons.bookmark_border,
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

  List<Widget> _videoPlayer(String videoUrl, int index) {
    _clearUnusedVideoControllers(index);
    List<Widget> widgets = [];
    widgets.add(OlukoVideoPlayer(
        key: _videoKeys[index],
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) => this.setState(() {
              _videoControllers[index] = chewieController;
            })));
    if (_videoControllers[index] == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
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
      child: Column(children: [
        Container(height: 200, child: Stack(children: _videoPlayer(movement.video, tabController.index))),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  movement.description,
                  style: OlukoFonts.olukoMediumFont(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    MovementItemBubbles(
                        onPressed: (context, movement) {
                          if (_videoControllers[tabController.index] != null) {
                            _videoControllers[tabController.index].pause();
                          }
                          Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro],arguments: {'movement': movement});
                        },
                        content: this._movementInfoSuccess.relatedMovements,
                        width: ScreenUtils.width(context) / 1.2),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
              Column(children: this._movementInfoSuccess.relatedCourses.map((Course course) => courseRow(course)).toList()),
            ],
          ),
        )
      ]),
    );
  }

  _secondTab() {
    return Container(
      child: Column(children: [
        Container(height: 200, child: Stack(children: _videoPlayer(_secondTabVideoUrl, 1))),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  widget.movement.description,
                  style: OlukoFonts.olukoMediumFont(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    MovementItemBubbles(content: this.referenceMovements, width: ScreenUtils.width(context) / 1.2),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
      ]),
    );
  }

  Tab _tabItem(String name, int index, {bool disabled = false}) {
    return Tab(
      child: Container(
        decoration: BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            name.toUpperCase(),
            style: OlukoFonts.olukoMediumFont(
                customColor: disabled != null && disabled == true
                    ? Colors.grey.shade700
                    : tabController.index == index
                        ? Colors.black
                        : Colors.white),
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
}
