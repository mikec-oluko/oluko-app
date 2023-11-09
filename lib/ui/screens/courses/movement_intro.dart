import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/movement_info_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/enums/neumorphic_button_shape.dart';
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
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
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

  //Controllers
  TabController tabController;

  ChewieController videoController;
  // List<ChewieController> _videoControllers = [null];
  List<Key> _videoKeys = [GlobalKey()];
  MovementInfoSuccess _movementInfoSuccess;
  MovementSubmodel _movementSubmodel;
  List<Tab> currentTabs;

  @override
  void initState() {
    if (widget.movementSubmodel != null) {
      _movementSubmodel = widget.movementSubmodel;
    } else if (widget.movement != null) {
      _movementSubmodel = MovementSubmodel(id: widget.movement.id, name: widget.movement.name);
    }
    BlocProvider.of<MovementInfoBloc>(context).get(_movementSubmodel.id);
    super.initState();
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoNeumorphism.isNeumorphismDesign
          ? OlukoAppBar(
              title: _movementSubmodel.name,
              showTitle: true,
            )
          : OlukoImageBar(actions: [], movements: [_movementSubmodel], onPressedMovement: () => {}),
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      body: Container(
        decoration: const BoxDecoration(color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark),
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context),
        child: _viewBodyNeumorphic(),
      ),
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
            });
            tabController = TabController(length: tabs.length, vsync: this);
            currentTabs = _getTabs();
          }
          return Container(
            child: ListView(
              physics: OlukoNeumorphism.listViewPhysicsEffect,
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
                                          tabController.index = index;
                                        }),
                                        controller: tabController,
                                        indicatorSize: TabBarIndicatorSize.label,
                                        indicator:
                                            const BoxDecoration(border: Border(bottom: BorderSide(color: OlukoNeumorphismColors.initialGradientColorPrimary))),
                                        tabs: currentTabs,
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
    return [
      OlukoVideoPlayer(
        key: _videoKeys[index],
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) => setState(() {
          videoController = chewieController;
        }),
      ),
    ];
  }

  Widget _firstTab(Movement movement) {
    return Container(
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
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
              )),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    movement.description,
                    style: OlukoFonts.olukoMediumFont(customColor: Colors.grey),
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
                        movement: movement,
                        movementSubmodel: _movementSubmodel,
                        referenceMovementsSection: true,
                        replaceView: true,
                        onPressed: () {},
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
                if (!_existRelatedCourses)
                  const SizedBox.shrink()
                else
                  Container(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      physics: OlukoNeumorphism.listViewPhysicsEffect,
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
              ],
            ),
          )
        ],
      ),
    );
  }

  bool get _existRelatedCourses => _movementInfoSuccess.relatedCourses.isNotEmpty;

  Tab _tabItem(String name, int index, {bool disabled = false}) {
    return Tab(
      child: Container(
        decoration: const BoxDecoration(),
        child: Text(
          name,
          style: OlukoFonts.olukoMediumFont(
              customColor: disabled != null && disabled == true
                  ? Colors.grey.shade700
                  : tabController.index == index
                      ? Colors.white
                      : Colors.grey),
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
