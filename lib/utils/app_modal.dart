import 'package:flutter/material.dart';
import 'package:mvt_fitness/ui/components/dialog.dart';

class AppModal {
  //Function handler Dialog/Modal
  static dialogContent(
      {BuildContext context,
      List<Widget> content,
      dynamic valueToReturn,
      bool closeButton = false}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext _) {
          if (closeButton == true) {
            content.insert(
                0,
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: 20,
                    child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                  ),
                ));
          }

          return DialogWidget(content: content);
        }).whenComplete(() {
      return valueToReturn;
    });
  }
}
