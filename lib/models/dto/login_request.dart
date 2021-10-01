class LoginRequest {
  LoginRequest({this.email, this.password, this.projectId, this.userName});

  String email;
  String userName;
  String password;
  String projectId;

  LoginRequest.fromJson(Map json)
      : email = json['email']?.toString(),
        password = json['password']?.toString(),
        projectId = json['projectId']?.toString(),
        userName = json['userName']?.toString();

  Map<String, dynamic> toJson() => {'email': email, 'password': password, 'projectId': projectId, 'username': userName};
}
