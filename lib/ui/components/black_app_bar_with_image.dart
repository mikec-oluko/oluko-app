import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/title_header.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class OlukoImageBar<T> extends StatelessWidget implements PreferredSizeWidget {
  final Function() onPressed;
  final String title;
  final List<Widget> actions;
  final double toolbarHeight;
  final String imageItemUrl =
      "https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/Airsquats.jpg?alt=media&token=641c2dff-ac0e-4b22-8a8d-aee9adbca3a1";
  final String itemName = 'Airsquats';

  OlukoImageBar(
      {this.title,
      this.onPressed,
      this.actions,
      this.toolbarHeight = kToolbarHeight * 1.75});
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(toolbarHeight),
      child: AppBar(
          toolbarHeight: toolbarHeight,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          actions: actions,
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          size: 35,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(),
                    width: ScreenUtils.width(context) / 1.8,
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.centerRight,
                          colors: [Colors.black, Colors.transparent],
                        ).createShader(
                            Rect.fromLTRB(0, 0, rect.width, rect.height));
                      },
                      blendMode: BlendMode.dstIn,
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: <Widget>[
                                _imageItem(imageItemUrl, itemName),
                              ])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 25,
                        ),
                        onPressed: () =>
                            {/* TODO Implement 'More' action functionality */}),
                  )
                ],
              )
            ],
          )),
    );
  }

  Widget _imageItem(String imageUrl, String name) {
    return Column(
      children: [
        StoriesItem(maxRadius: 25, imageUrl: imageItemUrl),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            name,
            style: OlukoFonts.olukoMediumFont(),
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(toolbarHeight);
}
