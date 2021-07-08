import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/child_tile.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ParentTileWidget extends StatefulWidget {
  final BasicTile tile;
  const ParentTileWidget({this.tile});

  @override
  _ParentTileWidgetState createState() => _ParentTileWidgetState();
}

class _ParentTileWidgetState extends State<ParentTileWidget> {
  var iconToUse = Icon(
    Icons.keyboard_arrow_right,
    color: OlukoColors.grayColor,
  );

  @override
  Widget build(BuildContext context) {
    final expanded = widget.tile.isExpanded;
    final title = widget.tile.title;
    final tiles = widget.tile.tiles;

    if (tiles.isEmpty) {
      return Container(
        color: OlukoColors.primary,
        child: Text(title,
            style:
                OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor)),
      );
    }

    return Container(
      decoration: BoxDecoration(
          color: OlukoColors.black,
          border: Border(
              bottom: BorderSide(width: 1.0, color: OlukoColors.grayColor))),
      child: ExpansionTile(
          initiallyExpanded: expanded,
          onExpansionChanged: (bool value) {
            setState(() {
              if (value) {
                widget.tile.isExpanded = value;
                iconToUse = Icon(
                  Icons.keyboard_arrow_up,
                  color: OlukoColors.grayColor,
                );
              } else {
                widget.tile.isExpanded = value;
                iconToUse = Icon(
                  Icons.keyboard_arrow_right,
                  color: OlukoColors.grayColor,
                );
              }
            });
          },
          trailing: iconToUse,
          title: Text(title,
              style: OlukoFonts.olukoMediumFont(
                  customColor: OlukoColors.grayColor)),
          children: tiles
              .map((tile) => Padding(
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: ChildTileWidget(tile: tile),
                  ))
              .toList()),
    );
  }
}
