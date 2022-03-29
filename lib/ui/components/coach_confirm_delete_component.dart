import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachConfirmDeleteComponent extends StatefulWidget {
  final Function() denyAction;
  final Function() allowAction;
  final bool isPreviewContent;

  const CoachConfirmDeleteComponent({Key key, @required this.denyAction, @required this.allowAction, @required this.isPreviewContent})
      : super(key: key);

  @override
  State<CoachConfirmDeleteComponent> createState() => _CoachConfirmDeleteComponentState();
}

class _CoachConfirmDeleteComponentState extends State<CoachConfirmDeleteComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                widget.isPreviewContent
                    ? OlukoLocalizations.get(context, 'cancelVoiceMessage')
                    : OlukoLocalizations.get(context, 'deleteVoiceMessage'),
                style: OlukoFonts.olukoSubtitleFont(customColor: OlukoColors.white)),
            Text(OlukoLocalizations.get(context, 'deleteMessageConfirm'),
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor))
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => widget.denyAction(),
                child: Text(OlukoLocalizations.get(context, 'deny')),
              ),
              Container(
                  width: 80,
                  height: 50,
                  child: OlukoNeumorphicPrimaryButton(
                      isExpanded: false, title: OlukoLocalizations.get(context, 'allow'), onPressed: () => widget.allowAction()))
            ],
          ),
        )
      ],
    );
  }
}
