import 'package:flutter/material.dart';
import 'package:oluko_app/helpers/basic_tiles.dart';
import 'package:oluko_app/ui/components/parent_tile.dart';

class ExpansionPanelListWidget extends StatefulWidget {
  @override
  _ExpansionPanelListState createState() => _ExpansionPanelListState();
}

class _ExpansionPanelListState extends State<ExpansionPanelListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: BasicTile.basicTiles
          .map((tile) => ParentTileWidget(tile: tile))
          .toList(),
    );
  }
}
