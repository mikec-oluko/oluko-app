import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/segment_type_enum.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/models/timer_entry.dart';
import 'package:oluko_app/ui/newDesignComponents/movement_items_bubbles_neumorphic.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

import 'oluko_localizations.dart';

class SegmentSubmodelUtils {
  static bool isAMRAPforSubmodel(SegmentSubmodel segment) {
    if (segment != null && segment.totalTime != null) {
      if (segment.type != null) {
        return segment.type == SegmentTypeEnum.Duration;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static bool isEMOMforSubmodel(SegmentSubmodel segment) {
    if (segment != null && segment.rounds != null && segment.totalTime != null) {
      if (segment.sections != null && segment.type != null) {
        return segment.sections.length == 1 && segment.type == SegmentTypeEnum.RoundsAndDuration;
      } else {
        return false;
      }
    }
    return false;
  }

  static Widget getRoundTitle(SegmentSubmodel segmentSubmodel, BuildContext context, Color color) {
    if (isEMOMforSubmodel(segmentSubmodel)) {
      return Text(
        "EMOM: ${segmentSubmodel.rounds} ${OlukoLocalizations.get(context, 'rounds')} ${OlukoLocalizations.get(context, 'in')} ${TimeConverter.secondsToMinutes(segmentSubmodel.totalTime.toDouble())}",
        style: OlukoFonts.olukoBigFont(customColor: color, customFontWeight: FontWeight.bold),
      );
    } else if (isAMRAPforSubmodel(segmentSubmodel)) {
      return Text(
        '${TimeConverter.secondsToMinutes(segmentSubmodel.totalTime.toDouble())} AMRAP',
        style: OlukoFonts.olukoBigFont(customColor: color, customFontWeight: FontWeight.bold),
      );
    } else {
      return (segmentSubmodel.rounds != null && segmentSubmodel.rounds > 1)
          ? Text(
              "${segmentSubmodel.rounds} ${OlukoLocalizations.get(context, 'rounds')}",
              style: OlukoFonts.olukoBigFont(customColor: color, customFontWeight: FontWeight.bold),
            )
          : SizedBox();
    }
  }
}
