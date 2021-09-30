class LoginResponse {
  LoginResponse({this.accessToken});

  String accessToken;

  LoginResponse.fromJson(Map json) : accessToken = json['accessToken']?.toString();

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
      };
}
