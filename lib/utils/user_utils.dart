import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class UserUtils {
  String defaultAvatarImageAsset = 'assets/utils/avatar.png';
  String defaultAvatarImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/oluko-development.appspot.com/o/avatar.png?alt=media&token=c16925c3-e2be-47fb-9d15-8cd1469d9790';

    CircleAvatar avatarImageDefault({double maxRadius, String name, String lastname}) {
    return CircleAvatar(
      maxRadius: maxRadius ?? 30,
      backgroundColor: name == null || lastname == null
          ? OlukoColors.userColor(null, null)
          : OlukoColors.userColor(name, lastname),
      child: name != null && name.isNotEmpty
          ? Text(
              name.characters?.first?.toString()?.toUpperCase() ?? '',
              style: OlukoFonts.olukoBigFont(
                customColor: OlukoColors.white,
                custoFontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            )
          : const SizedBox(),
    );
  }
}
