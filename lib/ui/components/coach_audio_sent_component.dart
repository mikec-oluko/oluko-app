import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_audio_message.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/utils/time_converter.dart';

class CoachAudioSentComponent extends StatefulWidget {
  final String record;
  final bool isPreviewContent;
  final Function() onDelete;
  final CoachAudioMessage audioMessageItem;
  const CoachAudioSentComponent({Key key, this.record, this.isPreviewContent = false, this.onDelete, this.audioMessageItem})
      : super(key: key);

  @override
  State<CoachAudioSentComponent> createState() => _CoachAudioSentComponentState();
}

class _CoachAudioSentComponentState extends State<CoachAudioSentComponent> {
  Duration _totalDuration;
  int _currentDuration;
  double _completedPercentage = 0.0;
  bool _isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  bool playedOnce = false;

  @override
  Widget build(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign ? neumorphicCoachAudioComponent(context) : defaultAudioSent(context);
  }

  Padding neumorphicCoachAudioComponent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Neumorphic(
        style: OlukoNeumorphism.getNeumorphicStyleForCircleElementNegativeDepth().copyWith(
          boxShape: NeumorphicBoxShape.roundRect(const BorderRadius.all(Radius.circular(10))),
          border: NeumorphicBorder(
              width: 3,
              color: widget.isPreviewContent
                  ? OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth
                  : OlukoNeumorphismColors.olukoNeumorphicBackgroundDark),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoColors.black),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () => _onPlay(filePath: widget.record),
                          child: Neumorphic(
                            style: OlukoNeumorphism.getNeumorphicStyleForCirclePrimaryColor(),
                            child: Image.asset(
                              !_isPlaying ? 'assets/assessment/play_triangle.png' : 'assets/assessment/pause.png',
                              width: 45,
                              height: 45,
                              scale: 1,
                              color: OlukoColors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(width: 200, child: CourseProgressBar(value: _completedPercentage)),
                        ),
                        const VerticalDivider(color: OlukoColors.grayColor),
                        GestureDetector(
                            onTap: () => widget.onDelete(),
                            child: Image.asset('assets/courses/coach_delete.png', scale: 5, color: OlukoColors.grayColor)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(),
                    Text(
                      _totalDuration != null ? TimeConverter.durationToString(_totalDuration) : '',
                      style: OlukoFonts.olukoSmallFont(
                          customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.listGrayColor : OlukoColors.white,
                          custoFontWeight: FontWeight.w500),
                    ),
                    const SizedBox(),
                    Row(
                      children: [
                        Text(
                          TimeConverter.getDateAndTimeOnStringFormat(
                              dateToFormat: widget.audioMessageItem != null ? widget.audioMessageItem.createdAt : Timestamp.now(),
                              context: context),
                          style: OlukoFonts.olukoSmallFont(
                              customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.listGrayColor : OlukoColors.white,
                              custoFontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 10),
                        !widget.isPreviewContent
                            ? Image.asset(
                                'assets/courses/coach_tick.png',
                                scale: 5,
                                color:
                                    widget.audioMessageItem.seenAt != null ? OlukoColors.skyblue : OlukoColors.grayColor.withOpacity(0.5),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container defaultAudioSent(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _onPlay(filePath: widget.record),
                    child: Image.asset(
                      'assets/assessment/play.png',
                      scale: 5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Image.asset(
                      'assets/courses/coach_audio.png',
                      width: 150,
                      fit: BoxFit.fill,
                      scale: 5,
                    ),
                  ),
                ],
              ),
              const VerticalDivider(color: OlukoColors.grayColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/courses/coach_delete.png',
                      scale: 5,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      'assets/courses/coach_tick.png',
                      scale: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onPlay({String filePath}) async {
    if (!_isPlaying) {
      if (playedOnce) {
        await audioPlayer.resume();
      } else {
        await audioPlayer.play(filePath, isLocal: true);
        setState(() {
          playedOnce = true;
        });
      }

      setState(() {
        _completedPercentage = 0.0;
        _isPlaying = true;
      });

      audioPlayer.onPlayerCompletion.listen((_) {
        setState(() {
          _isPlaying = false;
          _completedPercentage = 0.0;
          playedOnce = false;
        });
      });
      audioPlayer.onDurationChanged.listen((Duration duration) {
        setState(() {
          _totalDuration = duration;
        });
      });

      audioPlayer.onAudioPositionChanged.listen((duration) {
        setState(() {
          _currentDuration = duration.inMicroseconds;
          _completedPercentage = _currentDuration.toDouble() / _totalDuration.inMicroseconds.toDouble();
        });
      });
    } else {
      await audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }
}
