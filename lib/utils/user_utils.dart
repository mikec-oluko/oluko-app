import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class UserUtils {
  String defaultAvatarImageAsset = 'assets/utils/avatar.png';
  String defaultAvatarImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/oluko-development.appspot.com/o/avatar.png?alt=media&token=c16925c3-e2be-47fb-9d15-8cd1469d9790';

  static CircleAvatar avatarImageDefault({double maxRadius, String name, String lastname, Color circleColor}) {
    return CircleAvatar(
      maxRadius: maxRadius ?? 30,
      backgroundColor: circleColor != null
          ? circleColor
          : name == null || lastname == null || name == 'null' || lastname == 'null'
              ? OlukoColors.userColor(null, null)
              : OlukoColors.userColor(name, lastname),
      child: name != null && name.isNotEmpty
          ? Text(
              getAvatarText(name, lastname),
              style: OlukoFonts.olukoBigFont(
                customColor: OlukoColors.white,
                customFontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            )
          : Image.asset(
              OlukoNeumorphism.mvtLogo,
              scale: 3,
            ),
    );
  }

  static String getAvatarText(String name, String lastname) {
    String text = '';
    if (name != null && name != 'null' && name.isNotEmpty) {
      text += name.characters?.first?.toUpperCase();
    }
    if (lastname != null && lastname != 'null' && lastname.isNotEmpty) {
      text += lastname.characters?.first?.toUpperCase();
    }
    return text;
  }

  static Future<bool> isFirstTime() async {
    final sharedPref = await SharedPreferences.getInstance();
    final isFirstTime = sharedPref.getBool('first_time');
    return isFirstTime == null || isFirstTime == true;
  }

  static Future<bool> checkFirstTimeAndUpdate() async {
    final sharedPref = await SharedPreferences.getInstance();
    final isFirstTime = sharedPref.getBool('first_time');
    if (isFirstTime != null && !isFirstTime) {
      return false;
    }
    sharedPref.setBool('first_time', false);
    return true;
  }

  static bool userDeviceIsIOS() => Platform.isIOS;
  static bool userDeviceIsAndrioid() => Platform.isAndroid;
}
