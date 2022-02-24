import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/ui/components/custom_keyboard.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

import '../models/timer_entry.dart';

class SegmentClocksUtils {

  static List<Widget> getScoresByRound(
      BuildContext context, List<TimerEntry> timerEntries, int timerTaskIndex, int totalScore, List<String> scores) {
    List<String> lbls = counterText(
        context, timerEntries[timerEntries[timerTaskIndex - 1].movement.isRestTime ? timerTaskIndex : timerTaskIndex - 1].counter, timerEntries[timerTaskIndex - 1].movement.name);
    final bool isCounterByReps = timerEntries[timerTaskIndex - 1].counter == CounterEnum.reps;
    final List<Widget> widgets = [];
    String totalText = '${OlukoLocalizations.get(context, 'total')}: $totalScore ';
    if (!lbls.isEmpty) {
      totalText += lbls[1];
    }

    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(totalText, style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.w600, customColor: OlukoColors.primary)),
        ],
      ),
    );

    widgets.add(const SizedBox(height: 15));
    for (int i = 0; i < scores.length; i++) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${OlukoLocalizations.get(context, 'round')} ${i + 1}',
                style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w600, customColor: OlukoColors.white),
              ),
              SizedBox(
                width: ScreenUtils.width(context) * 0.5,
                child: Text(
                  scores[i],
                  textAlign: TextAlign.end,
                  style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400, customColor: OlukoColors.white),
                ),
              )
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  static List<String> counterText(BuildContext context, CounterEnum counter, String movementName) {
    List<String> counterText = [];
    switch (counter) {
      case CounterEnum.reps:
        counterText.add(OlukoLocalizations.get(context, 'enterScore'));
        counterText.add(movementName);
        break;
      case CounterEnum.distance:
        counterText.add(OlukoLocalizations.get(context, 'enterScore'));
        counterText.add(OlukoLocalizations.get(context, 'meters'));
        break;
      case CounterEnum.weight:
        counterText.add(OlukoLocalizations.get(context, 'enterWeight'));
        counterText.add(OlukoLocalizations.get(context, 'lbs'));
        break;
      default:
    }
    return counterText;
  }

  static Widget getKeyboard(BuildContext context, bool keyboardVisibilty) {
    const boxDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xff2b2f35), Color(0xff16171b)],
      ),
    );
    return SizedBox(
      width: ScreenUtils.width(context),
      child: Visibility(
        visible: keyboardVisibilty,
        child: CustomKeyboard(
          boxDecoration: boxDecoration,
        ),
      ),
    );
  }
}
