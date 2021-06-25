import 'package:flutter/material.dart';
import 'package:oluko_app/models/search_results.dart';

class SearchBar extends StatefulWidget {
  final Function(SearchResults) onSearchResults;
  final List<String> items;
  SearchBar({this.onSearchResults, this.items});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SearchBar> {
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
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      List<String> suggestedItems =
          widget.items.where((element) => element.contains(newQuery)).toList();
      widget.onSearchResults(
          SearchResults(query: newQuery, suggestedItems: suggestedItems));
    });
  }
}
