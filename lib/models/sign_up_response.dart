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

  factory SignUpResponse.fromJson(dynamic json) {
    return SignUpResponse(
      id: json['id'].toString(),
      firstName: json['first_name'].toString(),
      lastName: json['last_name'].toString(),
      email: json['email'].toString(),
      firebaseId: json['firebase_id'].toString(),
      hubspotCompanyId: num.tryParse(json['hubspot_company_id'].toString()),
      hubspotContactId: num.tryParse(json['hubspot_contact_id'].toString()),
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
