class SignUpRequest {
  SignUpRequest(
      {this.email,
      this.password,
      this.firstName,
      this.lastName,
      this.username});

  String email;
  String password;
  String firstName;
  String lastName;
  String username;

  SignUpRequest.fromJson(Map json)
      : email = json['email'],
        password = json['password'],
        firstName = json['first_name'],
        lastName = json['last_name'],
        username = json['username'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'username': username
      };
}
