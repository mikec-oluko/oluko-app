import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/course_category_item.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/models/tag.dart';
import 'package:oluko_app/ui/components/filter_selector.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/components/search_results_grid.dart';
import 'package:oluko_app/ui/components/search_suggestions.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class MovementUtils {
  static movementTitle(String title) {
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

  static workout(List<String> workouts) {
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

  static movementDialog(BuildContext context, List<Widget> content) {
    showDialog(
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
                      print('wow');
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
