import 'package:cloud_firestore/cloud_firestore.dart';

import 'base.dart';

class UserResponse extends Base {
  UserResponse(
      {this.firstName,
      this.lastName,
      this.email,
      this.firebaseId,
      this.hubspotCompanyId,
      this.hubspotContactId,
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
  String firstName;
  String lastName;
  String email;
  String firebaseId;
  num hubspotCompanyId;
  num hubspotContactId;

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    UserResponse userResponse = UserResponse(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      firebaseId: json['firebase_id'],
      hubspotCompanyId: json['hubspot_company_id'],
      hubspotContactId: json['hubspot_contact_id'],
    );
    userResponse.setBase(json);
    return userResponse;
  }

  setBase(Map<String, dynamic> json) {
    super.setBase(json);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> userReponseJson = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'firebase_id': firebaseId,
      'hubspot_company_id': hubspotCompanyId,
      'hubspot_contact_id': hubspotContactId,
    };
    userReponseJson.addEntries(super.toJson().entries);
    return userReponseJson;
  }
}
