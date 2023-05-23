import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/user_utils.dart';

class StoriesItem extends StatefulWidget {
  StoryListBloc bloc;
  final double maxRadius;
  final double progressValue;
  final String itemUserId;
  final String currentUserId;
  final bool showName;
  final bool getStories;
  final bool addUnseenStoriesRing;
  final bool isSegmentSection;
  String imageUrl;
  String name;
  String lastname;
  List<Story> stories;
  bool _hasUnseenStories = false;
  StoriesItemFrom from;
  UserProgressStreamBloc userProgressStreamBloc;
  UserProgress userProgress;
  bool showUserProgress;
  Color color;
  final Function onTap;
  final bool isLoadingState;

  StoriesItem(
      {this.maxRadius,
      this.imageUrl,
      this.userProgress,
      this.name,
      this.lastname,
      this.stories,
      this.progressValue = 0,
      this.showName = false,
      this.showUserProgress = false,
      this.getStories = false,
      this.addUnseenStoriesRing = false,
      this.currentUserId,
      this.userProgressStreamBloc,
      this.itemUserId,
      this.bloc,
      this.from = StoriesItemFrom.home,
      this.isSegmentSection = false,
      this.color,
      this.onTap,
      this.isLoadingState = false}) {
    if (getStories == true &&
        currentUserId != null &&
        itemUserId != null &&
        currentUserId.isNotEmpty &&
        itemUserId.isNotEmpty &&
        bloc != null &&
        GlobalConfiguration().getString('showStories') == 'true') {
      getStoriesFromUser();
    }
    checkForUnseenStories();
  }

  void getStoriesFromUser() {
    bloc.getStoriesFromUser(currentUserId, itemUserId);
  }

