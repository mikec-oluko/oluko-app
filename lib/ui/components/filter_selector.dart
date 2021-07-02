import 'package:flutter/material.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/ui/components/search_filters.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/screen_utils.dart';

import 'oluko_outlined_button.dart';
import 'oluko_primary_button.dart';

class FilterSelector<T extends Base> extends StatefulWidget {
  final String textInput;
  final Map<T, String> itemList;
  final Function(List<T>) onPressed;
  final Function(List<T>) onSubmit;
  final Function() onClosed;

  FilterSelector(
      {this.textInput,
      this.itemList,
      this.onPressed,
      this.onSubmit,
      this.onClosed});

  @override
  State<StatefulWidget> createState() => _State<T>();
}

class _State<T extends Base> extends State<FilterSelector> {
  Map<String, bool> _selected;

  @override
  void initState() {
    clearSelectedItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Container(
                width: ScreenUtils.width(context),
                child: Row(
                  children: [
                    OlukoPrimaryButton(
                      onPressed: submit,
                      title: 'Apply',
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    OlukoOutlinedButton(
                        title: 'Close', onPressed: () => widget.onClosed())
                  ],
                ))),
        _getFilterSelectorContent()
      ],
    );
  }

  Widget _getFilterSelectorContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TitleBody('Intensity'),
      ),
      SearchFilters<T>(
          itemList: Map<T, String>.fromIterable(
              widget.itemList.keys.toList().sublist(0, 4),
              key: (item) => item,
              value: (item) => item.name),
          onPressed: _loadTagsFromSearchFilter),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TitleBody('Equipment'),
      ),
      SearchFilters<T>(
          itemList: Map<T, String>.fromIterable(
              widget.itemList.keys.toList().sublist(4, 8),
              key: (item) => item,
              value: (item) => item.name),
          onPressed: _loadTagsFromSearchFilter),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TitleBody('Workout Duration'),
      ),
      SearchFilters<T>(
          itemList: Map<T, String>.fromIterable(
              widget.itemList.keys.toList().sublist(8, 12),
              key: (item) => item,
              value: (item) => item.name),
          onPressed: _loadTagsFromSearchFilter),
    ]);
  }

  void _loadTagsFromSearchFilter(Map<String, bool> selectedItems) {
    selectedItems.entries.forEach(
        (MapEntry<String, bool> entry) => _selected[entry.key] = entry.value);
    if (widget.onPressed != null) {
      widget.onPressed(_getSelectedItemList());
    }
  }

  List<Base> _getSelectedItemList() {
    return _selected.entries
        .where((element) => element.value == true)
        .map((entry) =>
            widget.itemList.keys.firstWhere((item) => item.id == entry.key))
        .toList();
  }

  void clearSelectedItems() {
    _selected = Map<String, bool>.fromIterable(widget.itemList.keys,
        key: (item) => item.id, value: (item) => false);
  }

  void submit() {
    //Submit a list of selected items on the provided callback.
    if (widget.onSubmit != null) {
      print('${_getSelectedItemList().length} items selected.');
      widget.onSubmit(_getSelectedItemList());
    }
  }
}
