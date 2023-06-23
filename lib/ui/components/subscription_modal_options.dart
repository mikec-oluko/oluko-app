import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class SubscriptionModalOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return returnList(context);
  }

  Container returnList(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView(
        physics: OlukoNeumorphism.listViewPhysicsEffect,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        shrinkWrap: true,
        children: [
          ListTile(
            onTap: () {},
            leading: Icon(
              Icons.credit_card,
              color: Colors.white,
            ),
            title: Text(ProfileViewConstants.profileChangePaymentMethodTitle, style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
          ),
          ListTile(
            onTap: () {},
            leading: Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.white,
            ),
            title: Text(ProfileViewConstants.profileUnsuscribeTitle, style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
          ),
        ],
      ),
    );
  }
}
