class SignUpRequest {
  SignUpRequest(
      {this.email,
      this.password,
      this.firstName,
      this.lastName,
      this.projectId,
      this.username});

  String email;
  String password;
  String firstName;
  String lastName;
  String projectId;
  String username;

  SignUpRequest.fromJson(Map json)
      : email = json['email'],
        password = json['password'],
        firstName = json['first_name'],
        lastName = json['last_name'],
        projectId = json['projectId'],
        username = json['username'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'projectId': projectId,
        'username': username
      };

  Map<String, dynamic> toDTOJson() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'projectId': projectId,
        'username': username
      };
}
