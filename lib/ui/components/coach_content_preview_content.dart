import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import '../../routes.dart';
import 'coach_content_section_card.dart';
import 'coach_video_content.dart';
import 'image_and_video_container.dart';

class CoachContentPreviewContent extends StatefulWidget {
  final CoachContentSection contentFor;
  final String titleForSection;
  final List<MovementSubmission> videoContent;
  final bool isForCarousel;

  const CoachContentPreviewContent(
      {this.contentFor, this.titleForSection, this.videoContent, this.isForCarousel = false});

  @override
  _CoachContentPreviewContentState createState() => _CoachContentPreviewContentState();
}

class _CoachContentPreviewContentState extends State<CoachContentPreviewContent> {
  Widget imageAndVideoContainer;

  @override
  void initState() {
    setState(() {
      imageAndVideoContainer = ImageAndVideoContainer(
          backgroundImage: widget.videoContent[0].video.thumbUrl,
          isContentVideo: true,
          videoUrl: widget.videoContent[0].video.url,
          originalContent: widget.videoContent[0],
          isCoach: true,
          isForCarousel: widget.isForCarousel);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                widget.titleForSection,
                // OlukoLocalizations.of(context).find('sentVideos'),
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: GestureDetector(
                onTap: () {
                  widget.videoContent.length != null ? getRouteForContent(widget.contentFor) : () {};
                },
                child: widget.isForCarousel
                    ? Wrap(
                        children: [
                          Container(
                            height: 150,
                            width: 200,
                            color: Colors.black,
                            child: widget.videoContent.length != 0
                                ? CoachVideoContent(
                                    videoThumbnail: widget.videoContent[0].video.thumbUrl,
                                    isForGallery: widget.isForCarousel)
                                : CoachContentSectionCard(
                                    title: widget.titleForSection,
                                    isForCarousel: widget.isForCarousel,
                                    needTitle: false),
                          ),
                        ],
                      )
                    : Container(
                        width: 150,
                        height: 115,
                        color: Colors.black,
                        child: widget.videoContent.length != 0
                            ? CoachVideoContent(
                                videoThumbnail: widget.videoContent[0].video.thumbUrl,
                                isForGallery: widget.isForCarousel)
                            : CoachContentSectionCard(
                                title: widget.titleForSection, isForCarousel: widget.isForCarousel, needTitle: false),
                      ),
              ),
            )
          ],
        )
      ],
    );
  }

  getRouteForContent(CoachContentSection contentFor) {
    switch (contentFor) {
      case CoachContentSection.mentoredVideos:
        return Navigator.pushNamed(context, routeLabels[RouteEnum.mentoredVideos],
            arguments: {'taskSubmissions': widget.videoContent});
      case CoachContentSection.sentVideos:
        return Navigator.pushNamed(context, routeLabels[RouteEnum.sentVideos],
            arguments: {'sentVideosContent': widget.videoContent});
      case CoachContentSection.recomendedVideos:
        return OlukoLocalizations.of(context).find('recomendedVideos');
      case CoachContentSection.voiceMessages:
        return OlukoLocalizations.of(context).find('voiceMessages');

      default:
    }
  }
}
