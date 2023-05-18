import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class DialogUtils {
  static Future<dynamic> getDialog(BuildContext context, List<Widget> content, {bool showExitButton = true, bool useAppBackground = false}) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
          backgroundColor: useAppBackground ? OlukoNeumorphismColors.appBackgroundColor : OlukoColors.black,
          content: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: content,
              ),
              if (showExitButton)
                Positioned(
                    top: -15,
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ))
              else
                const SizedBox(),
            ],
          )),
    );
  }
}
