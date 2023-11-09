import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoNeumorphicSwitch extends StatefulWidget {
  final bool value;
  final Function(bool value) onSwitchChange;
  const OlukoNeumorphicSwitch({@required this.value, @required this.onSwitchChange});

  @override
  _OlukoNeumorphicSwitchState createState() => _OlukoNeumorphicSwitchState();
}

class _OlukoNeumorphicSwitchState extends State<OlukoNeumorphicSwitch> {
  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
          depth: 2,
          intensity: 1,
          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
          shape: NeumorphicShape.flat,
          lightSource: LightSource.bottom,
          boxShape: NeumorphicBoxShape.stadium(),
          shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
          shadowLightColorEmboss: OlukoColors.black,
          surfaceIntensity: 1,
          shadowLightColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
          shadowDarkColor: OlukoColors.black),
      child: Container(
        width: 50,
        height: 30,
        child: NeumorphicSwitch(
          style: NeumorphicSwitchStyle(
              inactiveThumbColor: OlukoColors.primary,
              activeThumbColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
              activeTrackColor: OlukoColors.primary,
              inactiveTrackColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
              thumbShape: NeumorphicShape.flat,
              thumbDepth: 1,
              disableDepth: true),
          value: widget.value,
          onChanged: (bool value) => widget.onSwitchChange(value),
        ),
      ),
    );
  }
}
