import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/search_results.dart';

class SearchBar<T> extends StatefulWidget {
  final Function(SearchResults<T>) onSearchResults;
  final Function(SearchResults<T>) onSearchSubmit;
  final Function(TextEditingController) whenInitialized;
  final List<T> Function(String, List<T>) suggestionMethod;
  final List<T> Function(String, List<T>) searchMethod;
  final List<T> items;
  final GlobalKey<SearchState> searchKey;
  SearchBar({Key key, this.onSearchResults, this.suggestionMethod, this.searchMethod, this.items, this.onSearchSubmit, this.whenInitialized, this.searchKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SearchState<T>();
}

class SearchState<T> extends State<SearchBar> {
  TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = "Search query";

  @override
  void initState() {
    widget.whenInitialized(_searchQueryController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(children: [
              _cancelIcon(),
              Expanded(
                child: _buildSearchField(),
              ),
              _searchIcon()
            ])));
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
    return _searchQueryController.text != ''
        ? GestureDetector(
            onTap: _cancelSearch,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.close,
                color: OlukoColors.appBarIcon,
              ),
            ),
          )
        : SizedBox();
  }

  void _cancelSearch() {
    setState(() {
      _searchQueryController.text = '';
      updateSearchQuery(_searchQueryController.text);
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: "Search",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
      onSubmitted: (query) => updateSearchResults(query),
    );
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      List<T> suggestedItems = widget.suggestionMethod(searchQuery, widget.items) as List<T>;
      List<T> searchResults = widget.searchMethod(searchQuery, widget.items) as List<T>;
      widget.onSearchResults(
          SearchResults<T>(query: newQuery, suggestedItems: suggestedItems, searchResults: searchResults));
    });
  }

  void updateSearchResults(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      List<T> suggestedItems = widget.suggestionMethod(searchQuery, widget.items) as List<T>;
      List<T> searchResults = widget.searchMethod(searchQuery, widget.items) as List<T>;
      widget.onSearchSubmit(SearchResults<T>(
          query: newQuery, suggestedItems: suggestedItems as List<T>, searchResults: searchResults as List<T>));
    });
  }
}
