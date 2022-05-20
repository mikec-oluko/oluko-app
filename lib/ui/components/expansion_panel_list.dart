import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/basic_tiles.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/faq_item.dart';
import 'package:oluko_app/ui/components/parent_tile.dart';

class ExpansionPanelListWidget extends StatefulWidget {
  List<FAQItem> faqList;
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
        children: [
          for (var type in FAQCategoriesEnum.values)
            ParentTileWidget(
              tile: BasicTile(title: fAQCategories[type], tiles: [
                for (FAQItem faq in widget.faqList)
                  if (faq.category == type) BasicTile(title: faq.question, tiles: [BasicTile(title: faq.answer)]),
              ]),
            )
        ],
      ),
    );
  }
}
