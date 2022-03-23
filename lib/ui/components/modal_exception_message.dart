import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/oluko_exception_message.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';

class ModalExceptionMessage extends StatefulWidget {
  final ExceptionTypeEnum exceptionType;
  final ExceptionTypeSourceEnum exceptionSource;
  final Function() onPress;
  const ModalExceptionMessage({@required this.exceptionType, @required this.onPress, this.exceptionSource}) : super();

  @override
  State<ModalExceptionMessage> createState() => _ModalExceptionMessageState();
}

class _ModalExceptionMessageState extends State<ModalExceptionMessage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: OlukoNeumorphism.isNeumorphismDesign
            ? BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
            : BorderRadius.zero,
        color: OlukoNeumorphismColors.appBackgroundColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              color: OlukoNeumorphismColors.appBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                    OlukoExceptionMessage.getExceptionMessage(
                        exceptionType: widget.exceptionType, exceptionSource: widget.exceptionSource, context: context),
                    style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor)),
              )),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Container(
                    width: 80,
                    height: 50,
                    child: OlukoNeumorphicPrimaryButton(title: 'Ok', onPressed: () => widget.onPress(), isExpanded: false)),
              )
            ],
          )
        ],
      ),
    );
  }
}
