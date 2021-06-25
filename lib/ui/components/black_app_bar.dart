import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/components/title_header.dart';

class OlukoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function() onPressed;
  final Function(SearchResults) onSearchResults;
  final String title;
  final List<Widget> actions;
  final List<String> searchResultItems;

  OlukoAppBar(
      {this.title,
      this.onPressed,
      this.actions,
      this.onSearchResults,
      this.searchResultItems});
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
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Column(
                children: [
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: SearchBar(
                        items: searchResultItems,
                        onSearchResults: (SearchResults searchResults) =>
                            onSearchResults(searchResults),
                      )),
                  Divider(
                    height: 1,
                    color: Colors.white12,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                  )
                ],
              ))),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight * 2);
}
