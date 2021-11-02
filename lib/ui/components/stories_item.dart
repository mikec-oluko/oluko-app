import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/dto/story_dto.dart';

class StoriesItem extends StatefulWidget {
  String imageUrl;
  final double maxRadius;
  double progressValue;
  String userStoryId;
  String name;
  final bool showName;
  String lastname;
  List<Story> stories;
  bool _hasUnseenStories = false;

  StoriesItem({this.maxRadius, this.imageUrl, this.userStoryId, this.name, this.lastname, this.stories, this.progressValue = 0, this.showName = true}) {
    checkForUnseenStories();
  }

  void checkForUnseenStories() {
    if (stories != null) {
      if (stories.where((element) => !element.seen).isNotEmpty) {
        _hasUnseenStories = true;
      } else {
        _hasUnseenStories = false;
      }
    }
  }

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StoriesItem> {
  @override
  Widget build(BuildContext context) {
    return /*BlocListener<StoryListBloc, StoryListState>(
        listener: (BuildContext context, StoryListState state) {
          if (state is StoryListUpdate && state.event.snapshot.exists) {
            if (state.event.snapshot.key == widget.userStoryId) {
              final unchangedStories = widget.stories;
              updateData(state.event.snapshot);
              if (unchangedStories != widget.stories) {
                setState(() {
                  widget.checkForUnseenStories();
                });
              }
            }
          }
        },
        child: */Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
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
                  if (widget.imageUrl != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.imageUrl),
                      maxRadius: widget.maxRadius,
                    )
                  else
                    CircleAvatar(
                      maxRadius: widget.maxRadius,
                      backgroundColor: OlukoColors.userColor(widget.name, widget.lastname),
                      child: widget.name != null
                          ? Text(
                              widget.name?.characters?.first.toString().toUpperCase(),
                              style: OlukoFonts.olukoBigFont(
                                customColor: OlukoColors.white,
                                custoFontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : nil,
                    ),
                  if (widget._hasUnseenStories) Image.asset('assets/courses/photo_ellipse.png', scale: 7, color: OlukoColors.secondary)
                ],
              ),
              if (widget.name != null && widget.showName)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: Text(
                    widget.name ?? '',
                    style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w400, fontSize: 12, fontFamily: 'Open Sans'),
                  ),
                )
              else
                const SizedBox()
            ],
          ),
        )/*)*/;
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
      if (storiesAsMap == null) {
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
      if (a.createdAt != null && b.createdAt != null) return a.createdAt?.compareTo(b.createdAt);
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
}
