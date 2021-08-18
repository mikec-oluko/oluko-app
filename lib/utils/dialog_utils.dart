import 'package:flutter/material.dart';

class DialogUtils {
  static Future<dynamic> getDialog(
      BuildContext context, List<Widget> content,
      {bool showExitButton = true}) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
          backgroundColor: Colors.black,
          content: Stack(
            children: [
              showExitButton
                  ? Positioned(
                      top: -15,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ))
                  : SizedBox(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: content,
              ),
            ],
          )),
    );
  }
}