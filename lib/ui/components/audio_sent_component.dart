import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_audio_message.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';


class AudioSentComponent extends StatefulWidget {
  final String record;
  final Duration durationFromRecord;
  final bool isPreviewContent;
  final Function() onDelete;
  final Function(bool isPlaying) onAudioPlaying;
  final bool Function() onStartPlaying;
  final CoachAudioMessage audioMessageItem;
  final bool isForList;
  final bool showBin;
  final bool showDate;
  final Function valueNotifier;

  const AudioSentComponent(
      {Key key,
      this.record,
      this.isPreviewContent = false,
      this.onDelete,
      this.audioMessageItem,
      this.durationFromRecord,
      this.onAudioPlaying,
      this.isForList = false,
      this.onStartPlaying,
      this.showBin = true,
      this.showDate = true,
      this.valueNotifier,})
      : super(key: key);

  @override
  State<AudioSentComponent> createState() => _AudioSentComponentState();
}

class _AudioSentComponentState extends State<AudioSentComponent> {
  Duration _totalDuration;
  int _currentDuration;
  double _completedPercentage = 0.0;
  bool _isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  bool playedOnce = false;

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  //Pause the audio playing on background, when widget is removed from Widget tree.
  void deactivate() {
    audioPlayer.pause();
    super.deactivate();
  }

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
              color: widget.isPreviewContent ? OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth : OlukoNeumorphismColors.olukoNeumorphicBackgroundDark),
        ),
        child: Container(
          width: widget.isForList ? ScreenUtils.width(context) : ScreenUtils.width(context) / 1.6,
          height: 80,
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoNeumorphismColors.appBackgroundColor),
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
                              width: 40,
                              height: 40,
                              scale: 1,
                              color: OlukoColors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Container(width: ScreenUtils.width(context) / 3, child: CourseProgressBar(value: _completedPercentage)),
                        ),
                        if (widget.showBin) ...[
                          const VerticalDivider(color: OlukoColors.grayColor),
                          GestureDetector(
                              onTap: () => widget.onDelete(), child: Image.asset('assets/courses/coach_delete.png', scale: 5, color: OlukoColors.grayColor)),
                        ]
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(),
                    Text(
                      _totalDuration != null
                          ? TimeConverter.durationToString(_totalDuration)
                          : widget.durationFromRecord != null
                              ? TimeConverter.durationToString(widget.durationFromRecord)
                              : '',
                      style: OlukoFonts.olukoSmallFont(
                          customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.listGrayColor : OlukoColors.white, customFontWeight: FontWeight.w500),
                    ),
                    const SizedBox(),
                    Row(
                      children: [
                        Text(
                          widget.isPreviewContent
                              ? TimeConverter.getDateAndTimeOnStringFormat(dateToFormat: Timestamp.now(), context: context)
                              : widget.audioMessageItem != null
                                  ? TimeConverter.getDateAndTimeOnStringFormat(dateToFormat: widget.audioMessageItem?.createdAt, context: context)
                                  : '',
                          style: OlukoFonts.olukoSmallFont(
                              customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.listGrayColor : OlukoColors.white,
                              customFontWeight: FontWeight.w500),
                        ),
                        // const SizedBox(width: 10),
                        if (!widget.isPreviewContent)
                          Image.asset(
                            'assets/courses/coach_tick.png',
                            scale: 5,
                            color: widget.audioMessageItem?.seenAt != null ? OlukoColors.skyblue : OlukoColors.grayColor.withOpacity(0.5),
                          )
                        else
                          const SizedBox.shrink(),
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

    if (!widget.onStartPlaying()) {
      if (playedOnce && audioPlayer.state == PlayerState.paused) {
        await audioPlayer.resume();
      } else {
        if (widget.isPreviewContent) {
          await audioPlayer.play(DeviceFileSource(filePath));
        } else {
          await audioPlayer.play(UrlSource(filePath));
        }
        setState(() {
          playedOnce = true;
        });
      }
      setState(() {
        _completedPercentage = 0.0;
        _isPlaying = true;
        widget.onAudioPlaying(_isPlaying);
      });

      audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          _isPlaying = false;
          widget.onAudioPlaying(_isPlaying);
          _completedPercentage = 0.0;
          playedOnce = false;
        });
      });
      audioPlayer.onDurationChanged.listen((Duration duration) {
        setState(() {
          _totalDuration = duration;
        });
      });

      audioPlayer.onPositionChanged.listen((duration) {
        setState(() {
          _currentDuration = duration.inMicroseconds;
          _completedPercentage = _currentDuration.toDouble() / _totalDuration.inMicroseconds.toDouble();
        });
      });
    } else {
      if (audioPlayer.state == PlayerState.playing) {
        await audioPlayer.pause();
        setState(() {
          _isPlaying = false;
          widget.onAudioPlaying(_isPlaying);
        });
      }
    
  }
  }
}
