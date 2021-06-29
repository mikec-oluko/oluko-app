import 'package:flutter/material.dart';
import 'package:oluko_app/models/search_results.dart';

class SearchBar<T> extends StatefulWidget {
  final Function(SearchResults<T>) onSearchResults;
  final Function(SearchResults<T>) onSearchSubmit;
  final List<dynamic> Function(String, List<T>) suggestionMethod;
  final List<dynamic> Function(String, List<T>) searchMethod;
  final List<T> items;
  SearchBar(
      {this.onSearchResults,
      this.suggestionMethod,
      this.searchMethod,
      this.items,
      this.onSearchSubmit});

  @override
  State<StatefulWidget> createState() => _State<T>();
}

class _State<T> extends State<SearchBar> {
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(children: [
              Expanded(
                child: _buildSearchField(),
              ),
              _searchIcon()
            ])));
  }

  Widget _searchIcon() {
    return Icon(
      Icons.search,
      color: Colors.white,
    );
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
      List<T> suggestedItems =
          widget.suggestionMethod(searchQuery, widget.items);
      List<T> searchResults = widget.searchMethod(searchQuery, widget.items);
      widget.onSearchResults(SearchResults<T>(
          query: newQuery,
          suggestedItems: suggestedItems,
          searchResults: searchResults));
    });
  }

  void updateSearchResults(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      List<T> suggestedItems =
          widget.suggestionMethod(searchQuery, widget.items);
      List<T> searchResults = widget.searchMethod(searchQuery, widget.items);
      widget.onSearchSubmit(SearchResults<T>(
          query: newQuery,
          suggestedItems: suggestedItems,
          searchResults: searchResults));
    });
  }
}
