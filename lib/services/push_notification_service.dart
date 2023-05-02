import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/push_notification_bloc.dart';
import 'package:oluko_app/blocs/user_bloc.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class PushNotificationService {
  static FirebaseMessaging messagin = FirebaseMessaging.instance;
  static String token;
  static bool bottomDialogDisplayed = false;

  static Future<void> initializePushNotifications(BuildContext context, String userId) async {
    await messagin.requestPermission();
    final String token = await messagin.getToken();
    BlocProvider.of<UserBloc>(context).saveToken(userId, token);
  }

  static void listenPushNotifications(BuildContext contextPush) {
    messagin.getInitialMessage().then((RemoteMessage message) {
      notifyNewPushNotification(message, contextPush);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data != null && !bottomDialogDisplayed) {
        bottomDialogDisplayed = true;
        BottomDialogUtils.showBottomDialog(
          content: Container(
            height: 270,
            decoration: const BoxDecoration(
              borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(20)),
              image: DecorationImage(
                image: AssetImage('assets/courses/dialog_background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      message.data['title']?.toString(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      message.data['body']?.toString(),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.grey),
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
                          width: 100,
                          child: OlukoNeumorphicSecondaryButton(
                            isExpanded: false,
                            thinPadding: true,
                            textColor: Colors.grey,
                            onPressed: () {
                              bottomDialogDisplayed = false;
                              Navigator.pop(contextPush);
                            },
                            title: OlukoLocalizations.get(contextPush, 'ignore'),
                          ),
                        ),
                        const SizedBox(width: 25),
                        SizedBox(
                          width: 150,
                          child: OlukoNeumorphicPrimaryButton(
                            isExpanded: false,
                            thinPadding: true,
                            onPressed: () {
                              bottomDialogDisplayed = false;
                              Navigator.pop(contextPush);
                              notifyNewPushNotification(message, contextPush);
                            },
                            title: OlukoLocalizations.get(contextPush, 'goToCoach'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          context: contextPush,
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      notifyNewPushNotification(message, contextPush);
    });
  }

  static void notifyNewPushNotification(RemoteMessage message, BuildContext contextPush) {
    if (message != null && message.data != null) {
      BlocProvider.of<PushNotificationBloc>(contextPush).notifyNewPushNotification();
    }
  }
}
