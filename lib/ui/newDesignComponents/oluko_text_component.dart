import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoTextComponent extends StatefulWidget {
  final String textContent;
  final EdgeInsetsGeometry elementPadding;
  final TextStyle textStyle;
  final TextAlign textAlignment;
  const OlukoTextComponent({Key key, this.textContent, this.textStyle, this.elementPadding, this.textAlignment}) : super(key: key);

  @override
  State<OlukoTextComponent> createState() => _OlukoTextComponentState();
}

class _OlukoTextComponentState extends State<OlukoTextComponent> {
  final String titleContent = 'New title';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.elementPadding ?? EdgeInsets.zero,
      child: Text(
        widget.textContent ?? titleContent,
        style: widget.textStyle ?? OlukoFonts.olukoMediumFont(),
        textAlign: widget.textAlignment ?? TextAlign.start,
      ),
    );
  }
}
