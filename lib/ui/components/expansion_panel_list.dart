import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/basic_tiles.dart';
import 'package:oluko_app/models/submodels/questions_answers.dart';
import 'package:oluko_app/ui/components/parent_tile.dart';

class ExpansionPanelListWidget extends StatefulWidget {
  List<QuestionAndAnswer> faqList;
    ExpansionPanelListWidget({this.faqList});
  @override
  _ExpansionPanelListState createState() => _ExpansionPanelListState();
}

class _ExpansionPanelListState extends State<ExpansionPanelListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
      child: ListView(
        children:widget.faqList.map((tile) => ParentTileWidget(tile: BasicTile(title:tile.question ,tiles: [BasicTile(title: tile.answer)]))).toList(),
      ),
    );
  }
}
