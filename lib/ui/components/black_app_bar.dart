import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/components/title_header.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class OlukoAppBar<T> extends StatefulWidget implements PreferredSizeWidget {
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
  State<OlukoAppBar<T>> createState() => _OlukoAppBarState<T>();
  @override
  Size get preferredSize => showSearchBar == true || OlukoNeumorphism.isNeumorphismDesign
      ? new Size.fromHeight(kToolbarHeight * 2)
      : new Size.fromHeight(kToolbarHeight);
}

class _OlukoAppBarState<T> extends State<OlukoAppBar<T>> {
  bool isSearchVisible = false;
  @override
  Widget build(BuildContext context) {
    return buildAppBar(context);
  }

  Widget buildAppBar(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign ? neumorphicAppBar(context) : olukoAppBar(context);
  }

  PreferredSize olukoAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
          backgroundColor: Colors.black,
          leading: widget.showBackButton
              ? IconButton(
                  icon: Icon(Icons.chevron_left, size: 35, color: Colors.white),
                  onPressed: () => {
                        if (this.widget.onPressed == null) {Navigator.pop(context)} else {this.widget.onPressed()}
                      })
              : nil,
          title: widget.showLogo
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'assets/home/mvt.png',
                    scale: 4,
                  ))
              : Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: TitleHeader(widget.title, bold: true, isNeumorphic: OlukoNeumorphism.isNeumorphismDesign))),
          actions: widget.actions,
          bottom: widget.showSearchBar == true
              ? PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: SearchBar<T>(
                            key: widget.searchKey,
                            items: widget.searchResultItems,
                            whenInitialized: (TextEditingController controller) => widget.whenSearchBarInitialized(controller),
                            onSearchSubmit: (SearchResults<dynamic> searchResults) =>
                                widget.onSearchSubmit(searchResults as SearchResults<T>),
                            onSearchResults: (SearchResults<dynamic> searchResults) =>
                                widget.onSearchResults(searchResults as SearchResults<T>),
                            searchMethod: (String query, List<dynamic> collection) => widget.searchMethod(query, collection as List<T>),
                            suggestionMethod: (String query, List<dynamic> collection) =>
                                widget.suggestionMethod(query, collection as List<T>),
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
                      widget.showDivider
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
          // actions: actions,
          automaticallyImplyLeading: false,
          backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
          bottom: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight), child: neumorphicDivider(context)),
          flexibleSpace: widget.showLogo
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
              : widget.showTitle
                  ? widget.showBackButton
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: OlukoNeumorphicCircleButton(onPressed: widget.onPressed),
                              ),
                              Expanded(
                                child: SizedBox(),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: TitleHeader(
                                      widget.title,
                                      bold: false,
                                      isNeumorphic: true,
                                    )),
                              ),
                              Expanded(
                                child: SizedBox(),
                              ),
                            ],
                          ),
                        )
                      : widget.showSearchBar
                          ? Center(
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20.0),
                                      child: Visibility(
                                        visible: !isSearchVisible,
                                        child: GestureDetector(
                                          // onTap: ,
                                          child: OlukoNeumorphicCircleButton(
                                              onPressed: () {
                                                if (widget.title == OlukoLocalizations.get(context, 'filters')) {
                                                  //TODO: hide filters
                                                }
                                                setState(() {
                                                  isSearchVisible = !isSearchVisible;
                                                });
                                              },
                                              customIcon: Icon(
                                                widget.title == OlukoLocalizations.get(context, 'filters')
                                                    ? Icons.arrow_back
                                                    : Icons.search,
                                                color: OlukoColors.grayColor,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: isSearchVisible,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: SearchBar<T>(
                                          key: widget.searchKey,
                                          items: widget.searchResultItems,
                                          whenInitialized: (TextEditingController controller) =>
                                              widget.whenSearchBarInitialized(controller),
                                          onSearchSubmit: (SearchResults<dynamic> searchResults) =>
                                              widget.onSearchSubmit(searchResults as SearchResults<T>),
                                          onSearchResults: (SearchResults<dynamic> searchResults) =>
                                              widget.onSearchResults(searchResults as SearchResults<T>),
                                          searchMethod: (String query, List<dynamic> collection) =>
                                              widget.searchMethod(query, collection as List<T>),
                                          suggestionMethod: (String query, List<dynamic> collection) =>
                                              widget.suggestionMethod(query, collection as List<T>),
                                          onTapClose: () {
                                            setState(() {
                                              isSearchVisible = !isSearchVisible;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  //TODO: TITLE BEHIND SEARCHBAR
                                  Visibility(
                                    visible: !isSearchVisible,
                                    child: Center(
                                      child: TitleHeader(
                                        widget.title,
                                        bold: false,
                                        isNeumorphic: true,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: !isSearchVisible,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: widget.actions,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Center(
                              child: TitleHeader(
                                widget.title,
                                bold: false,
                                isNeumorphic: true,
                              ),
                            )
                  ////TODO: NO SEARCH BAR
                  : SizedBox.shrink(),
        ),
      ),
    );
  }

  OlukoNeumorphicDivider neumorphicDivider(BuildContext context) {
    return const OlukoNeumorphicDivider();
  }
}
