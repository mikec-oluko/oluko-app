import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

import '../../../routes.dart';

class AssessmentNeumorphicDoneScreen extends StatelessWidget {
  const AssessmentNeumorphicDoneScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context),
        color: OlukoNeumorphismColors.appBackgroundColor,
        child: Center(
          child: Container(
            width: ScreenUtils.width(context),
            height: ScreenUtils.height(context) / 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Neumorphic(
                      style: NeumorphicStyle(
                          depth: 3,
                          intensity: 0.5,
                          color: OlukoColors.primary,
                          shape: NeumorphicShape.convex,
                          lightSource: LightSource.topLeft,
                          boxShape: NeumorphicBoxShape.circle(),
                          shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
                          shadowLightColorEmboss: OlukoColors.black,
                          surfaceIntensity: 1,
                          shadowLightColor: OlukoColors.grayColor,
                          shadowDarkColor: OlukoColors.black),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Center(
                          child: Image.asset(
                            'assets/assessment/check.png',
                            color: Colors.white,
                            scale: 1,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Text(OlukoLocalizations.get(context, 'done!'),
                          style: OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        OlukoLocalizations.get(context, 'assessmentMessagePart1'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text(
                        OlukoLocalizations.get(context, 'assessmentMessagePart2'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ScreenUtils.height(context) / 2.5,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 80,
                      child: OlukoNeumorphicPrimaryButton(
                        thinPadding: true,
                        isExpanded: false,
                        title: OlukoLocalizations.get(context, 'ok'),
                        onPressed: () {
                          return AppNavigator().returnToHome(context);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.popAndPushNamed(context, routeLabels[RouteEnum.assessmentVideos],
                              arguments: {'isFirstTime': false, 'isForCoachPage': false});
                        },
                        child: Text(
                          'Go back to assessments',
                          textAlign: TextAlign.center,
                          style: OlukoFonts.olukoBigFont(
                            customColor: OlukoColors.grayColor.withOpacity(0.7),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
