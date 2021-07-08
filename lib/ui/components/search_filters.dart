import 'package:flutter/material.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/models/base.dart';

class SearchFilters<T extends Base> extends StatefulWidget {
  final String textInput;
  final Map<T, String> itemList;
  final Function(Map<String, bool>) onPressed;
  final List<Base> selectedTags;

  SearchFilters(
      {this.textInput, this.itemList, this.onPressed, this.selectedTags});

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
                child: Chip(
                  side: BorderSide(color: OlukoColors.primary),
                  label: Text(
                    courseName.value,
                    style: TextStyle(
                        color: selected[courseName.key.id]
                            ? Colors.black
                            : OlukoColors.primary,
                        fontSize: 15),
                  ),
                  backgroundColor: selected[courseName.key.id]
                      ? OlukoColors.primary
                      : Colors.black,
                ),
              ),
            )
            .toList());
  }

  Map<String, bool> _setSelectedTags() {
    return Map<String, bool>.fromIterable(widget.itemList.keys,
        key: (item) => item.id,
        value: (item) =>
            widget.selectedTags.map((e) => e.id).contains(item.id));
  }
}
