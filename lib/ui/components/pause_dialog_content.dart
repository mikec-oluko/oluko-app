import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_text_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class PauseDialogContent extends StatefulWidget {
  final Function() restartAction;
  final Function() resumeAction;

  const PauseDialogContent({this.restartAction, this.resumeAction});

  @override
  _PauseDialogContentState createState() => _PauseDialogContentState();
}

class _PauseDialogContentState extends State<PauseDialogContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(OlukoNeumorphism.isNeumorphismDesign ? 20 : 0),
          topRight: Radius.circular(OlukoNeumorphism.isNeumorphismDesign ? 20 : 0),
        ),
        image: DecorationImage(
          image: AssetImage('assets/courses/dialog_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Column(
          crossAxisAlignment: OlukoNeumorphism.isNeumorphismDesign ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            const SizedBox(height: !OlukoNeumorphism.isNeumorphismDesign ? 10 : 30),
            if (!OlukoNeumorphism.isNeumorphismDesign)
              const Icon(Icons.warning_amber_rounded, color: OlukoColors.coral, size: 100)
            else
              Text(
                OlukoLocalizations.get(context, 'cancelSession'),
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white),
              ),
            const SizedBox(height: !OlukoNeumorphism.isNeumorphismDesign ? 5 : 15),
            Text(
              OlukoLocalizations.get(context, 'cancelMessage'),
              textAlign: !OlukoNeumorphism.isNeumorphismDesign ? TextAlign.center : TextAlign.start,
              style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w400, customColor: OlukoColors.grayColor),
            ),
            const SizedBox(height: !OlukoNeumorphism.isNeumorphismDesign ? 20 : 40),
            Row(
              children: [
                const Expanded(child: SizedBox()),
                OlukoNeumorphicTextButton(title: OlukoLocalizations.get(context, 'restart'), onPressed: () => widget.restartAction()),
                OlukoNeumorphicPrimaryButton(
                  title: OlukoLocalizations.get(context, 'resume'),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.resumeAction();
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
