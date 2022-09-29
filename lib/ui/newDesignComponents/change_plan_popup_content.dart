import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ChangePlanPopUpContent extends StatefulWidget {
  const ChangePlanPopUpContent({Key key, this.primaryPress, this.isPlanCanceled = false}) : super(key: key);
  final Function() primaryPress;
  final bool isPlanCanceled;

  @override
  State<ChangePlanPopUpContent> createState() => _ChangePlanPopUpContentState();
}

class _ChangePlanPopUpContentState extends State<ChangePlanPopUpContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TitleBody(OlukoLocalizations.get(context, 'attention'), bold: true),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(OlukoLocalizations.get(context, widget.isPlanCanceled ? 'planCanceledAlertMessage' : 'planChangedAlertMessage'),
                  textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (OlukoNeumorphism.isNeumorphismDesign)
                  Container(
                    width: 80,
                    height: 50,
                    child: OlukoNeumorphicPrimaryButton(
                      title: OlukoLocalizations.get(context, 'ok'),
                      isExpanded: false,
                      onPressed: () {
                        widget.primaryPress();
                        Navigator.pop(context);
                      },
                    ),
                  )
                else
                  OlukoPrimaryButton(
                    title: OlukoLocalizations.get(context, 'ok'),
                    onPressed: () {
                      widget.primaryPress();
                      Navigator.pop(context);
                    },
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
