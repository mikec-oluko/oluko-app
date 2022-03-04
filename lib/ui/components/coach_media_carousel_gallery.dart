import 'package:flutter/material.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';

class CoachMediaCarouselGallery extends StatefulWidget {
  final CoachUser coachUser;
  final List<CoachMedia> coachMedia;

  const CoachMediaCarouselGallery({Key key, this.coachUser, this.coachMedia}) : super(key: key);

  @override
  State<CoachMediaCarouselGallery> createState() => _CoachMediaCarouselGalleryState();
}

class _CoachMediaCarouselGalleryState extends State<CoachMediaCarouselGallery> {
  @override
  Widget build(BuildContext context) {
    return coachMediaCarouselGallery(context);
  }

  Container coachMediaCarouselGallery(BuildContext context) {
    const double _galleryHeight = 180;
    return Container(
        width: MediaQuery.of(context).size.width,
        height: _galleryHeight,
        child: CarouselSmallSection(
          routeToGo: RouteEnum.aboutCoach,
          coachUser: widget.coachUser,
          title: '',
          children: widget.coachMedia
              .map((mediaContent) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ImageAndVideoContainer(
                        backgroundImage: mediaContent.video.thumbUrl,
                        isContentVideo: true,
                        videoUrl: mediaContent.video.url,
                        originalContent: mediaContent,
                        isCoachMediaContent: true),
                  ))
              .toList(),
        ));
  }
}
