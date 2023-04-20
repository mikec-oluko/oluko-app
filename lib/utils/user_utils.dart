import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/models/tag.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/friend_modal_content.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/search_results_grid.dart';
import 'package:oluko_app/ui/components/users_list_component.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class UserUtils {
  String defaultAvatarImageAsset = 'assets/utils/avatar.png';
  String defaultAvatarImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/oluko-development.appspot.com/o/avatar.png?alt=media&token=c16925c3-e2be-47fb-9d15-8cd1469d9790';

  static CircleAvatar avatarImageDefault({double maxRadius, String name, String lastname, Color circleColor, bool isLoadingState = false}) {
    return CircleAvatar(
      maxRadius: maxRadius ?? 30,
      backgroundColor: circleColor != null
          ? circleColor
          : name == null || lastname == null || name == 'null' || lastname == 'null'
              ? OlukoColors.userColor(null, null)
              : OlukoColors.userColor(name, lastname),
      child: name != null && name.isNotEmpty
          ? isLoadingState
              ? OlukoCircularProgressIndicator()
              : Text(
                  getAvatarText(name, lastname),
                  style: OlukoFonts.olukoBigFont(
                    customColor: OlukoColors.white,
                    customFontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                )
          : Image.asset(
              OlukoNeumorphism.mvtLogo,
              scale: 3,
            ),
    );
  }

  static String getAvatarText(String name, String lastname) {
    String text = '';
    if (name != null && name != 'null' && name.isNotEmpty) {
      text += name.characters?.first?.toUpperCase();
    }
    if (lastname != null && lastname != 'null' && lastname.isNotEmpty) {
      text += lastname.characters?.first?.toUpperCase();
    }
    return text;
  }

  static Future<bool> isFirstTime() async {
    final sharedPref = await SharedPreferences.getInstance();
    final isFirstTime = sharedPref.getBool('first_time');
    return isFirstTime == null || isFirstTime == true;
  }

  static Future<bool> checkFirstTimeAndUpdate() async {
    final sharedPref = await SharedPreferences.getInstance();
    final isFirstTime = sharedPref.getBool('first_time');
    if (isFirstTime != null && !isFirstTime) {
      return false;
    }
    sharedPref.setBool('first_time', false);
    return true;
  }

  static bool userDeviceIsIOS() => Platform.isIOS;
  static bool userDeviceIsAndrioid() => Platform.isAndroid;

  static int getUserAssesmentsQty(Assessment assessment, double userCurrentPlan) => userCurrentPlan != -1
      ? userCurrentPlan == 0
          ? assessment.tasks.getRange(0, 2).toList().length
          : assessment.tasks.length
      : null;

  static List<UserResponse> searchMethod(String query, List<UserResponse> collection, List<Tag> selectedTags) {
    List<UserResponse> results = collection.where((user) => checkContains(user, query)).toList();
    return results;
  }

  static List<UserResponse> suggestionMethod(String query, List<UserResponse> collection) {
    return collection.where((user) => checkContains(user, query)).toList();
  }

  static bool checkContains(UserResponse user, String query) {
    return (user.firstName?.toLowerCase()?.contains(query.toLowerCase()) ?? false) ||
        (user.lastName?.toLowerCase()?.contains(query.toLowerCase()) ?? false) ||
        (user.username?.toLowerCase()?.contains(query.toLowerCase()) ?? false);
  }

  static Widget searchResults(BuildContext context, SearchResults<UserResponse> search, UserResponse authUser) {
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
                      usersProgess: _usersProgress,
                      authUser: authUser,
                      users: search.searchResults,
                      onTapUser: (UserResponse friendUser) => modalOnUserTap(friendUser, authUser, context),
                    ),
                  )
                else
                  UserListComponent(
                    usersProgess: _usersProgress,
                    authUser: authUser,
                    users: search.searchResults,
                    onTapUser: (UserResponse friendUser) => modalOnUserTap(friendUser, authUser, context),
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
          BlocProvider.of<UserProgressStreamBloc>(context)),
      context: context,
    );
  }
}
