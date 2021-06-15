import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/ui/components/title_header.dart';

class OlukoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function() onPressed;
  final String title;

  OlukoAppBar({this.title, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          size: 35,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: TitleHeader(
        title,
        bold: true,
      ),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
