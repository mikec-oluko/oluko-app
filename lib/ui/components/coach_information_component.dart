import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachInformationComponent extends StatefulWidget {
  final CoachUser coachUser;
  const CoachInformationComponent({this.coachUser}) : super();

  @override
  _CoachInformationComponentState createState() => _CoachInformationComponentState();
}

class _CoachInformationComponentState extends State<CoachInformationComponent> {
  String _userLocation;
  String defaultCoachPic = '';
  bool _isVideoPlaying = false;

  @override
  void initState() {
    _userLocation = getUserLocation(widget.coachUser);
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
    return Positioned(
      //COACH INFORMATION
      top: MediaQuery.of(context).size.height / 4,
      child: Container(
          width: MediaQuery.of(context).size.width,
          height: 110,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: OlukoNeumorphism.isNeumorphismDesign
                        ? BoxDecoration(color: Colors.white.withOpacity(0.01), borderRadius: BorderRadius.all(Radius.circular(10.0)))
                        : UserInformationBackground.getContainerGradientDecoration(isNeumorphic: OlukoNeumorphism.isNeumorphismDesign),
                    child: coachInformationContent(context),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Row coachInformationContent(BuildContext context) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: widget.coachUser.avatarThumbnail == null
                  ? Stack(children: [
                      OlukoNeumorphism.isNeumorphismDesign
                          ? Neumorphic(style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(), child: avatarName())
                          : avatarName(),
                    ])
                  : OlukoNeumorphism.isNeumorphismDesign
                      ? Neumorphic(style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(), child: avatarName())
                      : avatarImage(),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OlukoLocalizations.get(context, 'coach'),
                    style: OlukoFonts.olukoBigFont(
                        customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary,
                        custoFontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  widget.coachUser != null
                      ? Text(
                          // widget.coachUser.lastName,
                          widget.coachUser.firstName,
                          style: OlukoFonts.olukoBigFont(
                              customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary,
                              custoFontWeight: FontWeight.w500),
                        )
                      : Container(),
                ],
              ),
            ),
            _userLocation != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      _userLocation,
                      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w300),
                    ),
                  )
                : Container()
          ],
        )
      ],
    );
  }

  CircleAvatar avatarImage() {
    return CircleAvatar(
      backgroundColor: OlukoColors.black,
      backgroundImage: Image(
        image: CachedNetworkImageProvider(widget.coachUser.avatarThumbnail),
        fit: BoxFit.contain,
        frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
            ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 30, width: 30),
        height: 30,
        width: 30,
      ).image,
      radius: 30.0,
    );
  }

  CircleAvatar avatarName() {
    return CircleAvatar(
      backgroundColor:
          widget.coachUser != null ? OlukoColors.userColor(widget.coachUser.firstName, widget.coachUser.lastName) : OlukoColors.black,
      radius: 24.0,
      child: Text(
          widget.coachUser != null
              ? '${widget.coachUser.firstName.characters.first.toUpperCase()}${widget.coachUser.lastName.characters.first.toUpperCase()}'
              : defaultCoachPic,
          style: OlukoFonts.olukoBigFont(customColor: OlukoNeumorphismColors.appBackgroundColor, custoFontWeight: FontWeight.w500)),
    );
  }

  String getUserLocation(CoachUser user) {
    String userLocationContent = '';
    if ((user.city != null && user.city != 'null') &&
        ((user.state != null && user.state != 'null') && (user.country != null && user.country != 'null'))) {
      userLocationContent = "${user.city}, ${user.state} ${user.country}";
    }
    return userLocationContent;
  }
}
