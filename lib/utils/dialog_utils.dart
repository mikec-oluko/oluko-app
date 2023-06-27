import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class DialogUtils {
  static Future<dynamic> getDialog(BuildContext context, List<Widget> content,
      {bool showExitButton = true,
      bool showExitButtonOutside = false,
      bool showBackgroundColor = true,
      bool useAppBackground = false,
      bool addTopPadding = false,
      bool removeHorizontalPadding = false,
      Color closeIconColor = OlukoColors.white,
      bool addPaddingToCloseButton = false}) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: removeHorizontalPadding ? 0 : 40.0, vertical: 24.0),
            backgroundColor: showBackgroundColor
                ? useAppBackground
                    ? OlukoNeumorphismColors.appBackgroundColor
                    : OlukoColors.black
                : Colors.transparent,
            content: Padding(
                padding: EdgeInsets.only(top: addTopPadding ? 120 : 0),
                child: showExitButtonOutside
                    ? Column(
                        children: [
                          Row(children: [const Expanded(child: SizedBox()), _closeButton(context, color: OlukoColors.primary)]),
                          _dialogContent(context, content, showExitButton, closeIconColor)
                        ],
                      )
                    : _dialogContent(context, content, showExitButton, closeIconColor, addPaddingToCloseButton: addPaddingToCloseButton))));
  }

  static Widget _dialogContent(BuildContext context, List<Widget> content, bool showExitButton, Color closeIconColor, {bool addPaddingToCloseButton = false}) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: content,
        ),
        showExitButton
            ? Positioned(top: -15, right: 0, child: _closeButton(context, color: closeIconColor, addPaddingToCloseButton: addPaddingToCloseButton))
            : SizedBox(),
      ],
    );
  }

  static Widget _closeButton(BuildContext context, {Color color = Colors.white, bool addPaddingToCloseButton = false}) {
    return Padding(
        padding: EdgeInsets.only(top: addPaddingToCloseButton ? 15 : 0),
        child: IconButton(
          splashRadius: 5.0,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.close,
            color: color,
          ),
        ));
  }
}
