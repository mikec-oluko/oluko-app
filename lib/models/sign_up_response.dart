class SignUpResponse {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String firebaseId;
  final num hubspotCompanyId;
  final num hubspotContactId;

  SignUpResponse({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.firebaseId,
    this.hubspotCompanyId,
    this.hubspotContactId,
  });

  factory SignUpResponse.fromJson(Map json) {
    return SignUpResponse(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      firebaseId: json['firebase_id'],
      hubspotCompanyId: json['hubspot_company_id'],
      hubspotContactId: json['hubspot_contact_id'],
    );
  }

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
