import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/dto/story_dto.dart';

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
      this.from = StoriesItemFrom.home}) {
    if (getStories == true && currentUserId != null && itemUserId != null && currentUserId.isNotEmpty && itemUserId.isNotEmpty) {
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
    } else if (addUnseenStoriesRing && currentUserId != null && itemUserId != null && currentUserId.isNotEmpty && itemUserId.isNotEmpty) {
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
        bloc: widget.bloc,
        listener: (BuildContext context, StoryListState state) {
          if (state is StoryListUpdate && state?.event?.snapshot?.exists == true) {
            if (state?.event?.snapshot?.key == widget?.itemUserId) {
              final unchangedStories = widget.stories;
              updateData(state.event.snapshot);
              if (unchangedStories != widget.stories) {
                setState(() {
                  widget.checkForUnseenStories();
                });
              }
            }
          } else if (state is GetStoriesSuccess) {
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
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
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
                      widget.currentUserId.isNotEmpty &&
                      widget.itemUserId.isNotEmpty &&
                      widget.name.isNotEmpty &&
                      widget.imageUrl.isNotEmpty)
                    GestureDetector(
                        child: getCircularAvatar(),
                        onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.story], arguments: {
                              'stories': widget.stories,
                              'userId': widget.currentUserId,
                              'userStoriesId': widget.itemUserId,
                              'name': widget.name,
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

  void updateData(DataSnapshot snapshot) {
    if (snapshot.value == null) {
      return;
    }
    updateField(snapshot.value, 'avatar_thumbnail');
    updateField(snapshot.value, 'lastname');
    updateField(snapshot.value, 'name');

    final List<Story> updatedStories = [];
    if (snapshot.value['stories'] != null) {
      final Map<String, dynamic> storiesAsMap = Map<String, dynamic>.from(snapshot.value['stories'] as Map);
      if (storiesAsMap == null || storiesAsMap.isEmpty) {
        return;
      }

      storiesAsMap.forEach((key, story) {
        updatedStories.add(Story.fromJson(Map<String, dynamic>.from(story as Map)));
      });

      sortStories(updatedStories);
      if (updatedStories != null && widget.stories != updatedStories) {
        widget.stories = updatedStories;
      }
    }
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
    if (widget.imageUrl != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(widget.imageUrl),
        maxRadius: widget.maxRadius ?? 30,
      );
    } else {
      return CircleAvatar(
        maxRadius: widget.maxRadius ?? 30,
        backgroundColor: OlukoColors.userColor(widget.name, widget.lastname),
        child: widget.name != null || widget.name.isEmpty
            ? Text(
                widget.name.characters?.first?.toString()?.toUpperCase() ?? '',
                style: OlukoFonts.olukoBigFont(
                  customColor: OlukoColors.white,
                  custoFontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              )
            : nil,
      );
    }
  }

  double getScale() {
    switch (widget.from) {
      case StoriesItemFrom.home:
        return 7;
        break;
      case StoriesItemFrom.friendsModal:
        return 6.2;
        break;
      case StoriesItemFrom.friends:
        return 7.3;
        break;
      default:
        return 7;
    }
  }
}
