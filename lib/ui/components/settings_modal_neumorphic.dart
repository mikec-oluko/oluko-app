import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/app_validators.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsModalNeumorphic extends StatefulWidget {
  BuildContext profileViewContext;
  List<String> permissionsRequired;
  SettingsModalNeumorphic(this.profileViewContext, {Key key, this.permissionsRequired}) : super(key: key);

  @override
  _SettingsModalNeumorphicState createState() => _SettingsModalNeumorphicState();
}

class _SettingsModalNeumorphicState extends State<SettingsModalNeumorphic> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(25)), color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark),
      height: ScreenUtils.height(context) * 0.38,
      width: ScreenUtils.width(context),
      child: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 40),
        child: Column(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(padding: const EdgeInsets.only(bottom: 15.0), child: TitleBody(OlukoLocalizations.get(context, 'requiredPermitsTitle'), bold: true)),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(OlukoLocalizations.get(context, 'requiredPermitsBody'), style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor)),
          ),
          if (AppValidators.isNeitherNullNorEmpty(widget.permissionsRequired))
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: showPermissionsRequired(widget.permissionsRequired),
                )),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                child: Text(
                  OlukoLocalizations.get(context, 'ignore'),
                  style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
                ),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 30),
              SizedBox(
                width: 100,
                height: 50,
                child: OlukoNeumorphicPrimaryButton(
                  thinPadding: true,
                  isExpanded: false,
                  title: OlukoLocalizations.get(context, 'settings'),
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                ),
              ),
            ],
          )
        ]),
      ),
    );
  }

  Column showPermissionsRequired(List<String> permissions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: permissions
          .map((permission) => Row(
                children: [
                  bulletPoint(),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Text(OlukoLocalizations.get(context, permission),
                        textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor)),
                  ),
                ],
              ))
          .toList(),
    );
  }

  Widget bulletPoint() => Container(
        height: 5.0,
        width: 5.0,
        decoration: const BoxDecoration(
          color: OlukoColors.grayColor,
          shape: BoxShape.circle,
        ),
      );
}
