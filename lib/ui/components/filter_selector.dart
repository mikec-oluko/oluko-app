import 'package:flutter/material.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/ui/components/search_filters.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'oluko_outlined_button.dart';
import 'oluko_primary_button.dart';

class FilterSelector<T extends Base> extends StatefulWidget {
  final String textInput;
  final Map<String, Map<T, String>> itemList;
  final Function(List<T>) onPressed;
  final Function(List<T>) onSubmit;
  final Function() onClosed;
  List<Base> selectedTags;

  FilterSelector({this.textInput, this.itemList, this.onPressed, this.onSubmit, this.onClosed, this.selectedTags});

  @override
  State<StatefulWidget> createState() => _State<T>();
}

class _State<T extends Base> extends State<FilterSelector> {
  Map<String, bool> _selected;

  @override
  void initState() {
    initializeSelectedItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: _getFilterSelectorContent(),
        ),
        Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Container(
                color: Colors.black,
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
                    OlukoOutlinedButton(title: 'Close', onPressed: () => widget.onClosed())
                  ],
                ))),
      ],
    );
  }

  Widget _getFilterSelectorContent() {
    return Container(
      child: ListView(
          children: widget.itemList.entries
              .map((entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _getFilterCategory(entry),
                  ))
              .toList()),
    );
  }

  List<Widget> _getFilterCategory(MapEntry<String, Map<Base, String>> filterEntry) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TitleBody(filterEntry.key),
      ),
      SearchFilters<T>(
          itemList: Map<T, String>.fromIterable(filterEntry.value.keys,
              key: (item) => item as T, value: (item) => item.name as String),
          selectedTags: _getSelectedItemList(),
          onPressed: _loadTagsFromSearchFilter)
    ];
  }

  void _loadTagsFromSearchFilter(Map<String, bool> selectedItems) {
    this.setState(() {
      selectedItems.entries.forEach((MapEntry<String, bool> entry) => _selected[entry.key] = entry.value);
      if (widget.onPressed != null) {
        widget.onPressed(_getSelectedItemList());
      }
    });
  }

  List<Base> _getSelectedItemList() {
    List<MapEntry<String, bool>> selectedEntries = _selected.entries.where((element) => element.value == true).toList();

    List<T> allItems =
        _getAllValuesFromCategories(widget.itemList.entries.toList() as List<MapEntry<String, Map<T, String>>>)
            .map((item) => item.key)
            .toList();

    return selectedEntries.map((entry) => allItems.firstWhere((item) => item.id == entry.key)).toList();
  }

  List<MapEntry<T, String>> _getAllValuesFromCategories(List<MapEntry<String, Map<T, String>>> itemsInCategories) {
    List<MapEntry<T, String>> allItems = [];

    itemsInCategories
        .forEach((MapEntry<String, Map<T, String>> entry) => entry.value.entries.forEach((item) => allItems.add(item)));
    return allItems;
  }

  //Populate selected items array for first time at widget init
  void initializeSelectedItems() {
    List<MapEntry<T, String>> allItems =
        _getAllValuesFromCategories(widget.itemList.entries.toList() as List<MapEntry<String, Map<T, String>>>)
            .toList();

    _selected = Map.fromIterable(allItems,
        key: (item) => item.key.id as String,
        value: (item) => widget.selectedTags.map((tag) => tag.id).contains(item.key.id));
  }

  void submit() {
    //Submit a list of selected items on the provided callback.
    if (widget.onSubmit != null) {
      print('${_getSelectedItemList().length} items selected.');
      widget.onSubmit(_getSelectedItemList());
    }
  }
}
