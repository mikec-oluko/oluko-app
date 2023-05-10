import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class DialogUtils {
  static Future<dynamic> getDialog(BuildContext context, List<Widget> content,
      {bool showExitButton = true, bool showExitButtonOutside = false, bool showBackgroundColor = false}) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
            backgroundColor: showBackgroundColor ? OlukoColors.black : Colors.transparent,
            content: showExitButtonOutside
                ? Column(
                    children: [
                      Row(children: [const Expanded(child: SizedBox()), _closeButton(context, color: OlukoColors.primary)]),
                      _dialogContent(context, content, showExitButton)
                    ],
                  )
                : _dialogContent(context, content, showExitButton)));
  }

  static Widget _dialogContent(BuildContext context, List<Widget> content, bool showExitButton) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: content,
        ),
        showExitButton ? Positioned(top: -15, right: 0, child: _closeButton(context)) : SizedBox(),
      ],
    );
  }

  static Widget _closeButton(BuildContext context, {Color color = Colors.white}) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(
        Icons.close,
        color: color,
      ),
    );
  }
}
