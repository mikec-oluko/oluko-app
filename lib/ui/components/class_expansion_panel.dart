import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/class_item.dart';
import 'package:oluko_app/services/class_service.dart';
import 'package:oluko_app/ui/components/challenge_section.dart';
import 'package:oluko_app/ui/components/class_section.dart';
import 'package:oluko_app/ui/components/course_segment_section.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ClassExpansionPanel extends StatefulWidget {
  final List<Class> classes;
  final List<Movement> movements;
  final Function(BuildContext, Movement) onPressedMovement;

  ClassExpansionPanel({
    this.classes,
    this.onPressedMovement,
    this.movements,
  });

  @override
  _State createState() => _State();
}

class _State extends State<ClassExpansionPanel> {
  List<ClassItem> _classItems = [];

  @override
  void initState() {
    super.initState();
    // _classItems = generateClassItems(); //TODO: this is receiving old classes from another course
  }

  @override
  Widget build(BuildContext context) {
    _classItems = generateClassItems();
    return _classItems.length > 0
        ? ExpansionPanelList(
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
                    horizontalTitleGap: 0,
                    contentPadding: EdgeInsets.all(0),
                    title: ClassSection(
                      index: _classItems.indexOf(item),
                      total: _classItems.length,
                      classObj: item.classObj,
                      onPressed: () {},
                    ),
                  );
                },
                body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: getClassWidgets(_classItems.indexOf(item))),
                isExpanded: item.expanded,
              );
            }).toList(),
          )
        : Center(
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: TitleBody(OlukoLocalizations.of(context).find("noClasses")),
            ),
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

  List<Widget> getClassWidgets(int classIndex) {
    List<Widget> widgets = [];
    if (widget.classes.length - 1 < classIndex) {
      return [];
    }
    Class classObj = widget.classes[classIndex];
    classObj.segments.forEach((segment) {
      List<Movement> movements = ClassService.getClassSegmentMovements(segment.movements, widget.movements);
      widgets.add(ListTile(
        title: CourseSegmentSection(segmentName: segment.name, movements: movements, onPressedMovement: widget.onPressedMovement),
        subtitle: segment.challengeImage != null ? ChallengeSection(challenges: [segment]) : SizedBox(),
      ));
    });
    return widgets;
  }
}
