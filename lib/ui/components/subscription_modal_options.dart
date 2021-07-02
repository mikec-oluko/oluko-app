import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
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
        shrinkWrap: true,
        children: [
          ListTile(
            onTap: () {},
            leading: Icon(
              Icons.credit_card,
              color: Colors.white,
            ),
            title: Text(ProfileViewConstants.profileChangePaymentMethodTitle,
                style:
                    OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
          ),
          ListTile(
            onTap: () {},
            leading: Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.white,
            ),
            title: Text(ProfileViewConstants.profileUnsuscribeTitle,
                style:
                    OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
          ),
        ],
      ),
    );
  }
}
