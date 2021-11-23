import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachAppBar extends StatefulWidget implements PreferredSizeWidget {
  final UserResponse coachUser;
  final Function() onNavigation;
  const CoachAppBar({this.coachUser, this.onNavigation});

  @override
  _CoachAppBarState createState() => _CoachAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CoachAppBarState extends State<CoachAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GestureDetector(
                onTap: () {
                  widget.onNavigation();
                  Navigator.pushNamed(context, routeLabels[RouteEnum.coachProfile], arguments: {'coachUser': widget.coachUser});
                },
                child: Text(
                  OlukoLocalizations.get(context, 'hiCoach'),
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
                ),
              ),
            ),
            if (widget.coachUser != null && widget.coachUser.avatarThumbnail != null)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: CircleAvatar(
                  backgroundColor: OlukoColors.black,
                  backgroundImage: Image.network(
                    widget.coachUser.avatarThumbnail,
                    fit: BoxFit.contain,
                    frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
                        ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 24, width: 24),
                    height: 24,
                    width: 24,
                  ).image,
                  radius: 24.0,
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: 5),
                child: CircleAvatar(
                  backgroundColor: OlukoColors.black,
                  radius: 24.0,
                ),
              ),
          ],
        )
      ],
      elevation: 0.0,
      backgroundColor: OlukoColors.black,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.popAndPushNamed(context, routeLabels[RouteEnum.root]);
        },
      ),
    );
  }
}
