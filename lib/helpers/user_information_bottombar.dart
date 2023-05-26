import 'package:characters/src/extensions.dart';
import 'package:flutter/material.dart';

class UserInformationBottomBar {
  String firstName;
  String lastName;
  String avatar;
  UserInformationBottomBar({
    this.avatar,
    this.firstName,
    this.lastName,
  });
  String loadProfileDefaultPicContent() {
    if (firstName != null && firstName.isNotEmpty && lastName != null && lastName.isNotEmpty) {
      return '${firstName.characters.first.toUpperCase()}${lastName.characters.first.toUpperCase()}';
    } else {
      return '';
    }
  }
}
