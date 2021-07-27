import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/class_item.dart';

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
  @override
  Widget build(BuildContext context) {
    List<ClassItem> _classItems = generateClassItems();
    return Container(
      padding: EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: _classItems.length,
        itemBuilder: (BuildContext context, int index) {
          return ExpansionPanelList(
            animationDuration: Duration(milliseconds: 1000),
            dividerColor: Colors.red,
            elevation: 1,
            children: [
              ExpansionPanel(
                body: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipOval(
                        child: CircleAvatar(
                          child: Image.asset(
                            _classItems[index].classObj.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        _classItems[index].classObj.description,
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                            letterSpacing: 0.3,
                            height: 1.3),
                      ),
                    ],
                  ),
                ),
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      _classItems[index].classObj.name,
                      style: TextStyle(
                        color: OlukoColors.white,
                        fontSize: 18,
                      ),
                    ),
                  );
                },
                isExpanded: _classItems[index].expanded,
              )
            ],
            expansionCallback: (int item, bool status) {
              setState(() {
                _classItems[index].expanded = !_classItems[index].expanded;
              });
            },
          );
        },
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
}
