import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/class_item.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/services/class_service.dart';
import 'package:oluko_app/ui/components/challenge_section.dart';
import 'package:oluko_app/ui/components/class_section.dart';
import 'package:oluko_app/ui/components/course_segment_section.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/newDesignComponents/class_section_expansion_panel.dart';
import 'package:oluko_app/ui/screens/courses/custom_expansion_panel_list.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

const SCROLL_DELAY_DURATION = 200;
const SCROLL_DURATION = 600;

class ClassExpansionPanels extends StatefulWidget {
  final List<Class> classes;
  final Function() onPressedMovement;
  final ScrollController screenController;
  final int totalClasses;
  const ClassExpansionPanels({
    this.classes,
    this.onPressedMovement,
    this.screenController,
    this.totalClasses,
  });

  @override
  _State createState() => _State();
}

class _State extends State<ClassExpansionPanels> {
  List<ClassItem> _classItems = [];
  List<Widget> _subClassItems = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_classItems.length != widget.classes.length) {
      _classItems = generateClassItems();
    }
    if (_subClassItems.length != _classItems.length) {
      _subClassItems = generateSubClassItems();
    }
    return expansionPanelNeumorphic();
  }

  Widget expansionPanel() {
    return _classItems.isNotEmpty
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
                    contentPadding: const EdgeInsets.all(0),
                    title: ClassSection(
                      index: _classItems.indexOf(item),
                      total: widget.totalClasses,
                      classObj: item.classObj,
                      onPressed: () {},
                    ),
                  );
                },
                body: _subClassItems[_classItems.indexOf(item)],
                isExpanded: item.expanded,
              );
            }).toList(),
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TitleBody(OlukoLocalizations.get(context, 'noClasses')),
            ),
          );
  }

  Widget expansionPanelNeumorphic() {
    bool isPanelExpanded = false;
    if (_classItems.isNotEmpty) {
      return CustomExpansionPanelList.radio(
        animationDuration: Duration(milliseconds: 500),
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            isPanelExpanded = !_classItems[index].expanded;
            _classItems[index].expanded = !_classItems[index].expanded;
          });
        },
        onPanelTap: (details) {
          if (isPanelExpanded) {
            widget.screenController?.jumpTo(details.globalPosition.dy + (widget.screenController.position.pixels * 0.75));
          }
        },
        children: _classItems.map<ExpansionPanelRadio>((ClassItem item) {
          return ExpansionPanelRadio(
            canTapOnHeader: true,
            backgroundColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker : OlukoColors.black,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return Padding(
                key: item.globalKey,
                padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.only(left: 15.0) : const EdgeInsets.only(),
                child: ClassSectionExpansionPanel(
                  index: _classItems.indexOf(item),
                  total: widget.totalClasses,
                  classObj: item.classObj,
                  onPressed: () {},
                ),
              );
            },
            body: _subClassItems[_classItems.indexOf(item)],
            value: _classItems.indexOf(item),
          );
        }).toList(),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TitleBody(OlukoLocalizations.get(context, 'noClasses')),
        ),
      );
    }
  }

  List<Widget> generateSubClassItems() => _classItems.map((element) => getSubPanel(element)).toList();

  List<ClassItem> generateClassItems() => widget.classes.map((element) => ClassItem(classObj: element, expanded: false)).toList();

  Widget getSubPanel(ClassItem item) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: getClassWidgets(_classItems.indexOf(item)));
  }

  List<Widget> getClassWidgets(int classIndex) {
    if (classIndex >= widget.classes.length) {
      return [];
    }

    Class classObj = widget.classes[classIndex];

    return classObj.segments
        .map((segment) => ListTile(
              title: CourseSegmentSection(
                segment: segment,
                movements: ClassService.getClassSegmentMovementSubmodels(segment.sections),
                onPressedMovement: widget.onPressedMovement,
              ),
            ))
        .toList();
  }
}
