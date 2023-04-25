import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/utils/json_utils.dart';
import 'base.dart';

class UserResponse extends Base {
  UserResponse(
      {this.firstName,
      this.lastName,
      this.email,
      this.username,
      this.firebaseId,
      this.hubspotCompanyId,
      this.hubspotContactId,
      this.privacy,
      this.notification,
      this.avatar,
      this.avatarThumbnail,
      this.coverImage,
      this.city,
      this.state,
      this.country,
      this.currentPlan,
      this.assessmentsCompletedAt,
      this.showRecordingAlert,
      this.firstLoginAt,
      this.firstAppInteractionAt,
      this.lastAppOpeningAt,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  String firstName, lastName, email, username, firebaseId, avatar, avatarThumbnail, coverImage, city, state, country;
  double currentPlan;
  num hubspotCompanyId;
  num hubspotContactId;
  int privacy;
  bool notification;
  bool showRecordingAlert;
  Timestamp assessmentsCompletedAt;
  Timestamp firstLoginAt;
  Timestamp firstAppInteractionAt;
  Timestamp lastAppOpeningAt;

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    try {
      UserResponse userResponse = UserResponse(
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
        currentPlan: json['current_plan'] == null ? -1 : double.tryParse((json['current_plan'] as num)?.toString()),
        assessmentsCompletedAt: getTimestamp(json['assessments_completed_at']),
        firstLoginAt: getTimestamp(json['first_login_at']),
        firstAppInteractionAt: getTimestamp(json['first_app_interaction_at']),
        lastAppOpeningAt: getTimestamp(json['last_app_opening_at']),
      );
      // Timestamp.fromMillisecondsSinceEpoch(json['assessments_completed_at'] as int)
      userResponse.setBase(json);
      return userResponse;
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      rethrow;
    }
  }

  setBase(Map<String, dynamic> json) {
    super.setBase(json);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> userReponseJson = {
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
      'assessments_completed_at': assessmentsCompletedAt,
      'first_login_at': firstLoginAt,
      'first_app_interaction_at': firstAppInteractionAt,
      'last_app_opening_at': lastAppOpeningAt
    };
    userReponseJson.addEntries(super.toJson().entries);
    return userReponseJson;
  }

  String getAvatarThumbnail() {
    return avatarThumbnail ?? avatar;
  }

  String getFullName({bool showFullName = false}) {
    if (firstName != null && lastName != null) {
      return showFullName ? '${getSingleName() ?? ''} ${lastName ?? ''}' : '${getSingleName()} ${lastName[0].toUpperCase()}.';
    }
    return username;
  }

  String getSingleName() {
    String singleName = '';
    if (firstName != null && firstName.isNotEmpty) {
      singleName = firstName.split(' ')[0];
    }
    return singleName;
  }
}
