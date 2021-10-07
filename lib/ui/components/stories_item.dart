import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/dto/story_dto.dart';

class StoriesItem extends StatefulWidget {
  final String imageUrl;
  final double maxRadius;
  double progressValue;
  final String name;
  final bool showName;
  final String lastname;
  final String avatar;
  final String avatar_thumbnail;
  final List<Story> stories;
  bool _hasUnseenStories = false;

  StoriesItem({this.maxRadius, this.imageUrl, this.name, this.lastname, this.avatar, this.avatar_thumbnail, this.stories, this.progressValue = 0, this.showName = true}) {
    if (stories != null) {
      if (stories.where((element) => !element.seen).isNotEmpty) {
        _hasUnseenStories = true;
      }
    }
  }

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StoriesItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
                          widget.name?.characters.first.toString().toUpperCase(),
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
    );
  }
}
