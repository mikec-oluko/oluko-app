import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachRequestContent extends StatefulWidget {
  final Function() onRecordingAction;
  final Function() onNotRecordingAction;
  final Function() onNotificationDismiss;
  final String image;
  final String name;
  final bool isNotification;

  const CoachRequestContent({this.onRecordingAction, this.onNotRecordingAction, this.image, this.name, this.isNotification, this.onNotificationDismiss});

  @override
  _CoachRequestContentState createState() => _CoachRequestContentState();
}

class _CoachRequestContentState extends State<CoachRequestContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            image: DecorationImage(
              image: AssetImage('assets/courses/dialog_background.png'),
              fit: BoxFit.cover,
            )),
        child: Stack(children: [
          Column(children: [
            const SizedBox(height: 25),
            Stack(
                alignment: Alignment.center,
                children: [StoriesItem(maxRadius: 65, imageUrl: widget.image), Image.asset('assets/neumorphic/black_ellipse.png', scale: 2.5)]),
            const SizedBox(height: 15),
            coachName(context),
            const SizedBox(height: 15),
            coachRequestText(context),
            const SizedBox(height: 35),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: getButtonsForPanel())),
          ]),
          closeButton(context)
        ]));
  }

  Align closeButton(BuildContext context) {
    return Align(
        alignment: Alignment.topRight,
        child: Padding(
            padding: EdgeInsets.only(top: 15, right: 15),
            child: IconButton(icon: const Icon(Icons.close, color: OlukoColors.primary), onPressed: () => Navigator.pop(context))));
  }

  OlukoNeumorphicPrimaryButton acceptButton(BuildContext context) {
    return OlukoNeumorphicPrimaryButton(
        title: OlukoLocalizations.get(context, 'ok'),
        onPressed: () {
          widget.isNotification ? widget.onNotificationDismiss() : widget.onRecordingAction();
        });
  }

  OlukoNeumorphicSecondaryButton ignoreButton(BuildContext context) {
    return OlukoNeumorphicSecondaryButton(
        lighterButton: true,
        title: OlukoLocalizations.get(context, 'ignore'),
        onPressed: () {
          widget.onNotRecordingAction();
        });
  }

  Padding coachRequestText(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Text(coachRecordingRequestMessage(context),
            textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w400)));
  }

  String coachRecordingRequestMessage(BuildContext context) => widget.isNotification
      ? "${OlukoLocalizations.get(context, 'segmentNotificationTimerEnd')} ${widget.name} ${OlukoLocalizations.get(context, 'segmentNotificationRequestRecordMessage')}"
      : "${OlukoLocalizations.get(context, 'coach')} ${widget.name} ${OlukoLocalizations.get(context, 'coachRequest')}";

  Text coachName(BuildContext context) {
    return Text('${OlukoLocalizations.get(context, 'coach')} ${widget.name}',
        textAlign: TextAlign.center, style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold));
  }

  List<Widget> getButtonsForPanel() {
    return widget.isNotification
        ? [
            acceptButton(context),
          ]
        : [
            ignoreButton(context),
            const SizedBox(width: 20),
            acceptButton(context),
          ];
  }
}
