import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserUtils {
  String defaultAvatarImageAsset = 'assets/utils/avatar.png';
  String defaultAvatarImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/oluko-development.appspot.com/o/avatar.png?alt=media&token=c16925c3-e2be-47fb-9d15-8cd1469d9790';

  static CircleAvatar avatarImageDefault({double maxRadius, String name, String lastname}) {
    return CircleAvatar(
      maxRadius: maxRadius ?? 30,
      backgroundColor: name == null || lastname == null || name == 'null' || lastname == 'null'
          ? OlukoColors.userColor(null, null)
          : OlukoColors.userColor(name, lastname),
      child: name != null && name.isNotEmpty
          ? Text(
              getAvatarText(name, lastname),
              style: OlukoFonts.olukoBigFont(
                customColor: OlukoColors.white,
                custoFontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            )
          : Image.asset(
              'assets/home/mvt.png',
              scale: 3,
            ),
    );
  }

  static String getAvatarText(String name, String lastname) {
    String text = '';
    if (name != null && name != 'null' && name.isNotEmpty) {
      text += name.characters?.first?.toString()?.toUpperCase();
    }
    if (lastname != null && lastname != 'null' && lastname.isNotEmpty) {
      text += lastname.characters?.first?.toString()?.toUpperCase();
    }
    return text;
  }

  static Future<bool> isFirstTime() async {
    final sharedPref = await SharedPreferences.getInstance();
    final isFirstTime = sharedPref.getBool('first_time');
    if (isFirstTime != null && !isFirstTime) {
      return false;
    } else {
      sharedPref.setBool('first_time', false);
      return true;
    }
  }
}
