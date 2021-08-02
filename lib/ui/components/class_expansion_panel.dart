import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/class_item.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/ui/components/challange_section.dart';
import 'package:oluko_app/ui/components/class_section.dart';
import 'package:oluko_app/ui/components/course_segment_section.dart';

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
          body: Column(children: getClassWidgets(_classItems.indexOf(item))),
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

  List<Widget> getClassWidgets(int classIndex) {
    List<Widget> widgets = [];
    Class classObj = widget.classes[classIndex];
    classObj.segments.forEach((segment) {
      List<Movement> movements = getClassSegmentMovements(segment);
      widgets.add(ListTile(
        title: CourseSegmentSection(
            segmentName: segment.name,
            movements: movements,
            onPressedMovement: widget.onPressedMovement),
            subtitle: segment.challangeImage != null ? ChallangeSection(challanges: [segment]) : SizedBox(),
      ));
    });
    return widgets;
  }

  List<Movement> getClassSegmentMovements(SegmentSubmodel segment) {
    List<String> movementIds = [];
    List<Movement> movements = [];
    segment.movements.forEach((ObjectSubmodel movement) {
      movementIds.add(movement.id);
    });
    widget.movements.forEach((movement) {
      if (movementIds.contains(movement.id)) {
        movements.add(movement);
      }
    });
    return movements;
  }
}
