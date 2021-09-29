import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

class OpenSettingsModal extends StatefulWidget {
  BuildContext profileViewContext;
  OpenSettingsModal(this.profileViewContext, {Key key}) : super(key: key);

  @override
  _OpenSettingsModalState createState() => _OpenSettingsModalState();
}

class _OpenSettingsModalState extends State<OpenSettingsModal> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.only(bottom: 15.0), child: TitleBody(OlukoLocalizations.of(context).find('requiredPermitsTitle'), bold: true)),
      Text(OlukoLocalizations.of(context).find('requiredPermitsBody'), textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont()),
      Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Row(
            children: [
              OlukoPrimaryButton(
                thinPadding: true,
                title: OlukoLocalizations.of(context).find('ignore'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 10),
              OlukoOutlinedButton(
                thinPadding: true,
                title: OlukoLocalizations.of(context).find('settings'),
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
              ),
            ],
          ))
    ]);
  }
}