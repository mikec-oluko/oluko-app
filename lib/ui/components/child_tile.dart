import 'package:flutter/material.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/ui/screens/profile/profile_constants.dart';

class ChildTileWidget extends StatefulWidget {
  final BasicTile tile;
  const ChildTileWidget({this.tile});

  @override
  _ChildTileWidgetState createState() => _ChildTileWidgetState();
}

class _ChildTileWidgetState extends State<ChildTileWidget> {
  var iconToUse = Icon(
    Icons.keyboard_arrow_right,
    color: OlukoColors.grayColor,
  );

  @override
  Widget build(BuildContext context) {
    final displayText = widget.tile.title;
    final tiles = widget.tile.tiles;
    if (tiles.isEmpty) {
      return Container(
        decoration: BoxDecoration(
            color: OlukoColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(displayText,
              style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.black)),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
          color: OlukoColors.listGrayColor,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: ExpansionTile(
          initiallyExpanded: widget.tile.isExpanded,
          backgroundColor: OlukoColors.listGrayColor,
          onExpansionChanged: (bool value) {
            setState(() {
              if (value) {
                iconToUse = Icon(
                  Icons.keyboard_arrow_up,
                  color: OlukoColors.grayColor,
                );
              } else {
                iconToUse = Icon(
                  Icons.keyboard_arrow_right,
                  color: OlukoColors.grayColor,
                );
              }
            });
          },
          trailing: iconToUse,
          title: Text(displayText,
              style: OlukoFonts.olukoMediumFont(
                  customColor: OlukoColors.grayColor)),
          children: tiles.map((tile) => ChildTileWidget(tile: tile)).toList()),
    );
  }
}
