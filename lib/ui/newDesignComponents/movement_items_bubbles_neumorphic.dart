import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/movement_item_image.dart';
import 'package:oluko_app/ui/components/stories_item.dart';

class MovementItemBubblesNeumorphic extends StatefulWidget {
  final List<Movement> content;
  final double width;
  final bool showAsGrid;
  final bool bubbleName;
  final bool viewDetailsScreen;
  final bool referenceMovementsSection;
  final bool replaceView;
  final Movement movement;
  final MovementSubmodel movementSubmodel;
  final Function() onPressed;
  MovementItemBubblesNeumorphic(
      {this.content,
      this.width,
      this.onPressed,
      this.showAsGrid = false,
      this.bubbleName = true,
      this.viewDetailsScreen = false,
      this.replaceView = false,
      this.movement,
      this.movementSubmodel,
      this.referenceMovementsSection = false});
  @override
  _MovementItemBubblesNeumorphicState createState() => _MovementItemBubblesNeumorphicState();
}

class _MovementItemBubblesNeumorphicState extends State<MovementItemBubblesNeumorphic> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: !widget.showAsGrid ? 100 : 400,
      width: widget.width,
      child: !widget.showAsGrid
          ? scrollableBubbles(
              bubbleName: widget.bubbleName, viewDetailsScreen: widget.viewDetailsScreen, referenceMovementsSection: widget.referenceMovementsSection)
          : buildBubbleGrid(bubbleName: widget.bubbleName),
    );
  }

  Widget scrollableBubbles({bool bubbleName = true, bool viewDetailsScreen = false, bool referenceMovementsSection = false}) {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.center,
          colors: [Colors.black, Colors.transparent],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: !viewDetailsScreen
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: buildBubbles(bubbleName: bubbleName, viewDetailsScreen: viewDetailsScreen, referenceMovementsSection: referenceMovementsSection))
          : buildBubbles(bubbleName: bubbleName, viewDetailsScreen: viewDetailsScreen, referenceMovementsSection: referenceMovementsSection),
    );
  }

  List<Widget> buildMovementItems({bool bubbleName = true, bool viewDetailsScreen = false, bool referenceMovementsSection}) {
    if (referenceMovementsSection) {
      final List<Widget> movements = widget.content
          .map(
            (movement) => movement != null
                ? _imageItem(
                    context,
                    movement?.image,
                    movement?.name,
                    onPressed: (context) {
                      if (widget.onPressed != null) widget.onPressed();
                      widget.replaceView
                          ? Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement})
                          : Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movementSubmodel': widget.movementSubmodel});
                    },
                    referenceMovementsSection: referenceMovementsSection,
                  )
                : const SizedBox(),
          )
          .toList();
      if (movements != null && movements.isNotEmpty) {
        movements.add(
          !viewDetailsScreen
              ? SizedBox(
                  width: !widget.showAsGrid ? 180 : 0,
                )
              : const SizedBox(),
        );
      }
      return movements;
    }
    if (!viewDetailsScreen) {
      List<Widget> movements = widget.content
          .map(
            (movement) => movement != null
                ? _imageItem(
                    context,
                    movement?.image,
                    movement?.name,
                    onPressed: (context) {
                      if (widget.onPressed != null) widget.onPressed();
                      widget.replaceView
                          ? Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movementSubmodel': movement})
                          : Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movementSubmodel': widget.movementSubmodel});
                    },
                    bubbleName: bubbleName,
                  )
                : const SizedBox(),
          )
          .toList();
      return movements;
    } else {
      return [
        _imageItem(
          context,
          widget?.movement?.image,
          widget?.movement?.name,
          bubbleName: bubbleName,
          onPressed: (context) {
            if (widget.onPressed != null) widget.onPressed();
            widget.replaceView
                ? Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': widget.movement})
                : Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movementSubmodel': widget.movementSubmodel});
          },
        )
      ];
    }
  }

  Widget buildBubbles({bool bubbleName = true, bool viewDetailsScreen, bool referenceMovementsSection = false}) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildMovementItems(bubbleName: bubbleName, viewDetailsScreen: viewDetailsScreen, referenceMovementsSection: referenceMovementsSection));
  }

  Widget buildBubbleGrid({bool bubbleName}) {
    return GridView.count(physics: OlukoNeumorphism.listViewPhysicsEffect, mainAxisSpacing: 15, crossAxisCount: 4, children: buildMovementItems());
  }

  Widget _imageItem(BuildContext context, String imageUrl, String name,
      {Function(BuildContext) onPressed, bool bubbleName = true, bool referenceMovementsSection = false}) {
    return GestureDetector(
      onTap: () => onPressed(context) ?? () {},
      child: SizedBox(
        width: 85,
        height: 100,
        child: Column(
          children: [
            if (referenceMovementsSection)
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: MovementItem(maxRadius: 35, imageUrl: imageUrl, referenceMovementsSection: referenceMovementsSection),
              )
            else
              bubbleName ?? true
                  ? StoriesItem(maxRadius: 23, imageUrl: imageUrl)
                  : Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: MovementItem(maxRadius: 40, imageUrl: imageUrl),
                    ),
            Visibility(
              visible: bubbleName ?? true,
              child: Padding(
                padding: const EdgeInsets.only(top: 7.0),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
