import 'package:flutter/material.dart';

class BottomDialogUtils {
  
  static showBottomDialog(
      {BuildContext context, Widget content}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext _) {
          return content;
        });
  }
 
}
