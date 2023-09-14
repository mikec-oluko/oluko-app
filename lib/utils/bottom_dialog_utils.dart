import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/friend_modal_content.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';

import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class BottomDialogUtils {
  static showBottomDialog(
      {BuildContext context,
      Widget content,
      bool isScrollControlled = false,
      bool barrierColor = true,
      Function() onDismissAction,
      bool backgroundTapEnable = true}) {
    showModalBottomSheet(
            isDismissible: backgroundTapEnable ?? true,
            barrierColor: barrierColor ? null : Colors.transparent,
            context: context,
            builder: (BuildContext _) {
              return content;
            },
            isScrollControlled: isScrollControlled)
        .whenComplete(() => {
              if (onDismissAction != null) {onDismissAction()}
            });
  }

  static friendsModal(
    UserResponse friendUser,
    String currentUserId,
    Map<String, UserProgress> usersProgess,
    BuildContext context, {
    bool barrierColor = true,
  }) {
    showModalBottomSheet(
      barrierColor: barrierColor ? null : Colors.transparent,
      context: context,
      builder: (_) {
        return FriendModalContent(
            friendUser,
            currentUserId,
            usersProgess,
            BlocProvider.of<FriendBloc>(context),
            BlocProvider.of<FriendRequestBloc>(context),
            BlocProvider.of<HiFiveSendBloc>(context),
            BlocProvider.of<HiFiveReceivedBloc>(context),
            BlocProvider.of<UserStatisticsBloc>(context),
            BlocProvider.of<FavoriteFriendBloc>(context),
            BlocProvider.of<PointsCardBloc>(context),
            BlocProvider.of<UserProgressStreamBloc>(context));
      },
    );
  }

  static void removeConfirmationPopup(String userId, UserResponse userToDelete, Friend friend, BuildContext context, FriendBloc blocFriends) {
    showBottomDialog(
      content: Container(
        height: ScreenUtils.height(context) * 0.3,
        decoration: const BoxDecoration(
          borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(20)),
          image: DecorationImage(
            image: AssetImage('assets/courses/dialog_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      OlukoLocalizations.get(context, 'removeThisPerson'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      OlukoLocalizations.get(context, 'removeThisPersonBody1') +
                          userToDelete.username +
                          OlukoLocalizations.get(context, 'removeThisPersonBody2'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 80,
                          child: OlukoNeumorphicSecondaryButton(
                            isExpanded: false,
                            thinPadding: true,
                            textColor: Colors.grey,
                            onPressed: () => Navigator.pop(context),
                            title: OlukoLocalizations.get(context, 'no'),
                          ),
                        ),
                        const SizedBox(width: 25),
                        SizedBox(
                          width: 80,
                          child: OlukoNeumorphicPrimaryButton(
                            isExpanded: false,
                            thinPadding: true,
                            onPressed: () {
                              blocFriends.removeFriend(userId, friend, userToDelete.id);
                              Navigator.pop(context);
                            },
                            title: OlukoLocalizations.get(context, 'yes'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      context: context,
    );
  }
}
