import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/basic_tiles.dart';
import 'package:oluko_app/ui/components/child_tile.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';

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
        child: Text(title, style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor)),
      );
    }

    return OlukoNeumorphism.isNeumorphismDesign
        ? Container(
            decoration: BoxDecoration(
              color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            ),
            child: Column(
              children: [
                newParentTile(expanded, title, tiles),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OlukoNeumorphicDivider(),
                )
              ],
            ),
          )
        : Container(
            decoration: BoxDecoration(
                color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
                border:
                    OlukoNeumorphism.isNeumorphismDesign ? Border() : Border(bottom: BorderSide(width: 1.0, color: OlukoColors.grayColor))),
            child: newParentTile(expanded, title, tiles),
          );
  }

  ExpansionTile newParentTile(bool expanded, String title, List<BasicTile> tiles) {
    return ExpansionTile(
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
        title: Text(title, style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor)),
        children: tiles
            .map((tile) => Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: ChildTileWidget(tile: tile),
                ))
            .toList());
  }
}
