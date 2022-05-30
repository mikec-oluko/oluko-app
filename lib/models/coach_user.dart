import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/utils/json_utils.dart';

class CoachUser extends UserResponse {
  String bannerVideo;
  CoachUser(
      {this.bannerVideo,
      String id,
      Timestamp createdAt,
      Timestamp updatedAt,
      Timestamp assessmentsCompletedAt,
      String createdBy,
      String updatedBy,
      String firstName,
      String lastName,
      String email,
      String username,
      String firebaseId,
      String avatar,
      String avatarThumbnail,
      String coverImage,
      String city,
      String state,
      String country,
      bool isHidden,
      bool isDeleted,
      bool showRecordingAlert,
      bool notification,
      int privacy,
      num hubspotCompanyId,
      num hubspotContactId,
      double currentPlan})
      : super(
          id: id,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
          assessmentsCompletedAt: assessmentsCompletedAt,
          updatedBy: updatedBy,
          firstName: firstName,
          lastName: lastName,
          email: email,
          username: username,
          firebaseId: firebaseId,
          avatar: avatar,
          avatarThumbnail: avatarThumbnail,
          coverImage: coverImage,
          city: city,
          state: state,
          country: country,
          isHidden: isHidden,
          isDeleted: isDeleted,
          showRecordingAlert: showRecordingAlert,
          notification: notification,
          privacy: privacy,
          hubspotCompanyId: hubspotCompanyId,
          hubspotContactId: hubspotContactId,
          currentPlan: currentPlan,
        );

  factory CoachUser.fromJson(Map<String, dynamic> json) {
    CoachUser coachResponse = CoachUser(
      bannerVideo: json['banner_video']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      username: json['username']?.toString(),
      avatar: json['avatar']?.toString(),
      avatarThumbnail: json['avatar_thumbnail']?.toString(),
      coverImage: json['cover_image']?.toString(),
      city: json['city'] == null ? null : json['city']?.toString(),
      state: json['state'] != null ? json['state']?.toString() : null,
      country: json['country'] != null ? json['country']?.toString() : null,
      firebaseId: json['firebase_id']?.toString(),
      hubspotCompanyId: json['hubspot_company_id'] is num ? json['hubspot_company_id'] as num : null,
      hubspotContactId: json['hubspot_contact_id'] is num ? json['hubspot_contact_id'] as num : null,
      notification: json['notification'] == null ? true : json['notification'] as bool,
      showRecordingAlert: json['show_recording_alert'] == null ? true : json['show_recording_alert'] as bool,
      privacy: json['privacy'] == null ? 0 : json['privacy'] as int,
      currentPlan: json['current_plan'] == null ? -100 : double.tryParse((json['current_plan'] as num)?.toString()),
      assessmentsCompletedAt: getTimestamp(json['assessments_completed_at']),
    );

    coachResponse.setBase(json);
    return coachResponse;
  }

  setBase(Map<String, dynamic> json) {
    super.setBase(json);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> coachResponseJson = {
      'banner_video': bannerVideo,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'username': username,
      'avatar': avatar,
      'avatar_thumbnail': avatarThumbnail,
      'cover_image': coverImage,
      'city': city,
      'state': state,
      'country': country,
      'firebase_id': firebaseId,
      'hubspot_company_id': hubspotCompanyId,
      'hubspot_contact_id': hubspotContactId,
      'notification': notification == null ? true : notification,
      'show_recording_alert': showRecordingAlert == null ? true : showRecordingAlert,
      'privacy': privacy == null ? 0 : privacy,
      'current_plan': currentPlan,
      'assessments_completed_at': assessmentsCompletedAt
    };
    coachResponseJson.addEntries(super.toJson().entries);
    return coachResponseJson;
  }
}
