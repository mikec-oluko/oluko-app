import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/notification_bloc.dart';
import 'package:oluko_app/routes.dart';

class HandWidget extends StatelessWidget {
  const HandWidget({
    Key key,
    @required this.authState,
  }) : super(key: key);

  final AuthSuccess authState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, notificationState) {
        return notificationState is NotificationSuccess && notificationState.notifications.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  BlocProvider.of<NotificationBloc>(context).clearAll(authState.user.id);
                  Navigator.pushNamed(context, routeLabels[RouteEnum.hiFivePage]);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0, top: 5),
                  child: notificationState.unseenNotifications > 0
                      ? Badge(
                          position: const BadgePosition(top: 0, start: 10),
                          badgeContent: Text(notificationState.unseenNotifications.toString()),
                          child: getHandIcon(),
                        )
                      : getHandIcon(),
                ),
              )
            : const SizedBox();
      },
    );
  }

  Image getHandIcon() {
    return Image.asset(
      'assets/home/hand.png',
      scale: 4,
    );
  }
}
