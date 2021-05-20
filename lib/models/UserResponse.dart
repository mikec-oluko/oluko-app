class UserResponse {
  UserResponse();

  String id;
  String firstName;
  String lastName;
  String email;
  String firebaseId;
  num hubspotCompanyId;
  num hubspotContactId;

  UserResponse.fromJson(Map json)
      : id = json['id'],
        firstName = json['first_name'],
        lastName = json['last_name'],
        email = json['email'],
        firebaseId = json['firebase_id'],
        hubspotCompanyId = json['hubspot_company_id'],
        hubspotContactId = json['hubspot_contact_id'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'firebase_id': firebaseId,
        'hubspot_company_id': hubspotCompanyId,
        'hubspot_contact_id': hubspotContactId,
      };
}
