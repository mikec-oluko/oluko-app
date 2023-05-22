import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';

import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class BottomDialogUtils {
  static showBottomDialog({BuildContext context, Widget content, bool isScrollControlled = false, Function() onDismissAction}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext _) {
          return content;
        },
        isScrollControlled: isScrollControlled
        ).whenComplete(() => {
          if (onDismissAction != null){
            onDismissAction()
          }
        });
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
