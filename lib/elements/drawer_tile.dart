import 'package:flutter/material.dart';

import 'package:oluko_app/constants/theme.dart';

class DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function() tap;
  final bool isSelected;
  final Color iconColor;

  DrawerTile(
      {this.title,
      this.icon,
      this.tap,
      this.isSelected = false,
      this.iconColor = OlukoColors.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tap,
      child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isSelected ? OlukoColors.primary : OlukoColors.white,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Row(
            children: [
              Icon(icon,
                  size: 20, color: isSelected ? OlukoColors.white : iconColor),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(title,
                    style: TextStyle(
                        letterSpacing: .3,
                        fontSize: 15,
                        color: isSelected
                            ? OlukoColors.white
                            : Color.fromRGBO(0, 0, 0, 0.7))),
              )
            ],
          )),
    );
  }
}
