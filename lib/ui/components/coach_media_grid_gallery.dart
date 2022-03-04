import 'package:flutter/material.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachMediaGridGallery extends StatefulWidget {
  final List<CoachMedia> coachMedia;
  final bool limitedContent;

  const CoachMediaGridGallery({Key key, this.coachMedia, this.limitedContent = false}) : super(key: key);

  @override
  State<CoachMediaGridGallery> createState() => _CoachMediaGridGalleryState();
}

class _CoachMediaGridGalleryState extends State<CoachMediaGridGallery> {
  final int _limitedContentMaxLength = 6;
  @override
  Widget build(BuildContext context) {
    return coachGridGalleryForMedia(context);
  }

  Container coachGridGalleryForMedia(BuildContext context) {
    return Container(
      width: ScreenUtils.width(context),
      height: ScreenUtils.height(context) / 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: widget.limitedContent
                ? widget.coachMedia.length >= _limitedContentMaxLength
                    ? _limitedContentMaxLength
                    : widget.coachMedia.length
                : widget.coachMedia.length,
            itemBuilder: (context, index) => Card(
                  color: Colors.transparent,
                  child: ImageAndVideoContainer(
                      backgroundImage: widget.coachMedia[index].video.thumbUrl,
                      isContentVideo: true,
                      videoUrl: widget.coachMedia[index].video.url,
                      originalContent: widget.coachMedia[index],
                      isCoachMediaContent: true),
                )),
      ),
    );
  }
}
