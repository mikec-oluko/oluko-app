import 'package:flutter/material.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/ui/components/search_filters.dart';
import 'package:oluko_app/ui/components/title_body.dart';

class FilterSelector<T extends Base> extends StatefulWidget {
  final String textInput;
  final Map<T, String> itemList;
  final List<String> keyNameList;
  final Function(T) onPressed;

  FilterSelector(
      {this.textInput, this.itemList, this.keyNameList, this.onPressed});

  @override
  State<StatefulWidget> createState() => _State<T>();
}

class _State<T extends Base> extends State<FilterSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TitleBody('Intensity'),
      ),
      SearchFilters<T>(
        itemList: Map<T, String>.fromIterable(
            widget.itemList.keys.toList().sublist(0, 4),
            key: (course) => course,
            value: (course) => course.name),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TitleBody('Equipment'),
      ),
      SearchFilters<T>(
        itemList: Map<T, String>.fromIterable(
            widget.itemList.keys.toList().sublist(4, 8),
            key: (course) => course,
            value: (course) => course.name),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TitleBody('Workout Duration'),
      ),
      SearchFilters<T>(
        itemList: Map<T, String>.fromIterable(
            widget.itemList.keys.toList().sublist(8, 12),
            key: (course) => course,
            value: (course) => course.name),
      ),
    ]);
  }
}
