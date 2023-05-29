import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/models/tag.dart';

class SearchBar<T> extends StatefulWidget {
  final Function(SearchResults<T>) onSearchResults;
  final Function(SearchResults<T>) onSearchSubmit;
  final Function(TextEditingController) whenInitialized;
  final List<T> Function(String, List<T>) suggestionMethod;
  final List<T> Function(String, List<T>, List<T>) searchMethod;
  final List<T> items;
  final GlobalKey<SearchState> searchKey;
  final Function() onTapClose;

  const SearchBar(
      {Key key,
      this.onSearchResults,
      this.suggestionMethod,
      this.searchMethod,
      this.items,
      this.onSearchSubmit,
      this.whenInitialized,
      this.onTapClose,
      this.searchKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SearchState<T>();
}

class SearchState<T> extends State<SearchBar> {
  Timer _debounce;
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = 'Search query';

  @override
  void initState() {
    widget.whenInitialized(_searchQueryController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: OlukoNeumorphism.isNeumorphismDesign
          ? neumorphicDecoration()
          : BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: OlukoNeumorphism.isNeumorphismDesign
            ? Row(
                children: [
                  Expanded(
                    child: _buildSearchField(),
                    // _buildSearchField(),
                  ),
                  _cancelIcon(),
                ],
              )
            : Row(
                children: [
                  _cancelIcon(),
                  Expanded(
                    child: _buildSearchField(),
                    // _buildSearchField(),
                  ),
                  _searchIcon()
                ],
              ),
      ),
    );
  }

  BoxDecoration neumorphicDecoration() {
    return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [OlukoNeumorphismColors.olukoNeumorphicSearchBarFirstColor, OlukoColors.black],
        ),
        borderRadius: BorderRadius.all(Radius.circular(25)));
  }

  Widget _searchIcon() {
    return _searchQueryController.text != ''
        ? GestureDetector(
            onTap: () => updateSearchResults(_searchQueryController.text),
            child: Icon(
              Icons.search,
              color: OlukoColors.appBarIcon,
            ),
          )
        : Icon(
            Icons.search,
            color: OlukoColors.appBarIcon,
          );
  }

  Widget _cancelIcon() {
    return _searchQueryController.text != '' || OlukoNeumorphism.isNeumorphismDesign
        ? GestureDetector(
            onTap: OlukoNeumorphism.isNeumorphismDesign
                ? () {
                    _cancelSearch();
                    //Close keyboard
                    FocusScope.of(context).unfocus();
                    widget.onTapClose();
                  }
                : _cancelSearch,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.close,
                color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.appBarIcon,
              ),
            ),
          )
        : SizedBox();
  }

  void _cancelSearch() {
    _debounce?.cancel();
    setState(() {
      _searchQueryController.text = '';
      updateSearchQuery(_searchQueryController.text, []);
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: "Search",
        border: InputBorder.none,
        hintStyle: OlukoFonts.olukoBigFont(customColor: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => _onSearchChanged(query),
      onSubmitted: (query) => updateSearchResults(query),
    );
  }

  void updateSearchQuery(String newQuery, List<Tag> tags) {
    setState(() {
      searchQuery = newQuery;
      final suggestedItems = widget.suggestionMethod(searchQuery, widget.items);
      final List<T> searchResults = widget.searchMethod(searchQuery, widget.items, tags) as List<T>;
      widget.onSearchResults(SearchResults<T>(query: newQuery, suggestedItems: suggestedItems as List<T>, searchResults: searchResults));
    });
  }

  void updateSearchResults(String newQuery, {List<Tag> selectedTags = const []}) {
    setState(() {
      searchQuery = newQuery;
      List<T> suggestedItems = widget.suggestionMethod(searchQuery, widget.items) as List<T>;
      List<T> searchResults = widget.searchMethod(searchQuery, widget.items, selectedTags) as List<T>;
      widget.onSearchSubmit(
        SearchResults<T>(query: newQuery, suggestedItems: suggestedItems as List<T>, searchResults: searchResults as List<T>),
      );
    });
  }

  _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) {
      _debounce.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 1500), () {
      updateSearchQuery(query, []);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
