import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_audio_bloc.dart';
import 'package:oluko_app/ui/components/course_poster.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CourseInfoSection extends StatefulWidget {
  final int peopleQty;
  final int audioMessageQty;
  final String image;
  final bool isUserChallengeSection;
  final Function() onAudioPressed;
  final Function() onPeoplePressed;
  final Function() clockAction;

  CourseInfoSection(
      {this.peopleQty,
      this.audioMessageQty,
      this.image,
      this.onPeoplePressed,
      this.onAudioPressed,
      this.clockAction,
      this.isUserChallengeSection = false});

  @override
  _State createState() => _State();
}

class _State extends State<CourseInfoSection> {
  int _audioQty = 0;

  @override
  void initState() {
    _audioQty = widget.audioMessageQty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(padding: const EdgeInsets.only(left: 15), child: CoursePoster(image: widget.image)),
      widget.isUserChallengeSection ? _getButtons() : SizedBox(),
    ]);
  }

  Widget clockSection() {
    return Container(
      width: 60,
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Image.asset(
              'assets/courses/clock.png',
              height: 24,
              width: 27,
            )),
        const SizedBox(height: 5),
        Text(
          OlukoLocalizations.get(context, 'personalRecord'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
        )
      ]),
    );
  }

  Widget peopleSection() {
    return Column(children: [
      Text(
        widget.peopleQty != 0 ? '${widget.peopleQty}+' : '0',
        textAlign: TextAlign.center,
        style: OlukoNeumorphism.isNeumorphismDesign
            ? const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: OlukoColors.primary)
            : const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      const SizedBox(height: 5),
      Text(
        widget.isUserChallengeSection ? OlukoLocalizations.get(context, 'doneThis') : OlukoLocalizations.get(context, 'inThis'),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
      ),
      Text(
        widget.isUserChallengeSection
            ? OlukoLocalizations.get(context, 'challenge').toLowerCase()
            : OlukoLocalizations.get(context, 'course').toLowerCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
      )
    ]);
  }

  Widget audioSection(BuildContext context) {
    return GestureDetector(
        onTap: _audioQty > 0 ? widget.onAudioPressed : null,
        child: Stack(alignment: Alignment.topRight, children: [
          Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Image.asset(
                'assets/courses/audio.png',
                height: 50,
                width: 50,
              )),
          getAudioNotification(),
        ]));
  }

  Widget getAudioNotification() {
    return BlocBuilder<CourseEnrollmentAudioBloc, CourseEnrollmentAudioState>(builder: (context, state) {
      if (state is ClassAudioDeleteSuccess) {
        _audioQty = state.audios.length;
      }
      return _audioQty > 0
          ? Stack(alignment: Alignment.center, children: [
              Image.asset(
                'assets/courses/audio_notification.png',
                height: 22,
                width: 22,
              ),
              Text(
                _audioQty.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300, color: Colors.white),
              ),
            ])
          : SizedBox();
    });
  }

  Widget verticalDivider() {
    return Image.asset(
      'assets/courses/vertical_divider.png',
      height: 48,
      width: 48,
    );
  }

  Widget _getButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Column(
        children: [
          const SizedBox(height: 80),
          Row(
            children: [
              if (widget.peopleQty != null) GestureDetector(onTap: widget.onPeoplePressed, child: peopleSection()) else const SizedBox(),
              verticalDivider(),
              if (widget.onAudioPressed != null)
                GestureDetector(onTap: widget.onAudioPressed, child: audioSection(context))
              else
                const SizedBox(),
              if (widget.clockAction != null) GestureDetector(onTap: widget.clockAction, child: clockSection()) else const SizedBox(),
            ],
          )
        ],
      ),
    );
  }
}