  void checkForUnseenStories() {
    if (stories != null && stories.isNotEmpty) {
      if (stories.where((element) => !element.seen).isNotEmpty) {
        _hasUnseenStories = true;
      } else {
        _hasUnseenStories = false;
      }
    } else if (addUnseenStoriesRing && currentUserId != null && itemUserId != null && currentUserId.isNotEmpty && itemUserId.isNotEmpty && bloc != null) {
      bloc.checkForUnseenStories(currentUserId, itemUserId);
    }
  }

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StoriesItem> {
  UserProgress _userProgress;

  @override
  void initState() {
    if (widget.userProgress != null) {
      _userProgress = widget.userProgress;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userProgress != null && _userProgress == null) {
      _userProgress = widget.userProgress;
    }
    return BlocListener<StoryListBloc, StoryListState>(
        bloc: widget.bloc ?? StoryListBloc(),
        listener: (context, state) {
          if (state is GetStoriesSuccess && state.stories != null && state.stories.isNotEmpty) {
            setState(() {
              widget.stories = state.stories;
              widget.checkForUnseenStories();
            });
          } else if (state is GetUnseenStories) {
            setState(() {
              widget._hasUnseenStories = state.hasUnseenStories;
            });
          }
        },
        child: Padding(
          padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.all(10) : const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (true) Image.asset('assets/courses/photo_ellipse.png', scale: getScale(), color: OlukoColors.secondary),
                  if (widget.showUserProgress) Positioned(bottom: 0, top: 0, left: 0, right: 0, child: userProgressIndicator()) else const SizedBox(),
                  if (widget.stories != null &&
                      widget.stories.isNotEmpty &&
                      widget.currentUserId != null &&
                      widget.itemUserId != null &&
                      widget.name != null &&
                      GlobalConfiguration().getString('showStories') == 'true')
                    GestureDetector(
                      child: getCircularAvatar(),
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap();
                        }
                        Navigator.pushNamed(
                          context,
                          routeLabels[RouteEnum.story],
                          arguments: {
                            'stories': widget.stories,
                            'userId': widget.currentUserId,
                            'userStoriesId': widget.itemUserId,
                            'name': widget.name,
                            'lastname': widget.lastname,
                            'avatarThumbnail': widget.imageUrl
                          },
                        );
                      },
                    )
                  else
                    getCircularAvatar()
                ],
              ),
              if (widget.showName && widget.name != null && widget.name.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: Text(
                    widget.name,
                    style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w400, fontSize: 12, fontFamily: 'Open Sans'),
                  ),
                )
            ],
          ),
        ));
  }

  void sortStories(List<Story> updatedStories) {
    updatedStories.sort((a, b) {
      if (a.seen && !b.seen) return 1;
      if (!a.seen && b.seen) return -1;
      if (a.createdAt != null && b.createdAt != null) return a.createdAt.compareTo(b.createdAt);
      return 0;
    });
  }

  void updateField(snapValue, String fieldName) {
    if (snapValue[fieldName] != null) {
      final attrUpdated = snapValue[fieldName].toString();
      if (fieldName == 'avatar_thumbnail') {
        if (widget.imageUrl != attrUpdated) {
          widget.imageUrl = attrUpdated;
        }
      }
      if (fieldName == 'lastname') {
        if (widget.lastname != attrUpdated) {
          widget.lastname = attrUpdated;
        }
      }
      if (fieldName == 'name') {
        if (widget.name != attrUpdated) {
          widget.name = attrUpdated;
        }
      }
    }
  }

  Widget getCircularAvatar() {
    if (widget.imageUrl != null && widget.imageUrl != 'null') {
      final _sizeBasedOnRadius = widget.maxRadius * 2;
      return OlukoNeumorphism.isNeumorphismDesign && !widget.isSegmentSection
          ? Neumorphic(
              style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
              child: CachedNetworkImage(
                width: _sizeBasedOnRadius ?? 50,
                height: _sizeBasedOnRadius ?? 50,
                maxWidthDiskCache: widget.maxRadius != null ? (_sizeBasedOnRadius * 2.5).toInt() : 100,
                maxHeightDiskCache: widget.maxRadius != null ? (_sizeBasedOnRadius * 2.5).toInt() : 100,
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => widget.isLoadingState
                    ? OlukoCircularProgressIndicator()
                    : CircleAvatar(
                        backgroundImage: imageProvider,
                        maxRadius: widget.maxRadius ?? 30,
                      ),
                imageUrl: widget.imageUrl,
              ),
            )
          : CachedNetworkImage(
              fit: BoxFit.contain,
              maxWidthDiskCache: widget.maxRadius != null ? (_sizeBasedOnRadius * 2.5).toInt() : 100,
              maxHeightDiskCache: widget.maxRadius != null ? (_sizeBasedOnRadius * 2.5).toInt() : 100,
              imageBuilder: (context, imageProvider) => widget.isLoadingState
                  ? OlukoCircularProgressIndicator()
                  : CircleAvatar(
                      backgroundImage: imageProvider,
                      maxRadius: widget.maxRadius ?? 30,
                    ),
              imageUrl: widget.imageUrl,
            );
    } else {
      return OlukoNeumorphism.isNeumorphismDesign
          ? Neumorphic(
              style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
              child: UserUtils.avatarImageDefault(
                  maxRadius: widget.maxRadius, name: widget.name, lastname: widget.lastname, circleColor: widget.color, isLoadingState: widget.isLoadingState))
          : UserUtils.avatarImageDefault(maxRadius: widget.maxRadius, name: widget.name, lastname: widget.lastname, isLoadingState: widget.isLoadingState);
    }
  }

  double getScale() {
    switch (widget.from) {
      case StoriesItemFrom.home:
        return 12;
        break;
      case StoriesItemFrom.neumorphicHome:
        return 15.2;
        break;
      case StoriesItemFrom.friendsModal:
        return 13.2;
        break;
      case StoriesItemFrom.friends:
        return 14.3;
        break;
      case StoriesItemFrom.longPressHome:
        return 10;
        break;
      default:
        return 7;
    }
  }

  Widget userProgressIndicator() {
    if (widget.userProgressStreamBloc != null) {
      return BlocConsumer<UserProgressStreamBloc, UserProgressStreamState>(
        bloc: widget.userProgressStreamBloc,
        listener: (context, userProgressStreamState) {
          blocConsumerCondition(userProgressStreamState);
        },
        builder: (context, userProgressStreamState) {
          return greenCircle();
        },
      );
    } else {
      return BlocConsumer<UserProgressStreamBloc, UserProgressStreamState>(
        listener: (context, userProgressStreamState) {
          blocConsumerCondition(userProgressStreamState);
        },
        builder: (context, userProgressStreamState) {
          return greenCircle();
        },
      );
    }
  }

  void blocConsumerCondition(UserProgressStreamState userProgressStreamState) {
    if (userProgressStreamState is UserProgressUpdate && userProgressStreamState.obj.id == widget.itemUserId) {
      setState(() {
        _userProgress = userProgressStreamState.obj;
      });
    } else if (userProgressStreamState is UserProgressAdd && userProgressStreamState.obj.id == widget.itemUserId) {
      setState(() {
        _userProgress = userProgressStreamState.obj;
      });
    } else if (userProgressStreamState is UserProgressRemove && userProgressStreamState.obj.id == widget.itemUserId) {
      setState(() {
        _userProgress.progress = 0;
      });
    }
  }

  Widget greenCircle() {
    return CircularProgressIndicator(
      value: _userProgress != null ? _userProgress.progress : 0,
      strokeWidth: 7,
      valueColor: const AlwaysStoppedAnimation<Color>(OlukoColors.primary),
    );
  }
}
