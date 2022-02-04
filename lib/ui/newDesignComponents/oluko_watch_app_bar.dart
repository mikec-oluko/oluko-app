import 'package:flutter/material.dart';
import 'package:oluko_app/utils/screen_utils.dart';

import 'oluko_neumorphic_back_button.dart';

class OlukoWatchAppBar extends StatefulWidget implements PreferredSizeWidget {
  const OlukoWatchAppBar({this.showBackButton = true, this.onPressed, this.actions});
  final bool showBackButton;
  final Function() onPressed;
  final List<Widget> actions;
  @override
  _OlukoWatchAppBarState createState() => _OlukoWatchAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _OlukoWatchAppBarState extends State<OlukoWatchAppBar> {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Container(
              width: ScreenUtils.width(context),
              height: 80,
              // color: Colors.red,
              child: widget.showBackButton
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OlukoNeumorphicCircleButton(onPressed: widget.onPressed),
                          if (widget.actions != null) ...widget.actions else SizedBox.shrink()
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          )),
    );
  }
}
