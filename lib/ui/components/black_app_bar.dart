import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/components/title_header.dart';

class OlukoAppBar<T> extends StatelessWidget implements PreferredSizeWidget {
  final Function() onPressed;
  final Function(SearchResults<T>) onSearchResults;
  final List<T> Function(String, List<T>) filterMethod;
  final String title;
  final List<Widget> actions;
  final List<T> searchResultItems;
  final bool showSearchBar;

  OlukoAppBar(
      {this.title,
      this.onPressed,
      this.actions,
      this.onSearchResults,
      this.searchResultItems,
      this.showSearchBar = false,
      this.filterMethod});
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 35,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: TitleHeader(
            title,
            bold: true,
          ),
          actions: actions,
          bottom: showSearchBar
              ? PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: SearchBar<T>(
                            items: searchResultItems,
                            onSearchResults:
                                (SearchResults<dynamic> searchResults) =>
                                    onSearchResults(searchResults),
                            filterMethod:
                                (String query, List<dynamic> collection) =>
                                    filterMethod(query, collection),
                          )),
                      Divider(
                        height: 1,
                        color: Colors.white12,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      )
                    ],
                  ))
              : null),
    );
  }

  @override
  Size get preferredSize =>
      new Size.fromHeight(showSearchBar ? kToolbarHeight * 2 : kToolbarHeight);
}
