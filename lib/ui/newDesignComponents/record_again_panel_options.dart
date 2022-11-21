import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class RecordAgainPanelOptions extends StatefulWidget {
  final Function() recordAgainActions;
  final Function() cancelRecordAction;
  const RecordAgainPanelOptions({Key key, this.recordAgainActions, this.cancelRecordAction}) : super(key: key);

  @override
  State<RecordAgainPanelOptions> createState() => _RecordAgainPanelOptionsState();
}

class _RecordAgainPanelOptionsState extends State<RecordAgainPanelOptions> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(children: [
          Padding(padding: const EdgeInsets.only(bottom: 15.0), child: TitleBody(OlukoLocalizations.get(context, 'recordAgainQuestion'), bold: true)),
          Text(OlukoLocalizations.get(context, 'recordAgainWarning'), textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont()),
          Padding(
              padding: const EdgeInsets.only(top: OlukoNeumorphism.isNeumorphismDesign ? 80 : 25.0),
              child: Row(
                mainAxisAlignment: OlukoNeumorphism.isNeumorphismDesign ? MainAxisAlignment.end : MainAxisAlignment.center,
                children: [
                  if (OlukoNeumorphism.isNeumorphismDesign)
                    TextButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          OlukoLocalizations.get(context, 'yes'),
                          style: OlukoFonts.olukoBigFont(),
                        ),
                      ),
                      onPressed: () {
                        widget.recordAgainActions();
                      },
                    )
                  else
                    OlukoPrimaryButton(
                      title: OlukoLocalizations.get(context, 'no'),
                      onPressed: () {
                        widget.cancelRecordAction();
                      },
                    ),
                  const SizedBox(width: 20),
                  if (OlukoNeumorphism.isNeumorphismDesign)
                    Container(
                      width: 80,
                      height: 50,
                      child: OlukoNeumorphicPrimaryButton(
                        thinPadding: true,
                        isExpanded: false,
                        title: OlukoLocalizations.get(context, 'no'),
                        onPressed: () {
                          widget.cancelRecordAction();
                        },
                      ),
                    )
                  else
                    OlukoOutlinedButton(
                      title: OlukoLocalizations.get(context, 'yes'),
                      onPressed: () {
                        widget.recordAgainActions();
                      },
                    ),
                ],
              ))
        ]));
  }
}
