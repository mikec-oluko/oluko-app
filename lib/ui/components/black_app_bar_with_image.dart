import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
            child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.black,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.network(
                      "https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/airsquats-icon.ico?alt=media&token=3dd95779-2e94-4d2f-a255-8f559b1c7fa5"),
                )),
          )),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
