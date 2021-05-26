class LoginRequest {
  LoginRequest({this.email, this.password});

  String email;
  String password;

  LoginRequest.fromJson(Map json)
      : email = json['email'],
        password = json['password'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
