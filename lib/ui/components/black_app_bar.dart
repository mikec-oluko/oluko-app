import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nil/nil.dart';
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
  final bool showBackButton;
  final bool showLogo;
  final String title;
  final List<Widget> actions;
  final List<T> searchResultItems;
  final bool showSearchBar;
  final GlobalKey<SearchState> searchKey;
  final bool showDivider;
  final bool showTitle;

  OlukoAppBar(
      {this.title,
      this.onPressed,
      this.actions,
      this.showLogo = false,
      this.onSearchResults,
      this.searchResultItems,
      this.showSearchBar = false,
      this.suggestionMethod,
      this.searchMethod,
      this.showBackButton = true,
      this.showDivider = true,
      this.showTitle = false,
      this.onSearchSubmit,
      this.whenSearchBarInitialized,
      this.searchKey});
  @override
  Widget build(BuildContext context) {
    return buildAppBar(context);
  }

  Widget buildAppBar(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? neumorphicAppBar(context)
        : PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: AppBar(
                backgroundColor: Colors.black,
                leading: showBackButton
                    ? IconButton(
                        icon: Icon(Icons.chevron_left, size: 35, color: Colors.white),
                        onPressed: () => {
                              if (this.onPressed == null) {Navigator.pop(context)} else {this.onPressed()}
                            })
                    : nil,
                title: showLogo
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/home/mvt.png',
                          scale: 4,
                        ))
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(fit: BoxFit.fitWidth, child: TitleHeader(title, bold: true, isNeumorphic: true))),
                actions: actions,
                bottom: showSearchBar == true
                    ? PreferredSize(
                        preferredSize: Size.fromHeight(kToolbarHeight),
                        child: Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                child: SearchBar<T>(
                                  key: searchKey,
                                  items: searchResultItems,
                                  whenInitialized: (TextEditingController controller) => whenSearchBarInitialized(controller),
                                  onSearchSubmit: (SearchResults<dynamic> searchResults) =>
                                      onSearchSubmit(searchResults as SearchResults<T>),
                                  onSearchResults: (SearchResults<dynamic> searchResults) =>
                                      onSearchResults(searchResults as SearchResults<T>),
                                  searchMethod: (String query, List<dynamic> collection) => searchMethod(query, collection as List<T>),
                                  suggestionMethod: (String query, List<dynamic> collection) =>
                                      suggestionMethod(query, collection as List<T>),
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
                    : PreferredSize(
                        preferredSize: Size.fromHeight(kToolbarHeight),
                        child: Column(
                          children: [
                            showDivider
                                ? Divider(
                                    height: 1,
                                    color: OlukoColors.divider,
                                    thickness: 1.5,
                                    indent: 0,
                                    endIndent: 0,
                                  )
                                : SizedBox()
                          ],
                        ))),
          );
  }

  PreferredSize neumorphicAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: SafeArea(
        child: AppBar(
          backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
          bottom: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight), child: neumorphicDivider(context)),
          flexibleSpace: showLogo
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Image.asset(
                      'assets/home/mvt.png',
                      scale: 4,
                    ),
                  ),
                )
              : showTitle
                  ? Center(
                      child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: TitleHeader(
                            title,
                            bold: false,
                            isNeumorphic: true,
                          )),
                    )
                  : SizedBox.shrink(),
        ),
      ),
    );
  }

  Container neumorphicDivider(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 1.5,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              OlukoColors.grayColorFadeBottom,
              OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
              OlukoColors.grayColorFadeBottom
            ],
            stops: [0.0, 0.5, 1],
          ),
        ));
  }

  @override
  Size get preferredSize => showSearchBar == true || OlukoNeumorphism.isNeumorphismDesign
      ? new Size.fromHeight(kToolbarHeight * 2)
      : new Size.fromHeight(kToolbarHeight);
}
