class SignUpRequest {
  SignUpRequest(
      {this.email, this.password, this.firstName, this.lastName, this.projectId, this.username, this.country, this.state, this.city, this.newsletter});

  String email;
  String password;
  String firstName;
  String lastName;
  String projectId;
  String username;
  String country;
  String state;
  String city;
  int zipCode;
  bool newsletter;

  SignUpRequest.fromJson(Map json)
      : email = json['email']?.toString(),
        password = json['password']?.toString(),
        firstName = json['first_name']?.toString(),
        lastName = json['last_name']?.toString(),
        projectId = json['projectid']?.toString(),
        username = json['username']?.toString(),
        country = json['country'] == null ? '' : json['country']?.toString(),
        state = json['state'] == null ? '' : json['state']?.toString(),
        city = json['city'] == null ? '' : json['city']?.toString(),
        zipCode = json['zip_code'] as int,
        newsletter = json['newsletter'] == null || json['newsletter'] is! bool ? false : json['newsletter'] as bool;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'projectId': projectId,
        'username': username,
        'country': country == null ? '' : country.toString(),
        'state': state == null ? '' : state.toString(),
        'city': city == null ? '' : city.toString(),
        'zipCode': zipCode,
        'newsletter': newsletter
      };

  Map<String, dynamic> toDTOJson() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'projectId': projectId,
        'username': username,
        'country': country ?? '',
        'state': state ?? '',
        'city': city ?? '',
        'zipCode': zipCode,
        'newsletter': newsletter
      };
}
