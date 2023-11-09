import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/remain_selected_tags_bloc.dart';
import 'package:oluko_app/blocs/selected_tags_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/tag.dart';
import 'package:oluko_app/ui/components/search_filters.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
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
  final Function showBottonTab;

  FilterSelector({this.textInput, this.itemList, this.onPressed, this.onSubmit, this.onClosed, this.selectedTags, this.showBottonTab});

  @override
  State<StatefulWidget> createState() => _State<T>();
}

class _State<T extends Base> extends State<FilterSelector> {
  Map<String, bool> _selected;
  Map<String, bool> _remainSelected;

  @override
  void initState() {
    BlocProvider.of<RemainSelectedTagsBloc>(context).get();
    initializeSelectedItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemainSelectedTagsBloc, SelectedTags>(builder: (context, tagsState) {
      if (tagsState is SelectedTags) {
        if (!tagsState.tags.isEmpty) {
          if (_selected == null) {
            _selected = tagsToMap(tagsState.tags);
          } else {
            tagsState.tags.forEach((element) {
              _selected[element.id] = true;
            });
          }
        }
      }
      return Scaffold(
          bottomSheet: SizedBox(height: ScreenUtils.height(context) / 5.6, child: filterNeumorphicButtons(context)),
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: OlukoNeumorphism.isNeumorphismDesign ? ScreenUtils.height(context) / 5.6 + 10 : 20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _getFilterSelectorContent(),
                ),
              ),
            ],
          ));
    });
  }

  Positioned filterButtons(BuildContext context) {
    return Positioned(
        bottom: 15,
        left: 0,
        right: 0,
        child: Container(
            color: OlukoNeumorphismColors.appBackgroundColor,
            width: ScreenUtils.width(context),
            child: Row(
              children: [
                OlukoPrimaryButton(
                  onPressed: submit,
                  title: OlukoLocalizations.get(context, 'apply'),
                ),
                SizedBox(
                  width: 15,
                ),
                OlukoOutlinedButton(title: OlukoLocalizations.get(context, 'close'), onPressed: () => {widget.onClosed()})
              ],
            )));
  }

  Widget filterNeumorphicButtons(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: OlukoNeumorphism.radiusValue,
        topRight: OlukoNeumorphism.radiusValue,
      ),
      child: Container(
          decoration: const BoxDecoration(
              color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight, border: Border(top: BorderSide(color: OlukoColors.grayColorFadeTop))),
          width: ScreenUtils.width(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    height: 60,
                    child: OlukoNeumorphicSecondaryButton(
                        useBorder: true,
                        buttonShape: NeumorphicShape.flat,
                        isExpanded: false,
                        textColor: OlukoColors.grayColor,
                        thinPadding: true,
                        title: OlukoLocalizations.get(context, 'close'),
                        onPressed: () => {widget.onClosed(), widget.showBottonTab()}),
                  ),
                  SizedBox(
                    width: 150,
                    height: 60,
                    child: OlukoNeumorphicPrimaryButton(
                      useBorder: true,
                      isExpanded: false,
                      thinPadding: true,
                      onPressed: submit,
                      title: OlukoLocalizations.get(context, 'apply'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10)
            ]),
          )),
    );
  }

  Widget _getFilterSelectorContent() {
    return ListView(
      physics: OlukoNeumorphism.listViewPhysicsEffect,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      children: widget.itemList.entries
          .map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _getFilterCategory(entry),
              ))
          .toList(),
    );
  }

  List<Widget> _getFilterCategory(MapEntry<String, Map<Base, String>> filterEntry) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TitleBody(filterEntry.key),
      ),
      SearchFilters<T>(
          itemList: Map<T, String>.fromIterable(filterEntry.value.keys, key: (item) => item as T, value: (item) => item.name as String),
          updateSelection: _updateTagsSelected,
          selectedTags: _getSelectedItemList(),
          onPressed: _loadTagsFromSearchFilter)
    ];
  }

  void _loadTagsFromSearchFilter(Map<String, bool> selectedItems) {
    setState(() {
      selectedItems.entries.forEach((MapEntry<String, bool> entry) => _selected[entry.key] = entry.value);
      if (widget.onPressed != null) {
        widget.onPressed(_getSelectedItemList());
      }
    });
  }

  void _updateTagsSelected(Map<String, bool> selectedItems) {
    setState(() {
      selectedItems.entries.forEach((MapEntry<String, bool> entry) => _selected[entry.key] = entry.value);
      BlocProvider.of<RemainSelectedTagsBloc>(context).set(_getSelectedItemList(selectedItemsUpdated: selectedItems) as List<Tag>);
    });
  }

  List<Base> _getSelectedItemList({Map<String, bool> selectedItemsUpdated}) {
    Map<String, bool> _updatedTagSelected = {};
    _updatedTagSelected = selectedItemsUpdated ?? _selected;
    final List<MapEntry<String, bool>> selectedEntries = _updatedTagSelected.entries.where((element) => element.value == true).toList();

    List<T> allItems = _getAllValuesFromCategories(widget.itemList.entries.toList() as List<MapEntry<String, Map<T, String>>>).map((item) => item.key).toList();
    final List<Base> selectedItems = selectedEntries.map((entry) => allItems.firstWhere((item) => item.id == entry.key)).toList();
    BlocProvider.of<SelectedTagsBloc>(context).updateSelectedTags(selectedItems.length);
    return selectedItems;
  }

  List<MapEntry<T, String>> _getAllValuesFromCategories(List<MapEntry<String, Map<T, String>>> itemsInCategories) {
    List<MapEntry<T, String>> allItems = [];

    itemsInCategories.forEach((MapEntry<String, Map<T, String>> entry) => entry.value.entries.forEach((item) => allItems.add(item)));
    return allItems;
  }

  //Populate selected items array for first time at widget init
  void initializeSelectedItems() {
    List<MapEntry<T, String>> allItems = _getAllValuesFromCategories(widget.itemList.entries.toList() as List<MapEntry<String, Map<T, String>>>).toList();

    _selected =
        Map.fromIterable(allItems, key: (item) => item.key.id as String, value: (item) => widget.selectedTags.map((tag) => tag.id).contains(item.key.id));
  }

  void submit() {
    //Submit a list of selected items on the provided callback.
    if (widget.onSubmit != null) {
      widget.showBottonTab();
      print('${_getSelectedItemList().length} items selected.');
      widget.onSubmit(_getSelectedItemList());
    }
  }

  Map<String, bool> tagsToMap(List<Base> tags) {
    Map<String, bool> mappedTags;
    List<MapEntry<T, String>> allItems = _getAllValuesFromCategories(widget.itemList.entries.toList() as List<MapEntry<String, Map<T, String>>>).toList();

    mappedTags = Map.fromIterable(allItems, key: (item) => item.key.id as String, value: (item) => tags.map((tag) => tag.id).contains(item.key.id));
    return mappedTags;
  }
}
