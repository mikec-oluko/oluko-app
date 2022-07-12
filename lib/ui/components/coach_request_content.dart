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
  final String image;
  final String name;

  const CoachRequestContent({this.onRecordingAction, this.onNotRecordingAction, this.image, this.name});

  @override
  _CoachRequestContentState createState() => _CoachRequestContentState();
}

class _CoachRequestContentState extends State<CoachRequestContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(OlukoNeumorphism.isNeumorphismDesign ? 20 : 0),
                topRight: Radius.circular(OlukoNeumorphism.isNeumorphismDesign ? 20 : 0)),
            image: DecorationImage(
              image: AssetImage('assets/courses/dialog_background.png'),
              fit: BoxFit.cover,
            )),
        child: Stack(children: [
          Column(children: [
            const SizedBox(height: 25),
            Stack(alignment: Alignment.center, children: [
              StoriesItem(maxRadius: 65, imageUrl: widget.image),
              OlukoNeumorphism.isNeumorphismDesign ? Image.asset('assets/neumorphic/black_ellipse.png', scale: 2.5) : SizedBox()
            ]),
            const SizedBox(height: 15),
            Text(OlukoLocalizations.get(context, 'coach') + " " + widget.name,
                textAlign: TextAlign.center, style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                    OlukoLocalizations.get(context, 'coach') + " " + widget.name + " " + OlukoLocalizations.get(context, 'coachRequest'),
                    textAlign: TextAlign.center,
                    style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w400))),
            const SizedBox(height: 35),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OlukoNeumorphism.isNeumorphismDesign
                        ? OlukoNeumorphicSecondaryButton(
                            title: OlukoLocalizations.get(context, 'ignore'),
                            onPressed: () {
                              widget.onNotRecordingAction();
                            })
                        : OlukoOutlinedButton(
                            title: OlukoLocalizations.get(context, 'ignore'),
                            onPressed: () {
                              widget.onNotRecordingAction();
                            },
                          ),
                    const SizedBox(width: 20),
                    OlukoNeumorphism.isNeumorphismDesign
                        ? OlukoNeumorphicPrimaryButton(
                            title: OlukoLocalizations.get(context, 'ok'),
                            onPressed: () {
                              widget.onRecordingAction();
                            })
                        : OlukoPrimaryButton(
                            title: OlukoLocalizations.get(context, 'ok'),
                            onPressed: () {
                              widget.onRecordingAction();
                            },
                          )
                  ],
                )),
          ]),
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: EdgeInsets.only(top: 15, right: 15),
                  child: IconButton(
                      icon: const Icon(Icons.close, color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.primary : OlukoColors.white),
                      onPressed: () => Navigator.pop(context))))
        ]));
  }
}
