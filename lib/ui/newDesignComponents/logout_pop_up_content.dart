import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class LogoutPopUpContent extends StatefulWidget {
  final Function() acceptAction;
  final Function() cancelAction;
  const LogoutPopUpContent({@required this.acceptAction, @required this.cancelAction}) : super();

  @override
  State<LogoutPopUpContent> createState() => _LogoutPopUpContentState();
}

class _LogoutPopUpContentState extends State<LogoutPopUpContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 120,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              OlukoLocalizations.get(context, 'logoutPopUpMessage'),
              style: OlukoFonts.olukoBigFont(),
            ),
            Row(
              children: [
                OlukoNeumorphicPrimaryButton(
                    title: OlukoLocalizations.get(context, 'yes'),
                    onPressed: () {
                      widget.acceptAction();
                    }),
                SizedBox(
                  width: 10,
                ),
                OlukoNeumorphicSecondaryButton(
                    title: OlukoLocalizations.get(context, 'cancel'),
                    onPressed: () {
                      widget.cancelAction();
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
