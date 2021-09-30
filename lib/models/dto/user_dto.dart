import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/user_response.dart';

class UserDto {
  UserDto.fromUserResponse(UserResponse userReponse) {
    createdAt = userReponse.createdAt?.millisecondsSinceEpoch;
    updatedAt = userReponse.updatedAt?.millisecondsSinceEpoch;
    firstName = userReponse.firstName;
    lastName = userReponse.lastName;
    email = userReponse.email;
    username = userReponse.username;
    firebaseId = userReponse.firebaseId;
    hubspotCompanyId = userReponse.hubspotCompanyId;
    hubspotContactId = userReponse.hubspotContactId;
    privacy = userReponse.privacy;
    notification = userReponse.notification;
    avatar = userReponse.avatar;
    avatarThumbnail = userReponse.avatarThumbnail;
    coverImage = userReponse.coverImage;
    city = userReponse.city;
    state = userReponse.state;
    country = userReponse.country;
    currentPlan = userReponse.currentPlan;
    id = userReponse.id;
    createdBy = userReponse.createdBy;
    updatedBy = userReponse.updatedBy;
    isHidden = userReponse.isHidden;
    isDeleted = userReponse.isDeleted;
  }

  UserDto({
    this.firstName,
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
    this.id,
    Timestamp createdAt,
    this.createdBy,
    Timestamp updatedAt,
    this.updatedBy,
    this.isHidden,
    this.isDeleted,
  }) {
    this.createdAt = createdAt?.millisecondsSinceEpoch;
    this.updatedAt = updatedAt?.millisecondsSinceEpoch;
  }

  String firstName, lastName, email, username, firebaseId, avatar, avatarThumbnail, coverImage, city, state, country;
  double currentPlan;
  num hubspotCompanyId;
  num hubspotContactId;
  int privacy;
  bool notification;
  String id;
  int createdAt;
  String createdBy;
  int updatedAt;
  String updatedBy;
  bool isDeleted = false;
  bool isHidden = false;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    UserDto userDto = UserDto(
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      username: json['username']?.toString(),
      avatar: json['avatar']?.toString(),
      avatarThumbnail: json['avatar_thumbnail']?.toString(),
      coverImage: json['cover_image']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      firebaseId: json['firebase_id']?.toString(),
      hubspotCompanyId: json['hubspot_company_id'] as num,
      hubspotContactId: json['hubspot_contact_id'] as num,
      notification: json['notification'] == null ? true : json['notification'] as bool,
      privacy: json['privacy'] == null ? 0 : json['privacy'] as int,
      currentPlan: json['current_plan'] == null ? 0 : double.tryParse((json['current_plan'] as num)?.toString()),
      id: json['id']?.toString(),
      createdAt: json['created_at'] as Timestamp,
      createdBy: json['created_by']?.toString(),
      updatedAt: json['updated_at'] as Timestamp,
      updatedBy: json['updated_by']?.toString(),
      isDeleted: json['is_deleted'] as bool,
      isHidden: json['is_hidden'] as bool,
    );
    return userDto;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> userDtoJson = {
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
      'notification': notification ?? true,
      'privacy': privacy ?? 0,
      'current_plan': currentPlan,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'created_by': createdBy,
      'id': id,
      'is_deleted': isDeleted,
      'is_hidden': isHidden,
    };
    return userDtoJson;
  }
}
