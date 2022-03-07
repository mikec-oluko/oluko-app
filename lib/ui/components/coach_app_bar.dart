import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/coach/coach_review_pending_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachAppBar extends StatefulWidget implements PreferredSizeWidget {
  final CoachUser coachUser;
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
  bool showCoachProfle = true;

  @override
  void initState() {
    setState(() {
      if (widget.coachUser != null) {
        defaultCoachPic =
            '${widget.coachUser.firstName.characters.first.toUpperCase()}${widget.coachUser.lastName.characters.first.toUpperCase()}';
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachReviewPendingBloc, CoachReviewPendingState>(
      builder: (context, state) {
        if (state is CoachReviewPendingDispose) {
          numberOfReviewPendingItems = state.reviewsPendingDisposeValue;
        }
        if (state is CoachReviewPendingSuccess) {
          numberOfReviewPendingItems = state.reviewsPending;
        }
        return OlukoNeumorphism.isNeumorphismDesign ? neumorphicCoachAppBar(context) : defaultAppBar(context);
      },
    );
  }

  PreferredSize neumorphicCoachAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OlukoNeumorphicCircleButton(
                onPressed: () {
                  Navigator.popAndPushNamed(context, routeLabels[RouteEnum.root]);
                },
              ),
            ],
          ),
        ),
        actions: [
          if (showCoachProfle)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Row(
                children: [
                  goToCoachProfile(context),
                  const SizedBox(width: 10),
                  if (widget.coachUser != null && widget.coachUser.avatarThumbnail != null)
                    OlukoNeumorphism.isNeumorphismDesign
                        ? Neumorphic(style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(), child: coachAvatarImage())
                        : coachAvatarImage()
                  else
                    OlukoNeumorphism.isNeumorphismDesign
                        ? Neumorphic(style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(), child: coachDefaultAvatar())
                        : coachDefaultAvatar(),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
        ],
        elevation: 0.0,
        backgroundColor: OlukoNeumorphismColors.appBackgroundColor,
      ),
    );
  }

  AppBar defaultAppBar(BuildContext context) {
    return AppBar(
      actions: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: showCoachProfle
                  ? goToCoachProfile(context)
                  : Text(
                      '$numberOfReviewPendingItems  ${OlukoLocalizations.get(context, 'reviewsPending').toUpperCase()}',
                      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
                    ),
            ),
            if (showCoachProfle)
              widget.coachUser != null && widget.coachUser.avatarThumbnail != null ? coachAvatarImage() : coachDefaultAvatar()
            else
              const SizedBox.shrink(),
          ],
        )
      ],
      elevation: 0.0,
      backgroundColor: OlukoNeumorphismColors.appBackgroundColor,
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
            style: OlukoFonts.olukoBigFont(customColor: OlukoNeumorphismColors.appBackgroundColor, custoFontWeight: FontWeight.w500)),
      ),
    ]);
  }

  Padding coachAvatarImage() {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: CircleAvatar(
        backgroundColor: OlukoColors.black,
        backgroundImage: Image(
          image: CachedNetworkImageProvider(widget.coachUser.avatarThumbnail),
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
