import 'package:flutter/material.dart';
import 'package:mvt_fitness/ui/components/parent_tile.dart';
import 'package:mvt_fitness/ui/screens/profile/profile_constants.dart';

class ExpansionPanelListWidget extends StatefulWidget {
  @override
  _ExpansionPanelListState createState() => _ExpansionPanelListState();
}

class _ExpansionPanelListState extends State<ExpansionPanelListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: basicTiles.map((tile) => ParentTileWidget(tile: tile)).toList(),
    );
  }
}
