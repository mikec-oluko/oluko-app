import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/recommendation_media.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'submodels/course_timeline_submodel.dart';

class CoachTimelineItem extends Base with EquatableMixin {
  String coachId;
  DocumentReference coachReference;
  DocumentReference contentReference;
  String contentDescription;
  String contentName;
  String contentThumbnail;
  TimelineInteractionType contentType;
  CourseTimelineSubmodel course;
  Movement movementForNavigation;
  Course courseForNavigation;
  RecommendationMedia recommendationMedia;
  List<Annotation> mentoredVideosForNavigation;
  List<SegmentSubmission> sentVideosForNavigation;
  CoachMediaMessage coachMediaMessage;

  CoachTimelineItem(
      {this.coachId,
      this.coachReference,
      this.contentReference,
      this.contentDescription,
      this.contentName,
      this.contentThumbnail,
      this.contentType,
      this.course,
      this.courseForNavigation,
      this.movementForNavigation,
      this.mentoredVideosForNavigation,
      this.sentVideosForNavigation,
      this.coachMediaMessage,
      this.recommendationMedia,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(
            id: id,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
            isDeleted: isDeleted,
            isHidden: isHidden);

  factory CoachTimelineItem.fromJson(Map<String, dynamic> json) {
    CoachTimelineItem coachTimelineItem = CoachTimelineItem(
      coachId: json['coach_id'].toString(),
      coachReference: json['coach_reference'] is DocumentReference ? json['coach_reference'] as DocumentReference : null,
      contentReference: json['content_reference'] is DocumentReference ? json['content_reference'] as DocumentReference : null,
      contentDescription: json['content_description'] != null ? json['content_description'].toString() : null,
      contentName: json['content_name'] != null ? json['content_name'].toString() : null,
      contentThumbnail: json['content_thumbnail'] != null ? json['content_thumbnail'].toString() : null,
      //contentType: json['content_type'] as num,
      contentType: json['content_type'] is int ? TimelineInteractionType.values[json['content_type'] as int] : null,
      course: json['course'] == null ? CourseTimelineSubmodel() : CourseTimelineSubmodel.fromJson(json['course'] as Map<String, dynamic>),
    );
    coachTimelineItem.setBase(json);
    return coachTimelineItem;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> coachTimelineItemJson = {
      'coach_id': coachId,
      'coach_reference': coachReference,
      'content_reference': contentReference,
      'content_description': contentDescription,
      'content_name': contentName,
      'content_thumbnail': contentThumbnail,
      //'content_type': contentType,
      'content_type': contentType.index,
      'course': course == null ? CourseTimelineSubmodel() : course.toJson(),
    };
    coachTimelineItemJson.addEntries(super.toJson().entries);
    return coachTimelineItemJson;
  }

  @override
  // TODO: implement props
  List<Object> get props => [
        coachId,
        coachReference,
        contentReference,
        contentDescription,
        contentName,
        contentThumbnail,
        contentType,
        course,
        courseForNavigation,
        movementForNavigation,
        mentoredVideosForNavigation,
        sentVideosForNavigation,
        coachMediaMessage,
        id,
        createdBy,
        createdAt,
        updatedAt,
        updatedBy,
        isDeleted,
        isHidden,
      ];
}
