import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/utils/user_utils.dart';

import '../../routes.dart';

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

  StoriesItem(
      {this.maxRadius,
      this.imageUrl,
      this.name,
      this.lastname,
      this.stories,
      this.progressValue = 0,
      this.showName = false,
      this.getStories = false,
      this.addUnseenStoriesRing = false,
      this.currentUserId,
      this.itemUserId,
      this.bloc,
      this.from = StoriesItemFrom.home,
      this.isSegmentSection = false}) {
    if (getStories == true &&
        currentUserId != null &&
        itemUserId != null &&
        currentUserId.isNotEmpty &&
        itemUserId.isNotEmpty &&
        bloc != null &&
        GlobalConfiguration().getValue('showStories') == 'true') {
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
    } else if (addUnseenStoriesRing &&
        currentUserId != null &&
        itemUserId != null &&
        currentUserId.isNotEmpty &&
        itemUserId.isNotEmpty &&
        bloc != null) {
      bloc.checkForUnseenStories(currentUserId, itemUserId);
    }
  }

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StoriesItem> {
  @override
  Widget build(BuildContext context) {
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
          padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.fromLTRB(10, 0, 10, 0) : const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (widget._hasUnseenStories)
                    Image.asset('assets/courses/photo_ellipse.png', scale: getScale(), color: OlukoColors.secondary),
                  Positioned(
                    bottom: 0,
                    top: 0,
                    left: 0,
                    right: 0,
                    child: CircularProgressIndicator(
                      value: widget.progressValue,
                      strokeWidth: 6,
                      valueColor: const AlwaysStoppedAnimation<Color>(OlukoColors.primary),
                    ),
                  ),
                  if (widget.stories != null &&
                      widget.stories.isNotEmpty &&
                      widget.currentUserId != null &&
                      widget.itemUserId != null &&
                      widget.name != null &&
                      GlobalConfiguration().getValue('showStories') == 'true')
                    GestureDetector(
                        child: getCircularAvatar(),
                        onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.story], arguments: {
                              'stories': widget.stories,
                              'userId': widget.currentUserId,
                              'userStoriesId': widget.itemUserId,
                              'name': widget.name,
                              'lastname': widget.lastname,
                              'avatarThumbnail': widget.imageUrl
                            }))
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
      return OlukoNeumorphism.isNeumorphismDesign && !widget.isSegmentSection
          ? Neumorphic(
              style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(widget.imageUrl),
                maxRadius: widget.maxRadius ?? 30,
              ),
            )
          : CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.imageUrl),
              maxRadius: widget.maxRadius ?? 30,
            );
    } else {
      return OlukoNeumorphism.isNeumorphismDesign
          ? Neumorphic(
              style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
              child: UserUtils().avatarImageDefault(maxRadius: widget.maxRadius, name: widget.name, lastname: widget.lastname),
            )
          : UserUtils().avatarImageDefault(maxRadius: widget.maxRadius, name: widget.name, lastname: widget.lastname);
    }
  }

  double getScale() {
    switch (widget.from) {
      case StoriesItemFrom.home:
        return 7;
        break;
      case StoriesItemFrom.neumorphicHome:
        return 8.2;
        break;
      case StoriesItemFrom.friendsModal:
        return 6.2;
        break;
      case StoriesItemFrom.friends:
        return 7.3;
        break;
      case StoriesItemFrom.longPressHome:
        return 10;
        break;
      default:
        return 7;
    }
  }
}
