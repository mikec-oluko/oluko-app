import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/class_item.dart';
import 'package:oluko_app/ui/components/class_section.dart';

class ClassExpansionPanel extends StatefulWidget {
  final List<Class> classes;
  final Function(BuildContext, Movement) onPressedMovement;

  ClassExpansionPanel({
    this.classes,
    this.onPressedMovement,
  });

  @override
  _State createState() => _State();
}

class _State extends State<ClassExpansionPanel> {
  List<ClassItem> _classItems = [];

  @override
  void initState() {
    super.initState();
    _classItems = generateClassItems();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _classItems[index].expanded = !_classItems[index].expanded;
        });
      },
      children: _classItems.map<ExpansionPanel>((ClassItem item) {
        return ExpansionPanel(
          canTapOnHeader: true,
          backgroundColor: OlukoColors.black,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: ClassSection(
                index: _classItems.indexOf(item),
                total: _classItems.length,
                classObj: item.classObj,
                onPressed: () {},
              ),
            );
          },
          body: ListTile(
            title: Text(
              "TODO: To be completed.",
              style: OlukoFonts.olukoBigFont(
                  custoFontWeight: FontWeight.normal,
                  customColor: OlukoColors.white),
            ),
            subtitle: Text(
              "TODO: To be completed.",
              style: OlukoFonts.olukoMediumFont(
                  custoFontWeight: FontWeight.normal,
                  customColor: OlukoColors.grayColor),
            ),
          ),
          isExpanded: item.expanded,
        );
      }).toList(),
    );
  }

  List<ClassItem> generateClassItems() {
    List<ClassItem> classItems = [];
    widget.classes.forEach((element) {
      ClassItem classItem = ClassItem(classObj: element, expanded: false);
      classItems.add(classItem);
    });
    return classItems;
  }
}
