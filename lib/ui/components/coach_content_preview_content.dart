import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/coach_media_message.dart';
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
  final List<CoachMediaMessage> coachMediaMessages;
  final Function() onNavigation;
  const CoachContentPreviewComponent(
      {this.contentFor,
      this.titleForSection,
      this.segmentSubmissionContent,
      this.coachAnnotationContent,
      this.coachMediaMessages,
      this.onNavigation,
      this.recommendedVideoContent});

  @override
  _CoachContentPreviewComponentState createState() => _CoachContentPreviewComponentState();
}

class _CoachContentPreviewComponentState extends State<CoachContentPreviewComponent> {
  final String _useDefaultImage = 'defaultImage';
  Widget imageAndVideoContainer;
  @override
  Widget build(BuildContext context) {
    if (widget.segmentSubmissionContent != null && widget.segmentSubmissionContent.isNotEmpty) {
      return segmentSubmissionWidget();
    }
    if ((widget.coachAnnotationContent != null && widget.coachAnnotationContent.isNotEmpty) ||
        (widget.coachMediaMessages != null && widget.coachMediaMessages.isNotEmpty)) {
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
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 2),
              child: Text(
                widget.titleForSection,
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
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
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 2),
              child: Text(
                widget.titleForSection,
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
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
                      ? CoachVideoContent(
                          videoThumbnail: getThumbnails(annotations: widget.coachAnnotationContent, coachMediaMessages: widget.coachMediaMessages),
                          isForGallery: false)
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
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 2),
              child: Text(
                widget.titleForSection,
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
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
                      ? CoachVideoContent(videoThumbnail: getThumbnails(recommendedVideoContent: widget.recommendedVideoContent), isForGallery: false)
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
            arguments: {'coachAnnotation': widget.coachAnnotationContent, 'coachVideoMessages': widget.coachMediaMessages});
      case CoachContentSection.sentVideos:
        return Navigator.pushNamed(context, routeLabels[RouteEnum.sentVideos], arguments: {'sentVideosContent': widget.segmentSubmissionContent});
      case CoachContentSection.recomendedVideos:
        return Navigator.pushNamed(context, routeLabels[RouteEnum.coachRecommendedContentGallery],
            arguments: {'recommendedVideoContent': widget.recommendedVideoContent, 'titleForAppBar': widget.titleForSection});
      case CoachContentSection.voiceMessages:
        return OlukoLocalizations.get(context, 'voiceMessages');

      default:
    }
  }

  List<String> getThumbnails(
      {List<SegmentSubmission> segments,
      List<Annotation> annotations,
      List<RecommendationMedia> recommendedVideoContent,
      final List<CoachMediaMessage> coachMediaMessages}) {
    List<String> thumbnailsList = [];
    if (segments != null && segments.isNotEmpty) {
      List<SegmentSubmission> limitSegments = [];
      segments.length >= 3 ? limitSegments = segments.getRange(segments.length - 3, segments.length).toList() : limitSegments = segments;

      limitSegments.forEach((segment) {
        if (segment.video.thumbUrl != null) {
          thumbnailsList.add(segment.video.thumbUrl);
        } else {
          thumbnailsList.add(_useDefaultImage);
        }
      });
    }

    if (annotations != null || coachMediaMessages != null) {
      List<String> personalizedVideosThumbnails = [];
      if (annotations.isNotEmpty) {
        annotations.forEach((annotationItem) {
          if (annotationItem.video.thumbUrl != null) {
            personalizedVideosThumbnails.add(annotationItem.video.thumbUrl);
          } else {
            personalizedVideosThumbnails.insert(0, _useDefaultImage);
          }
        });
      }
      if (coachMediaMessages.isNotEmpty) {
        coachMediaMessages.forEach((mediaMessage) {
          if (mediaMessage.video.thumbUrl != null) {
            personalizedVideosThumbnails.add(mediaMessage.video.thumbUrl);
          } else {
            personalizedVideosThumbnails.insert(0, _useDefaultImage);
          }
        });
      }

      thumbnailsList = personalizedVideosThumbnails.isEmpty
          ? thumbnailsList = [_useDefaultImage]
          : personalizedVideosThumbnails.length >= 3
              ? thumbnailsList = personalizedVideosThumbnails.getRange(0, 3).toList()
              : thumbnailsList = personalizedVideosThumbnails;
    }

    if (recommendedVideoContent != null && recommendedVideoContent.isNotEmpty) {
      List<RecommendationMedia> limitVideoRecommendation = [];
      recommendedVideoContent.length >= 3
          ? limitVideoRecommendation = recommendedVideoContent.getRange(recommendedVideoContent.length - 3, recommendedVideoContent.length).toList()
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
