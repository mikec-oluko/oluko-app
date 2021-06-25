class SignUpRequest {
  SignUpRequest(
      {this.id,
      this.email,
      this.password,
      this.firstName,
      this.lastName,
      this.projectId,
      this.username});

  String id;
  String email;
  String password;
  String firstName;
  String lastName;
  String projectId;
  String username;

  SignUpRequest.fromJson(Map json)
      : id = json['id'],
        email = json['email'],
        password = json['password'],
        firstName = json['first_name'],
        lastName = json['last_name'],
        projectId = json['projectId'],
        username = json['username'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'projectId': projectId,
        'username': username
      };
}
