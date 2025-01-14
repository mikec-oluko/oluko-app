import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoNeumorphicWhiteButton extends StatefulWidget {
  final Function() onPressed;
  final String title;
  final Color textColor;
  final TextAlign textAlign;
  final Widget icon;
  final bool thinPadding;
  final bool onlyIcon;
  final bool isDisabled;
  final bool isPrimary;
  final bool useBorder;
  final bool isExpanded;
  final bool flatStyle;
  final double customHeight;
  const OlukoNeumorphicWhiteButton(
      {@required this.title,
      @required this.onPressed,
      this.textColor = OlukoColors.black,
      this.textAlign = TextAlign.center,
      this.icon,
      this.thinPadding = false,
      this.onlyIcon = false,
      this.isExpanded = true,
      this.customHeight = 50,
      this.isDisabled = false,
      this.useBorder = false,
      this.flatStyle = false,
      this.isPrimary = true})
      : super();

  @override
  _OlukoNeumorphicWhiteButtonState createState() => _OlukoNeumorphicWhiteButtonState();
}

class _OlukoNeumorphicWhiteButtonState extends State<OlukoNeumorphicWhiteButton> {
  Color buttonColor = OlukoColors.primary;

  @override
  Widget build(BuildContext context) {
    return widget.isExpanded
        ? Expanded(
            child: whiteButton(),
          )
        : Center(child: Container(height: widget.customHeight, child: whiteButton()));
  }

  Widget whiteButton() {
    return NeumorphicButton(
      onPressed: () => widget.onPressed != null ? widget.onPressed() : () {},
      padding: EdgeInsets.all(2),
      style: !widget.isDisabled
          ? OlukoNeumorphism.whiteButtonStyle(
              useBorder: widget.useBorder,
              buttonShape: !widget.flatStyle ? NeumorphicShape.convex : NeumorphicShape.flat,
              boxShape: const NeumorphicBoxShape.stadium(),
              ligthShadow: true,
              darkShadow: true)
          : OlukoNeumorphism.whiteButtonStyle(
              useBorder: widget.useBorder,
              buttonShape: !widget.flatStyle ? NeumorphicShape.convex : NeumorphicShape.flat,
              boxShape: const NeumorphicBoxShape.stadium(),
              ligthShadow: true,
              darkShadow: true,
              isDisabled: widget.isDisabled),
      child: Neumorphic(
        style: !widget.isDisabled
            ? OlukoNeumorphism.whiteButtonStyle(buttonShape: NeumorphicShape.flat, boxShape: NeumorphicBoxShape.stadium(), ligthShadow: true, darkShadow: true)
            : OlukoNeumorphism.whiteButtonStyle(
                buttonShape: !widget.flatStyle ? NeumorphicShape.convex : NeumorphicShape.flat,
                boxShape: const NeumorphicBoxShape.stadium(),
                ligthShadow: true,
                darkShadow: true,
                isDisabled: widget.isDisabled),
        child: Center(
          child: widget.onlyIcon ? widget.icon : _textLabel(),
        ),
      ),
    );
  }

  Widget _textLabel() {
    if (widget.thinPadding) {
      return Text(
        widget.title,
        textAlign: widget.textAlign,
        style: OlukoFonts.olukoBigFont(customColor: widget.isDisabled ? OlukoColors.white : OlukoColors.primary),
      );
    } else {
      return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            widget.title,
            textAlign: widget.textAlign,
            style: OlukoFonts.olukoBigFont(customColor: widget.isDisabled ? OlukoColors.white : OlukoColors.primary),
          ));
    }
  }
}
