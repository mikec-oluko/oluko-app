import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/ui/components/stories_item.dart';

class MovementItemBubbles extends StatefulWidget {
  final List<Movement> content;
  final double width;
  final Function(BuildContext, Movement) onPressed;
  MovementItemBubbles({this.content, this.width, this.onPressed});
  @override
  _MovementItemBubblesState createState() => _MovementItemBubblesState();
}

class _MovementItemBubblesState extends State<MovementItemBubbles> {

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.content
                        .map((movement) => _imageItem(
                            context, movement.iconImage, movement.name,
                            onPressed: (context) =>
                                widget.onPressed(context, movement)))
                        .toList()
                          //Prevent the last item to be overlayed by the carousel gradient
                          ..add(SizedBox(
                            width: 180,
                          )))),
          ],
        ),
      ),
    );
  }

  Widget _imageItem(BuildContext context, String imageUrl, String name,
      {Function(BuildContext) onPressed}) {
    return GestureDetector(
      onTap: () => onPressed(context),
      child: Container(
        width: 75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StoriesItem(maxRadius: 25, imageUrl: imageUrl),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: OlukoFonts.olukoMediumFont(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
