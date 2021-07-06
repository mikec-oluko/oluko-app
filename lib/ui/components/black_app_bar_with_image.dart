import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/title_header.dart';

class OlukoImageBar<T> extends StatelessWidget implements PreferredSizeWidget {
  final Function() onPressed;
  final String title;
  final List<Widget> actions;

  OlukoImageBar({this.title, this.onPressed, this.actions});
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 35,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: actions,
          flexibleSpace: Align(
            alignment: Alignment.centerLeft,
            child: StoriesItem(
                name: "Airsquats",
                imageUrl:
                    "https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/Airsquats.jpg?alt=media&token=641c2dff-ac0e-4b22-8a8d-aee9adbca3a1"),
          )),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
