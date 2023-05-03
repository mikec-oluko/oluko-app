import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/notification_bloc.dart';
import 'package:oluko_app/routes.dart';
import 'package:badges/badges.dart' as badges;

class HandWidget extends StatefulWidget {
  const HandWidget({
    Key key,
    this.onTap,
    @required this.authState,
  }) : super(key: key);

  final AuthSuccess authState;
  final Function onTap;

  @override
  State<HandWidget> createState() => _HandWidgetState();
}

class _HandWidgetState extends State<HandWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, notificationState) {
        if (notificationState is NotificationSuccess && notificationState.notifications.isNotEmpty) {
          return GestureDetector(
            onTap: () async {
              if (widget.onTap != null) {
                await widget.onTap();
              }
              await BlocProvider.of<NotificationBloc>(context).clearAll(widget.authState.user.id);
              Navigator.pushNamed(context, routeLabels[RouteEnum.hiFivePage]);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 5),
              child: notificationState.unseenNotifications > 0
                  ? badges.Badge(
                      // position: const BadgePosition(top: 0, start: 10),
                      badgeContent: Text(notificationState.unseenNotifications.toString()),
                      child: getHandIcon(),
                    )
                  : getHandIcon(),
            ),
          );
        } else {
          return const SizedBox();
        }
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
