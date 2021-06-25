class LoginResponse {
  LoginResponse({this.accessToken});

  String accessToken;

  LoginResponse.fromJson(Map json) : accessToken = json['accessToken'];

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
      };
}
