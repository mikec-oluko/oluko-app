import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';

import 'oluko_localizations.dart';

class MovementUtils {
  static Text movementTitle(String title) {
    return Text(
      title,
      style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
    );
  }

  static description(String description, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              OlukoLocalizations.of(context).find('description') + ":",
              style: OlukoFonts.olukoSuperBigFont(
                  custoFontWeight: FontWeight.bold),
            )),
        Text(
          description,
          style: OlukoFonts.olukoBigFont(
              custoFontWeight: FontWeight.normal,
              customColor: OlukoColors.white),
        ),
      ],
    );
  }

  static Column workout(Segment segment, BuildContext context) {
    List<String> workouts = getWorkouts(segment, context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              OlukoLocalizations.of(context).find('workouts') + ":",
              style: OlukoFonts.olukoSuperBigFont(
                  custoFontWeight: FontWeight.bold),
            )),
        segment.rounds != null
            ? Text(
                segment.rounds.toString() +
                    " " +
                    OlukoLocalizations.of(context).find('rounds') +
                    "\n",
                style: OlukoFonts.olukoMediumFont(),
              )
            : SizedBox(),
        ListView.builder(
            shrinkWrap: true,
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              return index % 4 == 0
                  ? Text(
                      workouts[index],
                      style: OlukoFonts.olukoMediumFont(),
                    )
                  : Text(
                      workouts[index],
                      style: OlukoFonts.olukoBigFont(),
                    );
            })
      ],
    );
  }

  static List<String> getWorkouts(Segment segment, BuildContext context) {
    List<String> workouts = [];
    String workout;
    segment.movements.forEach((MovementSubmodel movement) {
      workouts.add(movement.timerSets.toString() +
          " " +
          OlukoLocalizations.of(context).find('sets'));
      if (movement.timerReps != null) {
        workout =
            '• ' + movement.timerReps.toString() + ' rep ' + movement.name;
      } else {
        workout =
            '• ' + movement.timerWorkTime.toString() + ' sec ' + movement.name;
      }
      workouts.add(workout);
      workout = '• ' + movement.timerRestTime.toString() + ' sec rest';
      workouts.add(workout);
      workouts.add(' ');
    });
    return workouts;
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
