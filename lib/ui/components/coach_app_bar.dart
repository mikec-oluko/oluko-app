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

class CoachAppBar extends StatefulWidget implements PreferredSizeWidget {
  final CoachUser coachUser;
  final UserResponse currentUser;
  final Function() onNavigationAction;
  const CoachAppBar({this.coachUser, this.currentUser, this.onNavigationAction});

  @override
  _CoachAppBarState createState() => _CoachAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}

class _CoachAppBarState extends State<CoachAppBar> {
  String defaultCoachPic = '';
  num numberOfReviewPendingItems = 0;
  bool showCoachProfle = true;

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
        return neumorphicCoachAppBar(context);
      },
    );
  }

  PreferredSize neumorphicCoachAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: Visibility(
          visible: false,
          child: Container(
            child: Row(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getSpacerWidget(),
                    Row(
                      children: [
                        if (widget.coachUser != null)
                          CoachAppBarRecordAudioComponent(
                            coachId: widget.coachUser.id,
                            userId: widget.currentUser.id,
                          ),
                        const SizedBox(width: 5),
                        _coachProfilePicWithNavigation(context)
                      ],
                    ),
                    getSpacerWidget()
                  ],
                ),
              )
            : const SizedBox.shrink(),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight), child: OlukoNeumorphicDivider()),
        backgroundColor: OlukoNeumorphismColors.appBackgroundColor,
      ),
    );
  }

  Widget _coachProfilePicWithNavigation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: SizedBox(
        height: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            getSpacerWidget(),
            GestureDetector(
                onTap: () {
                  widget.onNavigationAction();
                  Navigator.pushNamed(context, routeLabels[RouteEnum.coachProfile],
                      arguments: {'coachUser': widget.coachUser, 'currentUser': widget.currentUser});
                },
                child: Neumorphic(
                    style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
                    child: widget.coachUser != null && widget.coachUser.avatar != null ? coachAvatarImage() : coachDefaultAvatar())),
            getSpacerWidget()
          ],
        ),
      ),
    );
  }

  Expanded getSpacerWidget() => const Expanded(child: SizedBox());

  Stack coachDefaultAvatar() {
    return Stack(children: [
      CircleAvatar(
        backgroundColor: widget.coachUser != null ? OlukoColors.userColor(widget.coachUser.firstName, widget.coachUser.lastName) : OlukoColors.black,
        radius: 22.0,
        child: Text(
            widget.coachUser != null
                ? '${widget.coachUser.firstName.characters.first.toUpperCase()}${widget.coachUser.lastName.characters.first.toUpperCase()}'
                : defaultCoachPic,
            style: OlukoFonts.olukoBigFont(customColor: OlukoNeumorphismColors.appBackgroundColor, customFontWeight: FontWeight.w500)),
      ),
    ]);
  }

  Widget coachAvatarImage() {
    const double _imageRadius = 22;
    return CachedNetworkImage(
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
    );
  }
}
