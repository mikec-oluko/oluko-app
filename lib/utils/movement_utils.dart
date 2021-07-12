import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';

class MovementUtils {
  static Text movementTitle(String title) {
    return Text(
      title,
      style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
    );
  }

  static description(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description:",
          style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.bold),
        ),
        Text(
          description,
          style: OlukoFonts.olukoBigFont(
              custoFontWeight: FontWeight.normal,
              customColor: OlukoColors.white),
        ),
      ],
    );
  }

  static Column workout(List<String> workouts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Workouts:",
          style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.bold),
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              return Text(
                '• ${workouts[index]}',
                style: OlukoFonts.olukoBigFont(),
              );
            })
      ],
    );
  }

  static Column labelWithTitle(String title, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: OlukoFonts.olukoBigFont(),
        )
      ],
    );
  }

  static Future<dynamic> movementDialog(
      BuildContext context, List<Widget> content) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
          backgroundColor: Colors.black,
          content: Stack(
            children: [
              Positioned(
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
                  )),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: content,
              ),
            ],
          )),
    );
  }
}
