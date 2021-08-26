class LoginRequest {
  LoginRequest({this.email, this.password, this.projectId, this.userName});

  String email;
  String userName;
  String password;
  String projectId;

  LoginRequest.fromJson(Map json)
      : email = json['email'],
        password = json['password'],
        projectId = json['projectId'],
        userName = json['userName'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'projectId': projectId,
        'username': userName
      };
}
