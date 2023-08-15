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

class _OlukoNoInternetConectionComponentState extends State<OlukoNoInternetConectionComponent> with TickerProviderStateMixin {
  final GlobalService _globalService = GlobalService();
  AnimationController _animationController;
  final Tween<double> _tween = Tween(begin: 1, end: 1.2);
  Widget _widgetToReturn = SizedBox.shrink();

  @override
  void initState() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _animate = _tween.animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));
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
                    ScaleTransition(
                      scale: _animate,
                      child: Neumorphic(
                        style: const NeumorphicStyle(
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
                          child: const Center(
                              child: Icon(
                            Icons.priority_high_rounded,
                            color: OlukoColors.white,
                            size: 45,
                          )),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: ScaleTransition(
                        scale: _animate,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                OlukoLocalizations.get(context, 'oopsMessage'),
                                textAlign: TextAlign.center,
                                style: OlukoFonts.olukoTitleFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              OlukoLocalizations.get(context, 'noInternetConnectionHeaderText'),
                              textAlign: TextAlign.center,
                              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
                            ),
                            Text(
                              OlukoLocalizations.get(context, 'noInternetConnectionBodyText'),
                              textAlign: TextAlign.center,
                              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: ScreenUtils.height(context) / 2.5,
                  ),
                  Container(
                    width: 100,
                    child: OlukoNeumorphicPrimaryButton(
                      isExpanded: false,
                      customHeight: 60,
                      title: OlukoLocalizations.get(context, 'retry'),
                      onPressed: () {
                        if (_globalService.hasInternetConnection) {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        } else {
                          _animationController.forward();
                          Future.delayed(const Duration(milliseconds: 700), () {
                            _animationController.reset();
                          });
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
