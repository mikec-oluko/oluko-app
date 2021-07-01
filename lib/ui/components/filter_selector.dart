import 'package:flutter/material.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/ui/components/search_filters.dart';

class FilterSelector<T extends Base> extends StatefulWidget {
  final String textInput;
  final Map<T, String> itemList;
  final List<String> keyNameList;
  final Function(T) onPressed;

  FilterSelector(
      {this.textInput, this.itemList, this.keyNameList, this.onPressed});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<FilterSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SearchFilters(
        itemList: widget.itemList,
      ),
    );
  }
}
