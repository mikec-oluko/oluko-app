import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_audio_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_audio_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/screens/courses/audio_section.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class AudioPanel extends StatefulWidget {
  final List<UserResponse> coaches;
  final List<Audio> audios;
  final Function(int) onAudioPressed;
  final bool comesFromSegmentDetail;
  AudioPlayer audioPlayer;

  AudioPanel({this.comesFromSegmentDetail, this.coaches, this.audios, this.onAudioPressed, this.audioPlayer});

  @override
  _State createState() => _State();
}

class _State extends State<AudioPanel> {
  List<Widget> _audioWidgets = [];
  List<Audio> _audios = [];

  @override
  void initState() {
    _audios = widget.audios;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comesFromSegmentDetail != null && widget.comesFromSegmentDetail == true) {
      return BlocBuilder<ChallengeAudioBloc, ChallengeAudioState>(builder: (context, state) {
        if (state is DeleteChallengeAudioSuccess) {
          _audios = state.audios;
        }
        return getBody();
      });
    } else {
      return BlocBuilder<CourseEnrollmentAudioBloc, CourseEnrollmentAudioState>(builder: (context, state) {
        if (state is ClassAudioDeleteSuccess) {
          _audios = state.audios;
        }
        return getBody();
      });
    }
  }

  Widget getBody() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: OlukoNeumorphism.isNeumorphismDesign ? 10 : 25),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          gradient: OlukoNeumorphism.olukoNeumorphicGradientDark(),
        ),
        child: Column(crossAxisAlignment: OlukoNeumorphism.isNeumorphismDesign ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
          Center(
              child: Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: Image.asset(
                    'assets/courses/horizontal_vector.png',
                    scale: 3,
                  ))),
          Padding(
            padding: OlukoNeumorphism.isNeumorphismDesign ? EdgeInsets.only(top: 15, left: 15, bottom: 10) : EdgeInsets.only(top: 15, bottom: 5),
            child: Text(
              OlukoLocalizations.get(context, 'voiceMessages'),
              style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.white),
            ),
          ),
          Container(
              height: 360,
              child: ListView(addAutomaticKeepAlives: false, addRepaintBoundaries: false, key: ValueKey(_audios.length), children: getAudioWidgets(_audios)))
        ]));
  }

  List<Widget> getAudioWidgets(List<Audio> audios) {
    List<Widget> widgets = [];
    if (audios == null) {
      return widgets;
    }
    for (int i = 0; i < audios.length; i++) {
      widgets.add(AudioSection(
          showTopDivider: !OlukoNeumorphism.isNeumorphismDesign ? i != 0 : false,
          coach: widget.coaches == null ? null : widget.coaches[i],
          audio: audios[i],
          audioPlayer: widget.audioPlayer,
          onAudioPressed: () => widget.onAudioPressed(i)));
    }
    widgets.add(SizedBox(height: 20));
    return widgets;
  }
}
