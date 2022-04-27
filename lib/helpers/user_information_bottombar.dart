import 'package:cached_network_image/cached_network_image.dart';
import 'package:characters/src/extensions.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

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
    if (firstName != null && lastName != null) {
      return '${firstName.characters.first.toUpperCase()}${lastName.characters.first.toUpperCase()}';
    } else {
      return '';
    }
  }
}
