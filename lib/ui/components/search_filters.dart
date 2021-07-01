import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/base.dart';

class SearchFilters<T extends Base> extends StatefulWidget {
  final String textInput;
  final Map<T, String> itemList;
  final Function(T) onPressed;

  SearchFilters({this.textInput, this.itemList, this.onPressed});

  @override
  State<StatefulWidget> createState() => _State<T>();
}

class _State<T extends Base> extends State<SearchFilters> {
  Map<String, bool> selected;

  @override
  void initState() {
    selected = Map<String, bool>.fromIterable(widget.itemList.values,
        key: (item) => item, value: (item) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.start,
        children: widget.itemList.values
            .map(
              (courseName) => GestureDetector(
                onTap: () => this.setState(() {
                  selected[courseName] = !selected[courseName];
                }),
                child: Chip(
                  side: BorderSide(color: OlukoColors.primary),
                  label: Text(
                    courseName,
                    style: TextStyle(
                        color: selected[courseName]
                            ? Colors.black
                            : OlukoColors.primary,
                        fontSize: 15),
                  ),
                  backgroundColor:
                      selected[courseName] ? OlukoColors.primary : Colors.black,
                ),
              ),
            )
            .toList());
  }
}
