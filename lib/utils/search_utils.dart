import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/models/tag.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/filter_selector.dart';
import 'package:oluko_app/ui/components/friend_modal_content.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/components/search_results_grid.dart';
import 'package:oluko_app/ui/components/search_suggestions.dart';
import 'package:oluko_app/ui/components/users_list_component.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class SearchUtils {
  static List<UserResponse> searchUserMethod(String query, List<UserResponse> collection, List<Tag> selectedTags) {
    List<UserResponse> results = collection.where((user) => checkContains(user, query)).toList();
    return results;
  }

  static List<UserResponse> suggestionMethodForUsers(String query, List<UserResponse> collection) {
    return collection.where((user) => checkContains(user, query)).toList();
  }

  static bool checkContains(UserResponse user, String query) {
    return (user.firstName?.toLowerCase()?.contains(query.toLowerCase()) ?? false) ||
        (user.lastName?.toLowerCase()?.contains(query.toLowerCase()) ?? false) ||
        (user.username?.toLowerCase()?.contains(query.toLowerCase()) ?? false);
  }

  static Widget searchUserResults(BuildContext context, SearchResults<UserResponse> search, UserResponse authUser) {
    Map<String, UserProgress> _usersProgress = {};
    ScrollController _viewScrollController = ScrollController();
    return search.searchResults.isEmpty
        ? Padding(
            padding: const EdgeInsets.only(left: 30, top: 20),
            child: Text(
              OlukoLocalizations.get(context, 'noUserFound'),
              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
            ))
        : SizedBox(
            height: ScreenUtils.height(context),
            width: ScreenUtils.width(context),
            child: Column(
              children: [
                if (search.searchResults.isNotEmpty)
                  Expanded(
                    child: UserListComponent(
                      usersProgress: _usersProgress,
                      authUser: authUser,
                      users: search.searchResults,
                      onTapUser: (UserResponse friendUser) => modalOnUserTap(friendUser, authUser, context),
                      isForSearch: true,
                    ),
                  )
                else
                  UserListComponent(
                    usersProgress: _usersProgress,
                    authUser: authUser,
                    users: search.searchResults,
                    onTapUser: (UserResponse friendUser) => modalOnUserTap(friendUser, authUser, context),
                    isForSearch: true,
                  ),
              ],
            ),
          );
  }

  static modalOnUserTap(UserResponse friendUser, UserResponse authUser, BuildContext context) {
    BottomDialogUtils.showBottomDialog(
      content: FriendModalContent(
          friendUser,
          authUser.id,
          null,
          BlocProvider.of<FriendBloc>(context),
          BlocProvider.of<FriendRequestBloc>(context),
          BlocProvider.of<HiFiveSendBloc>(context),
          BlocProvider.of<HiFiveReceivedBloc>(context),
          BlocProvider.of<UserStatisticsBloc>(context),
          BlocProvider.of<FavoriteFriendBloc>(context),
          BlocProvider.of<PointsCardBloc>(context),
          BlocProvider.of<UserProgressStreamBloc>(context)),
      context: context,
    );
  }

  static List<Course> searchCoursesMethod(String query, List<Course> collection, List<Tag> selectedTags) {
    List<Course> resultsWithoutFilters = collection.where((course) => course.name.toLowerCase().contains(query.toLowerCase())).toList();
    List<Course> filteredResults = resultsWithoutFilters.where((Course course) {
      final List<String> courseTagIds = course.tags != null ? course.tags.map((e) => e.id).toList() : [];
      final List<String> selectedTagIds = selectedTags.map((e) => e.id).toList();
      //Return true if no filters are selected
      if (selectedTags.isEmpty) {
        return true;
      }
      //Check if this course match with the current tag filters.
      bool tagMatch = true;
      for (var i = 0; i < selectedTagIds.length && tagMatch; i++) {
        if (!courseTagIds.contains(selectedTagIds[i])) {
          tagMatch = false;
        }
      }
      return tagMatch;
    }).toList();
    return filteredResults;
  }

  static List<Course> suggestionMethodForCourses(String query, List<Course> collection) {
    return collection.where((course) => course.name.toLowerCase().indexOf(query.toLowerCase()) == 0).toList();
  }

  static Widget searchSuggestions(SearchResults<Course> search, GlobalKey<SearchState<dynamic>> searchBarKey, BuildContext context) {
    return search.suggestedItems.isEmpty
        ? CourseUtils.noCourseText(context)
        : SearchSuggestions<Course>(
            textInput: search.query,
            itemList: search.suggestedItems,
            onPressed: (dynamic item) => {searchBarKey.currentState.updateSearchResults(item.name.toString())},
            keyNameList: search.suggestedItems.map((e) => e.name).toList());
  }

  static Widget searchCourseResults(
      BuildContext context, SearchResults<Course> search, double cardsAspectRatio, int searchResultsToShowPortrait, int searchResultsToShowLandscape) {
    return search.searchResults.isEmpty
        ? CourseUtils.noCourseText(context)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 25, bottom: 15),
                child: Text(
                  '${OlukoLocalizations.get(context, 'result')} ${search.searchResults.length} ${OlukoLocalizations.get(context, 'courses').toLowerCase()}',
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: SearchResultsGrid<Course>(
                    childAspectRatio: cardsAspectRatio,
                    crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? searchResultsToShowPortrait : searchResultsToShowLandscape,
                    textInput: search.query,
                    itemList: search.searchResults),
              ),
            ],
          );
  }

  static Widget filterSelector(TagSuccess state,
      {Function(List<Base>) onSubmit, Function() onClosed, List<Tag> selectedTags = const [], Function showBottomTab}) {
    return Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 0, right: 0),
        child: FilterSelector<Tag>(
          itemList: Map.fromIterable(state.tagsByCategories.entries,
              key: (entry) => entry.key.name.toString(),
              value: (entry) => Map.fromIterable(entry.value as Iterable, key: (tag) => tag as Tag, value: (tag) => tag.name.toString())),
          selectedTags: selectedTags,
          onSubmit: onSubmit,
          onClosed: onClosed,
          showBottonTab: showBottomTab,
        ));
  }
}
