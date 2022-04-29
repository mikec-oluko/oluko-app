import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class OlukoNoInternetConectionComponent extends StatefulWidget {
  final NoInternetContentEnum contentFor;
  const OlukoNoInternetConectionComponent({@required this.contentFor}) : super();

  @override
  State<OlukoNoInternetConectionComponent> createState() => _OlukoNoInternetConectionComponentState();
}

class _OlukoNoInternetConectionComponentState extends State<OlukoNoInternetConectionComponent> {
  final GlobalService _globalService = GlobalService();

  Widget _widgetToReturn = SizedBox.shrink();
  @override
  Widget build(BuildContext context) {
    switch (widget.contentFor) {
      case NoInternetContentEnum.fullscreen:
        _widgetToReturn = Scaffold(
          body: Container(
            width: ScreenUtils.width(context),
            height: ScreenUtils.height(context),
            color: OlukoNeumorphismColors.appBackgroundColor,
            child: Center(
              child: Container(
                width: ScreenUtils.width(context),
                height: ScreenUtils.height(context) / 1.2,
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Column(children: [
                    Neumorphic(
                      style: const NeumorphicStyle(
                          depth: 3,
                          intensity: 0.5,
                          color: OlukoColors.primary,
                          shape: NeumorphicShape.convex,
                          lightSource: LightSource.topLeft,
                          boxShape: NeumorphicBoxShape.circle(),
                          shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                          shadowLightColorEmboss: OlukoColors.black,
                          surfaceIntensity: 1,
                          shadowLightColor: OlukoColors.grayColor,
                          shadowDarkColor: Colors.black),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: const Center(
                            child: Icon(
                          Icons.priority_high_rounded,
                          color: OlukoColors.white,
                          size: 45,
                        )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        // OlukoLocalizations.get(context, 'assessmentMessagePart1'),
                        'No internet connection, please check...',
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: ScreenUtils.height(context) / 2.5,
                  ),
                  Container(
                    width: 80,
                    child: OlukoNeumorphicPrimaryButton(
                      isExpanded: false,
                      // title: OlukoLocalizations.get(context, 'retry'),
                      title: 'retry',
                      onPressed: () {
                        if (_globalService.hasInternetConnection) {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  ),
                ]),
              ),
            ),
          ),
        );
        break;
      case NoInternetContentEnum.widget:
        break;
      default:
    }
    return _widgetToReturn;
  }
}
