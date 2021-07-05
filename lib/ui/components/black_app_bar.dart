import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/components/title_header.dart';

class OlukoAppBar<T> extends StatelessWidget implements PreferredSizeWidget {
  final Function() onPressed;
  final Function(SearchResults<T>) onSearchResults;
  final Function(SearchResults<T>) onSearchSubmit;
  final Function(TextEditingController) whenSearchBarInitialized;
  final List<T> Function(String, List<T>) suggestionMethod;
  final List<T> Function(String, List<T>) searchMethod;
  final String title;
  final List<Widget> actions;
  final List<T> searchResultItems;
  final bool showSearchBar;
  final GlobalKey<SearchState> searchKey;

  OlukoAppBar(
      {this.title,
      this.onPressed,
      this.actions,
      this.onSearchResults,
      this.searchResultItems,
      this.showSearchBar = false,
      this.suggestionMethod,
      this.searchMethod,
      this.onSearchSubmit,
      this.whenSearchBarInitialized,
      this.searchKey});
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
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: TitleHeader(
              title,
              bold: true,
            ),
          ),
          actions: actions,
          bottom: showSearchBar == true
              ? PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: SearchBar<T>(
                            key: searchKey,
                            items: searchResultItems,
                            whenInitialized:
                                (TextEditingController controller) =>
                                    whenSearchBarInitialized(controller),
                            onSearchSubmit:
                                (SearchResults<dynamic> searchResults) =>
                                    onSearchSubmit(searchResults),
                            onSearchResults:
                                (SearchResults<dynamic> searchResults) =>
                                    onSearchResults(searchResults),
                            searchMethod:
                                (String query, List<dynamic> collection) =>
                                    searchMethod(query, collection),
                            suggestionMethod:
                                (String query, List<dynamic> collection) =>
                                    suggestionMethod(query, collection),
                          )),
                      Divider(
                        height: 1,
                        color: OlukoColors.divider,
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
  Size get preferredSize => showSearchBar == true
      ? new Size.fromHeight(kToolbarHeight * 2)
      : new Size.fromHeight(kToolbarHeight);
}
