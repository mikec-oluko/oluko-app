import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'submodels/course_timeline_submodel.dart';

class CoachTimelineItem extends Base with EquatableMixin {
  String coachId;
  DocumentReference coachReference;
  String contentDescription;
  String contentName;
  String contentThumbnail;
  num contentType;
  CourseTimelineSubmodel course;
  Movement movementForNavigation;
  Course courseForNavigation;
  List<Annotation> mentoredVideosForNavigation;
  List<SegmentSubmission> sentVideosForNavigation;

  CoachTimelineItem(
      {this.coachId,
      this.coachReference,
      this.contentDescription,
      this.contentName,
      this.contentThumbnail,
      this.contentType,
      this.course,
      this.courseForNavigation,
      this.movementForNavigation,
      this.mentoredVideosForNavigation,
      this.sentVideosForNavigation,
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
      coachReference: json['coach_reference'] as DocumentReference,
      contentDescription: json['content_description'].toString(),
      contentName: json['content_name'] != null ? json['content_name'].toString() : null,
      contentThumbnail: json['content_thumbnail'] != null ? json['content_thumbnail'].toString() : null,
      contentType: json['content_type'] as num,
      course: json['course'] == null
          ? CourseTimelineSubmodel()
          : CourseTimelineSubmodel.fromJson(json['course'] as Map<String, dynamic>),
    );
    coachTimelineItem.setBase(json);
    return coachTimelineItem;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> coachTimelineItemJson = {
      'coach_id': coachId,
      'coach_reference': coachReference,
      'content_description': contentDescription,
      'content_name': contentName,
      'content_thumbnail': contentThumbnail,
      'content_type': contentType,
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
        contentDescription,
        contentName,
        contentThumbnail,
        contentType,
        course,
        courseForNavigation,
        movementForNavigation,
        mentoredVideosForNavigation,
        sentVideosForNavigation,
        id,
        createdBy,
        createdAt,
        updatedAt,
        updatedBy,
        isDeleted,
        isHidden,
      ];
}
