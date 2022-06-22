import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/base.dart';

class SearchFilters<T extends Base> extends StatefulWidget {
  final String textInput;
  final Map<T, String> itemList;
  final Function(Map<String, bool>) onPressed;
  final List<Base> selectedTags;

  SearchFilters({this.textInput, this.itemList, this.onPressed, this.selectedTags});

  @override
  State<StatefulWidget> createState() => _State<T>();
}

class _State<T extends Base> extends State<SearchFilters> {
  Map<String, bool> selected;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    selected = _setSelectedTags();
    return Wrap(
        spacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.start,
        children: widget.itemList.entries
            .map(
              (MapEntry<Base, String> courseName) => GestureDetector(
                onTap: () => this.setState(() {
                  selected[courseName.key.id] = !selected[courseName.key.id];
                  widget.onPressed(selected);
                }),
                child: OlukoNeumorphism.isNeumorphismDesign
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                        child: buildNeumorphicChip(courseName),
                      )
                    : buildChip(courseName),
              ),
            )
            .toList());
  }

  Chip buildChip(MapEntry<Base, String> courseName) {
    return Chip(
      side: BorderSide(color: OlukoColors.primary),
      label: Text(
        courseName.value,
        style: TextStyle(color: selected[courseName.key.id] ?OlukoColors.black : OlukoColors.primary, fontSize: 15),
      ),
      backgroundColor: selected[courseName.key.id] ? OlukoColors.primary : OlukoColors.black,
    );
  }

  Container buildNeumorphicChip(MapEntry<Base, String> courseName) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        color: selected[courseName.key.id] ? OlukoColors.primary : OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat,
      ),
      // side: BorderSide(color: OlukoColors.primary),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Text(
          courseName.value,
          style: OlukoFonts.olukoMediumFont(
              customColor: selected[courseName.key.id] ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.grayColor),
        ),
      ),
    );
  }

  Map<String, bool> _setSelectedTags() {
    return Map<String, bool>.fromIterable(widget.itemList.keys,
        key: (item) => item.id as String, value: (item) => widget.selectedTags.map((e) => e.id).contains(item.id));
  }
}
