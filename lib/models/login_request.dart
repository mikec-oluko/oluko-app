class LoginRequest {
  LoginRequest({this.email, this.password, this.projectId});

  String email;
  String password;
  String projectId;

  LoginRequest.fromJson(Map json)
      : email = json['email'],
        password = json['password'],
        projectId = json['projectId'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'projectId': projectId,
      };
}
