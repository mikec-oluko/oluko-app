import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_switch.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class TaskDetailsFormSection extends StatefulWidget {
  final bool makeThisPublic;
  final String taskDescription;
  final Widget recordedVideo;
  final Function(bool value) switchUpdated;
  const TaskDetailsFormSection({Key key, this.makeThisPublic = false, this.taskDescription, this.recordedVideo, this.switchUpdated}) : super(key: key);

  @override
  State<TaskDetailsFormSection> createState() => _TaskDetailsFormSectionState();
}

class _TaskDetailsFormSectionState extends State<TaskDetailsFormSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              OlukoLocalizations.get(context, 'makeThisPublic'),
              style: OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.bold),
            ),
            if (OlukoNeumorphism.isNeumorphismDesign)
              OlukoNeumorphicSwitch(
                value: widget.makeThisPublic ?? false,
                onSwitchChange: (bool value) => widget.switchUpdated(value),
              )
            else
              Switch(
                value: widget.makeThisPublic ?? false,
                onChanged: (bool value) => widget.switchUpdated(value),
                trackColor: MaterialStateProperty.all(Colors.grey),
                activeColor: OlukoColors.primary,
              )
          ],
        ),
      ),
      Text(
        widget.taskDescription,
        style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
      ),
      widget.recordedVideo
    ]));
  }
}
