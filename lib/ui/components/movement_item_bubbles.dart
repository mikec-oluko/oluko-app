import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/screens/movement_intro.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class MovementItemBubbles extends StatefulWidget {
  final List<Movement> content;
  final double width;
  MovementItemBubbles({this.content, this.width});
  @override
  _MovementItemBubblesState createState() => _MovementItemBubblesState();
}

class _MovementItemBubblesState extends State<MovementItemBubbles> {
  //TODO Make Dynamic
  final String imageItemUrl =
      "https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/Airsquats.jpg?alt=media&token=641c2dff-ac0e-4b22-8a8d-aee9adbca3a1";
  final String itemName = 'Airsquats';
  final Function(BuildContext) onPressedMovement = (context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MovementIntro()));
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      width: widget.width,
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.center,
            end: Alignment.centerRight,
            colors: [Colors.black, Colors.transparent],
          ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
        },
        blendMode: BlendMode.dstIn,
        child: Stack(
          children: [
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: widget.content
                        .map((movement) => _imageItem(
                            context, movement.iconImage, movement.name,
                            onPressed: onPressedMovement))
                        .toList())),
          ],
        ),
      ),
    );
  }

  Widget _imageItem(BuildContext context, String imageUrl, String name,
      {Function(BuildContext) onPressed}) {
    return GestureDetector(
      onTap: () => onPressed(context),
      child: Column(
        children: [
          StoriesItem(maxRadius: 25, imageUrl: imageUrl),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: OlukoFonts.olukoMediumFont(),
            ),
          )
        ],
      ),
    );
  }
}
