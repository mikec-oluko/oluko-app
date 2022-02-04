import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/ui/components/stories_item.dart';

class MovementItemBubbles extends StatefulWidget {
  final List<Movement> content;
  final double width;
  final bool showAsGrid;
  final Function(BuildContext, Movement) onPressed;
  final bool isSegmentSection;
  MovementItemBubbles({this.content, this.width, this.onPressed, this.showAsGrid = false, this.isSegmentSection = false});
  @override
  _MovementItemBubblesState createState() => _MovementItemBubblesState();
}

class _MovementItemBubblesState extends State<MovementItemBubbles> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: !widget.showAsGrid ? 100 : 300,
      width: widget.width,
      child: !widget.showAsGrid ? scrollableBubbles() : buildBubbleGrid(),
    );
  }

  Widget scrollableBubbles() {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.center,
          colors: [Colors.black, Colors.transparent],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: buildBubbles()),
    );
  }

  List<Widget> buildMovementItems() {
    List<Widget> movements = widget.content
        .map((movement) => _imageItem(context, movement.image, movement.name, onPressed: (context) => widget.onPressed(context, movement)))
        .toList();
    if (movements != null && movements.isNotEmpty) {
      movements.add(
        SizedBox(
          width: !widget.showAsGrid ? 180 : 0,
        ),
      );
    }
    return movements;
  }

  Widget buildBubbles() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: buildMovementItems(),
    );
  }

  Widget buildBubbleGrid() {
    return GridView.count(mainAxisSpacing: 15, crossAxisCount: 4, children: buildMovementItems());
  }

  Widget _imageItem(BuildContext context, String imageUrl, String name, {Function(BuildContext) onPressed}) {
    return GestureDetector(
      onTap: () => onPressed(context),
      child: SizedBox(
        width: 85,
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (OlukoNeumorphism.isNeumorphismDesign)
              StoriesItem(
                maxRadius: widget.isSegmentSection ? 30 : 23,
                imageUrl: imageUrl,
                bloc: StoryListBloc(),
                isSegmentSection: widget.isSegmentSection,
              )
            else
              StoriesItem(maxRadius: 23, imageUrl: imageUrl, bloc: StoryListBloc()),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                name ?? '',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
