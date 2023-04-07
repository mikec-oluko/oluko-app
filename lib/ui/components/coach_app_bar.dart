import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/coach/coach_review_pending_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/newDesignComponents/coach_app_bar_record_audio_component.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/sound_recorder.dart';
import 'package:oluko_app/utils/time_converter.dart';

class CoachAppBar extends StatefulWidget implements PreferredSizeWidget {
  final CoachUser coachUser;
  final UserResponse currentUser;
  final Function() onNavigation;
  const CoachAppBar({this.coachUser, this.currentUser, this.onNavigation});

  @override
  _CoachAppBarState createState() => _CoachAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}

class _CoachAppBarState extends State<CoachAppBar> {
  String defaultCoachPic = '';
  num numberOfReviewPendingItems = 0;
  bool showCoachProfle = true;
  // final SoundRecorder _recorder = SoundRecorder();

  @override
  void initState() {
    setState(() {
      if (widget.coachUser != null) {
        defaultCoachPic = '${widget.coachUser.firstName.characters.first.toUpperCase()}${widget.coachUser.lastName.characters.first.toUpperCase()}';
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
        leading: Visibility(
          visible: false,
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OlukoNeumorphicCircleButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, routeLabels[RouteEnum.root]);
                  },
                ),
              ],
            ),
          ),
        ),
        flexibleSpace: showCoachProfle
            ? PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5).copyWith(top: 5),
                    child: Container(
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CoachAppBarRecordAudioComponent(
                            coachId: widget.coachUser.id,
                            userId: widget.currentUser.id,
                            // audioRecorder: _recorder,
                          ), // goToCoachProfile(context),
                          const SizedBox(width: 10),
                          if (widget.coachUser != null && widget.coachUser.avatar != null)
                            OlukoNeumorphism.isNeumorphismDesign
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: GestureDetector(
                                        onTap: () {
                                          widget.onNavigation();
                                          Navigator.pushNamed(context, routeLabels[RouteEnum.coachProfile],
                                              arguments: {'coachUser': widget.coachUser, 'currentUser': widget.currentUser});
                                        },
                                        child: Neumorphic(style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(), child: coachAvatarImage())),
                                  )
                                : coachAvatarImage()
                          else
                            OlukoNeumorphism.isNeumorphismDesign
                                ? Neumorphic(style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(), child: coachDefaultAvatar())
                                : coachDefaultAvatar(),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(kToolbarHeight), child: OlukoNeumorphicDivider()),
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
                      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500),
                    ),
            ),
            if (showCoachProfle)
              widget.coachUser != null && widget.coachUser.avatar != null ? coachAvatarImage() : coachDefaultAvatar()
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
        backgroundColor: widget.coachUser != null ? OlukoColors.userColor(widget.coachUser.firstName, widget.coachUser.lastName) : OlukoColors.black,
        radius: 24.0,
        child: Text(
            widget.coachUser != null
                ? '${widget.coachUser.firstName.characters.first.toUpperCase()}${widget.coachUser.lastName.characters.first.toUpperCase()}'
                : defaultCoachPic,
            style: OlukoFonts.olukoBigFont(customColor: OlukoNeumorphismColors.appBackgroundColor, customFontWeight: FontWeight.w500)),
      ),
    ]);
  }

  Padding coachAvatarImage() {
    final double _imageRadius = 24;
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: CachedNetworkImage(
        height: _imageRadius * 2,
        width: _imageRadius * 2,
        maxWidthDiskCache: (_imageRadius * 2).toInt(),
        maxHeightDiskCache: (_imageRadius * 2).toInt(),
        fit: BoxFit.cover,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
          maxRadius: _imageRadius ?? 30,
        ),
        imageUrl: widget.coachUser.avatar,
      ),
    );
  }

  GestureDetector goToCoachProfile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onNavigation();
        Navigator.pushNamed(context, routeLabels[RouteEnum.coachProfile], arguments: {'coachUser': widget.coachUser, 'currentUser': widget.currentUser});
      },
      child: Text(
        OlukoLocalizations.get(context, 'hiCoach'),
        style: OlukoFonts.olukoMediumFont(
            customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary, customFontWeight: FontWeight.w500),
      ),
    );
  }
}
