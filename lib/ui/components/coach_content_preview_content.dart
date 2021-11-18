import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import '../../routes.dart';
import 'coach_content_section_card.dart';
import 'coach_video_content.dart';

class CoachContentPreviewContent extends StatefulWidget {
  final CoachContentSection contentFor;
  final String titleForSection;
  final List<SegmentSubmission> segmentSubmissionContent;
  final List<Annotation> coachAnnotationContent;

  const CoachContentPreviewContent({this.contentFor, this.titleForSection, this.segmentSubmissionContent, this.coachAnnotationContent});

  @override
  _CoachContentPreviewContentState createState() => _CoachContentPreviewContentState();
}

class _CoachContentPreviewContentState extends State<CoachContentPreviewContent> {
  Widget imageAndVideoContainer;
  //TODO: CHECK UPDATE TO USE IT ON CAROUSEL COACH
  @override
  Widget build(BuildContext context) {
    return widget.segmentSubmissionContent != null
        ? segmentSubmissionWidget()
        : widget.coachAnnotationContent != null
            ? mentoredVideosWidget()
            : null;
  }

  Row segmentSubmissionWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
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
              padding: EdgeInsets.zero,
              child: GestureDetector(
                onTap: () {
                  widget.segmentSubmissionContent.isNotEmpty ? getRouteForContent(widget.contentFor) : () {};
                },
                child: Container(
                  width: 150,
                  height: 115,
                  color: Colors.black,
                  child: widget.segmentSubmissionContent.isNotEmpty
                      ? CoachVideoContent(videoThumbnail: getThumbnails(segments: widget.segmentSubmissionContent), isForGallery: false)
                      : CoachContentSectionCard(title: widget.titleForSection, needTitle: false),
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Row mentoredVideosWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                widget.titleForSection,
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: EdgeInsets.zero,
              child: GestureDetector(
                onTap: () {
                  widget.coachAnnotationContent.isNotEmpty ? getRouteForContent(widget.contentFor) : () {};
                },
                child: Container(
                  width: 150,
                  height: 115,
                  color: Colors.black,
                  child: widget.coachAnnotationContent.isNotEmpty
                      ? CoachVideoContent(videoThumbnail: getThumbnails(annotations: widget.coachAnnotationContent), isForGallery: false)
                      : CoachContentSectionCard(title: widget.titleForSection, needTitle: false),
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
            arguments: {'coachAnnotation': widget.coachAnnotationContent});
      case CoachContentSection.sentVideos:
        return Navigator.pushNamed(context, routeLabels[RouteEnum.sentVideos],
            arguments: {'sentVideosContent': widget.segmentSubmissionContent});
      case CoachContentSection.recomendedVideos:
        return OlukoLocalizations.get(context, 'recomendedVideos');
      case CoachContentSection.voiceMessages:
        return OlukoLocalizations.get(context, 'voiceMessages');

      default:
    }
  }

  List<String> getThumbnails({List<SegmentSubmission> segments, List<Annotation> annotations}) {
    List<String> thumbnailsList = [];

    if (segments != null && segments.isNotEmpty) {
      List<SegmentSubmission> limitSegments = [];
      segments.length >= 3 ? limitSegments = segments.getRange(0, 3).toList() : limitSegments = segments;

      limitSegments.forEach((segment) {
        if (segment.video.thumbUrl != null) {
          thumbnailsList.add(segment.video.thumbUrl);
        }
      });
    }

    if (annotations != null && annotations.isNotEmpty) {
      List<Annotation> limitAnnotations = [];
      annotations.length >= 3 ? limitAnnotations = annotations.getRange(0, 3).toList() : limitAnnotations = annotations;
      limitAnnotations.forEach((annotation) {
        if (annotation.video.thumbUrl != null) {
          thumbnailsList.add(annotation.video.thumbUrl);
        }
      });
    }
    return thumbnailsList;
  }
}
