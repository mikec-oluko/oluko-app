import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/challenge/panel_audio_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_text_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DeleteAudioPanel extends StatefulWidget {
  final PanelController panelController;

  DeleteAudioPanel({this.panelController});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<DeleteAudioPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 32),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [OlukoNeumorphismColors.initialGradientColorDark, OlukoNeumorphismColors.finalGradientColorDark],
          ),
        ),
        child: Column(crossAxisAlignment: OlukoNeumorphism.isNeumorphismDesign ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
          SizedBox(height: !OlukoNeumorphism.isNeumorphismDesign ? 10 : 30),
          !OlukoNeumorphism.isNeumorphismDesign
              ? Icon(Icons.warning_amber_rounded, color: OlukoColors.coral, size: 100)
              : Text(
                  OlukoLocalizations.get(context, 'cancelVoiceMessage'),
                  style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white),
                ),
          SizedBox(height: !OlukoNeumorphism.isNeumorphismDesign ? 5 : 15),
          Text(OlukoLocalizations.get(context, 'deleteMessageConfirm'),
              textAlign: !OlukoNeumorphism.isNeumorphismDesign ? TextAlign.center : TextAlign.start,
              style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w400, customColor: OlukoColors.grayColor)),
          SizedBox(height: !OlukoNeumorphism.isNeumorphismDesign ? 25 : 40),
          Row(
            children: [
              Expanded(child: SizedBox()),
              !OlukoNeumorphism.isNeumorphismDesign
                  ? OlukoOutlinedButton(
                      title: OlukoLocalizations.get(context, 'no'),
                      onPressed: () {
                        widget.panelController.close();
                      },
                    )
                  : OlukoNeumorphicTextButton(
                      title: OlukoLocalizations.get(context, 'deny'),
                      onPressed: () {
                        widget.panelController.close();
                      }),
              !OlukoNeumorphism.isNeumorphismDesign
                  ? OlukoPrimaryButton(
                      title: OlukoLocalizations.get(context, 'yes'),
                      onPressed: () {
                        BlocProvider.of<PanelAudioBloc>(context).deleteAudio(false, true);
                        widget.panelController.close();
                      },
                    )
                  : OlukoNeumorphicPrimaryButton(
                      title: OlukoLocalizations.get(context, 'allow'),
                      onPressed: () {
                        BlocProvider.of<PanelAudioBloc>(context).deleteAudio(false, true);
                        widget.panelController.close();
                      })
            ],
          ),
        ]));
  }
}
