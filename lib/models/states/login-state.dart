import 'package:oluko_app/models/user-response.dart';

class LoginState {
  LoginState({this.user, this.error, this.errorMessages});

  UserResponse user;
  String error;
  List<dynamic> errorMessages;

  LoginState.fromJson(Map json)
      : user = json['user'],
        error = json['error'],
        errorMessages = json['errorMessages'];

  Map<String, dynamic> toJson() =>
      {'user': user, 'error': error, 'errorMessages': errorMessages};
}
