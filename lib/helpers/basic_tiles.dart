import 'package:flutter/material.dart';

class BasicTile {
  final String title;
  final List<BasicTile> tiles;
  bool isExpanded;

  BasicTile({@required this.title, this.tiles = const [], this.isExpanded = false});

  static final basicTiles = <BasicTile>[
    BasicTile(title: "Top Queries", tiles: [
      BasicTile(title: "What is included in the membership?", tiles: [
        BasicTile(title: " No information to display, information will be added as soon as possible, check back later."),
      ]),
      BasicTile(title: "How many courses do i get?", tiles: [
        BasicTile(title: " No information to display, information will be added as soon as possible, check back later. "),
      ]),
      BasicTile(title: "Which classes are right for me?", tiles: [
        BasicTile(title: " No information to display, information will be added as soon as possible, check back later. "),
      ]),
    ]),
    BasicTile(title: "Plans, Pricing and Payments", tiles: [
      BasicTile(title: "Plans", tiles: [
        BasicTile(title: "Plan 1", tiles: [
          BasicTile(title: " No information to display, information will be added as soon as possible, check back later. "),
        ]),
        BasicTile(title: "Plan 2", tiles: [
          BasicTile(title: " No information to display, information will be added as soon as possible, check back later. "),
        ]),
      ]),
    ])
  ];
}
