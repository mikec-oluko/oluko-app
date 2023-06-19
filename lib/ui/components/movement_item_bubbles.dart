import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/ui/components/stories_item.dart';

class MovementItemBubbles extends StatefulWidget {
  final List<MovementSubmodel> movements;
  final double width;
  final bool showAsGrid;
  final Function(BuildContext, MovementSubmodel) onPressed;
  final bool isSegmentSection;
  MovementItemBubbles({this.movements, this.width, this.onPressed, this.showAsGrid = false, this.isSegmentSection = false});
  @override
  _MovementItemBubblesState createState() => _MovementItemBubblesState();
}

class _MovementItemBubblesState extends State<MovementItemBubbles> {
  //TODO: change this
  String image = 'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/Airsquats.jpg?alt=media&token=641c2dff-ac0e-4b22-8a8d-aee9adbca3a1';
  final int _minMovementsQty = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: !widget.showAsGrid ? 100 : 300,
      width: widget.width,
      child: !widget.showAsGrid ? scrollableBubbles() : buildBubbleGrid(),
    );
  }

  Widget scrollableBubbles() {
    return widget.movements.length > _minMovementsQty
        ? ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.center,
                colors: [Colors.black, Colors.transparent],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: buildBubbles()),
          )
        : SingleChildScrollView(
            physics: widget.movements.length <= _minMovementsQty ? const NeverScrollableScrollPhysics() : const ScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: buildBubbles());
  }

  List<Widget> buildMovementItems() {
    List<Widget> movements = widget.movements
        .map(
          (movement) => movement != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: _imageItem(context, movement.image ?? image, movement.name, onPressed: (context) => widget.onPressed(context, movement)),
                )
              : const SizedBox(),
        )
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
    return GridView.count(padding: EdgeInsets.zero, shrinkWrap: true, mainAxisSpacing: 10, crossAxisCount: 4, children: buildMovementItems());
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
                maxRadius: widget.isSegmentSection ? 30 : 22,
                imageUrl: imageUrl,
                isSegmentSection: widget.isSegmentSection,
              )
            else
              StoriesItem(maxRadius: 23, imageUrl: imageUrl),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
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
