import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_review_pending_bloc.dart';
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
  String defaultCoachPic = '';
  num numberOfReviewPendingItems = 0;
  bool showCoachProfle = false;

  @override
  void initState() {
    setState(() {
      if (widget.coachUser != null) {
        defaultCoachPic =
            '${widget.coachUser.firstName.characters.first.toUpperCase()}${widget.coachUser.lastName.characters.first.toUpperCase()}';
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachReviewPendingBloc, CoachReviewPendingState>(
      builder: (context, state) {
        if (state is CoachReviewPendingSuccess) {
          numberOfReviewPendingItems = state.reviewsPending;
        }
        return AppBar(
          actions: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: showCoachProfle
                      ? goToCoachProfile(context)
                      : Text(
                          '$numberOfReviewPendingItems REVIEWS PENDING',
                          style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
                        ),
                ),
                showCoachProfle
                    ? widget.coachUser != null && widget.coachUser.avatarThumbnail != null
                        ? coachAvatarImage()
                        : coachDefaultAvatar()
                    : SizedBox.shrink(),
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
      },
    );
  }

  Stack coachDefaultAvatar() {
    return Stack(children: [
      CircleAvatar(
        backgroundColor:
            widget.coachUser != null ? OlukoColors.userColor(widget.coachUser.firstName, widget.coachUser.lastName) : OlukoColors.black,
        radius: 24.0,
        child: Text(
            widget.coachUser != null
                ? '${widget.coachUser.firstName.characters.first.toUpperCase()}${widget.coachUser.lastName.characters.first.toUpperCase()}'
                : defaultCoachPic,
            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500)),
      ),
    ]);
  }

  Padding coachAvatarImage() {
    return Padding(
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
    );
  }

  GestureDetector goToCoachProfile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onNavigation();
        Navigator.pushNamed(context, routeLabels[RouteEnum.coachProfile], arguments: {'coachUser': widget.coachUser});
      },
      child: Text(
        OlukoLocalizations.get(context, 'hiCoach'),
        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
      ),
    );
  }
}
