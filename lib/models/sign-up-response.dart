class SignUpResponse {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String firebaseId;
  final num hubspotCompanyId;
  final num hubspotContactId;

  SignUpResponse.fromJson(Map json)
      : id = json['id'],
        firstName = json['first_name'],
        lastName = json['last_name'],
        email = json['email'],
        firebaseId = json['firebase_id'],
        hubspotCompanyId = json['hubspot_company_id'],
        hubspotContactId = json['hubspot_contact_id'];
}
