import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/recommendation_media.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import '../../routes.dart';
import 'coach_content_section_card.dart';
import 'coach_video_content.dart';

class CoachContentPreviewComponent extends StatefulWidget {
  final CoachContentSection contentFor;
  final String titleForSection;
  final List<SegmentSubmission> segmentSubmissionContent;
  final List<Annotation> coachAnnotationContent;
  final List<RecommendationMedia> recommendedVideoContent;
  final Function() onNavigation;
  const CoachContentPreviewComponent(
      {this.contentFor,
      this.titleForSection,
      this.segmentSubmissionContent,
      this.coachAnnotationContent,
      this.onNavigation,
      this.recommendedVideoContent});

  @override
  _CoachContentPreviewComponentState createState() => _CoachContentPreviewComponentState();
}

class _CoachContentPreviewComponentState extends State<CoachContentPreviewComponent> {
  final String _useDefaultImage = 'defaultImage';
  Widget imageAndVideoContainer;
  //TODO: CHECK UPDATE TO USE IT ON CAROUSEL COACH
  @override
  Widget build(BuildContext context) {
    if (widget.segmentSubmissionContent != null && widget.segmentSubmissionContent.isNotEmpty) {
      return segmentSubmissionWidget();
    }
    if (widget.coachAnnotationContent != null && widget.coachAnnotationContent.isNotEmpty) {
      return mentoredVideosWidget();
    }
    if (widget.recommendedVideoContent != null && widget.recommendedVideoContent.isNotEmpty) {
      return recommendedVideosWidget();
    }
    return SizedBox.shrink();
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
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: EdgeInsets.zero,
              child: GestureDetector(
                onTap: () {
                  widget.onNavigation();
                  widget.segmentSubmissionContent.isNotEmpty ? getRouteForContent(widget.contentFor) : () {};
                },
                child: Container(
                  width: 150,
                  height: 120,
                  color: OlukoNeumorphismColors.appBackgroundColor,
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
                  widget.onNavigation();
                  widget.coachAnnotationContent.isNotEmpty ? getRouteForContent(widget.contentFor) : () {};
                },
                child: Container(
                  width: 150,
                  height: 120,
                  color: OlukoNeumorphismColors.appBackgroundColor,
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

  Row recommendedVideosWidget() {
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
                  widget.onNavigation();
                  widget.recommendedVideoContent.isNotEmpty ? getRouteForContent(widget.contentFor) : () {};
                },
                child: Container(
                  width: 150,
                  height: 120,
                  color: OlukoNeumorphismColors.appBackgroundColor,
                  child: widget.recommendedVideoContent.isNotEmpty
                      ? CoachVideoContent(
                          videoThumbnail: getThumbnails(recommendedVideoContent: widget.recommendedVideoContent), isForGallery: false)
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
        return Navigator.pushNamed(context, routeLabels[RouteEnum.coachRecommendedContentGallery],
            arguments: {'recommendedVideoContent': widget.recommendedVideoContent, 'titleForAppBar': widget.titleForSection});
      case CoachContentSection.voiceMessages:
        return OlukoLocalizations.get(context, 'voiceMessages');

      default:
    }
  }

  List<String> getThumbnails(
      {List<SegmentSubmission> segments, List<Annotation> annotations, List<RecommendationMedia> recommendedVideoContent}) {
    List<String> thumbnailsList = [];
    if (segments != null && segments.isNotEmpty) {
      List<SegmentSubmission> limitSegments = [];
      segments.length >= 3 ? limitSegments = segments.getRange(segments.length - 3, segments.length).toList() : limitSegments = segments;

      limitSegments.forEach((segment) {
        if (segment.video.thumbUrl != null) {
          thumbnailsList.add(segment.video.thumbUrl);
        }
      });
    }

    if (annotations != null && annotations.isNotEmpty) {
      List<Annotation> limitAnnotations = [];
      annotations.length >= 3
          ? limitAnnotations = annotations.getRange(annotations.length - 3, annotations.length).toList()
          : limitAnnotations = annotations;
      limitAnnotations.forEach((annotation) {
        if (annotation.video.thumbUrl != null) {
          thumbnailsList.add(annotation.video.thumbUrl);
        } else {
          thumbnailsList.insert(0, _useDefaultImage);
        }
      });
    }

    if (recommendedVideoContent != null && recommendedVideoContent.isNotEmpty) {
      List<RecommendationMedia> limitVideoRecommendation = [];
      recommendedVideoContent.length >= 3
          ? limitVideoRecommendation =
              recommendedVideoContent.getRange(limitVideoRecommendation.length - 3, recommendedVideoContent.length).toList()
          : limitVideoRecommendation = recommendedVideoContent;

      limitVideoRecommendation.forEach((videoRecommended) {
        if (videoRecommended.video.thumbUrl != null) {
          thumbnailsList.add(videoRecommended.video.thumbUrl);
        } else {
          thumbnailsList.insert(0, _useDefaultImage);
        }
      });
    }
    return thumbnailsList;
  }
}
