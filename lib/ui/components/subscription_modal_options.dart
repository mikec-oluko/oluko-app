import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';

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
            title: Text("Change Payment Method",
                style:
                    OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
          ),
          ListTile(
            onTap: () {},
            leading: Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.white,
            ),
            title: Text("Unsubscribe",
                style:
                    OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
          ),
        ],
      ),
    );
  }
}
