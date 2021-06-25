import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
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
    final title = widget.tile.title;
    final tiles = widget.tile.tiles;

    if (tiles.isEmpty) {
      return Container(
        color: Colors.blue,
        child: Text(title,
            style: TextStyle(fontSize: 14.0, color: OlukoColors.grayColor)),
      );
    }

    return Container(
      decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
              bottom: BorderSide(width: 1.0, color: OlukoColors.grayColor))),
      child: ExpansionTile(
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
          title: Text(title,
              style: TextStyle(fontSize: 14.0, color: OlukoColors.grayColor)),
          children: tiles
              .map((tile) => Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
                    child: ChildTileWidget(tile: tile),
                  ))
              .toList()),
    );
  }
}
