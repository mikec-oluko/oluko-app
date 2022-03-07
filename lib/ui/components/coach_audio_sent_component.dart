import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class CoachAudioSentComponent extends StatefulWidget {
  final List<String> records;
  final String record;
  const CoachAudioSentComponent({Key key, this.records, this.record}) : super(key: key);

  @override
  State<CoachAudioSentComponent> createState() => _CoachAudioSentComponentState();
}

class _CoachAudioSentComponentState extends State<CoachAudioSentComponent> {
  int _totalDuration;
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
    const defaultDateString = '10:00AM 22jul, 2022';
    const defaultDurationString = '0:50';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Neumorphic(
        style: OlukoNeumorphism.getNeumorphicStyleForCircleElementNegativeDepth()
            .copyWith(boxShape: NeumorphicBoxShape.roundRect(const BorderRadius.all(Radius.circular(10)))),
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
                          child: Image.asset(
                            'assets/assessment/play.png',
                            scale: 3.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Image.asset(
                            'assets/courses/coach_audio.png',
                            width: 150,
                            fit: BoxFit.fill,
                            scale: 5,
                            color: OlukoColors.grayColor,
                          ),
                        ),
                        const VerticalDivider(color: OlukoColors.grayColor),
                        Image.asset('assets/courses/coach_delete.png', scale: 5, color: OlukoColors.grayColor),
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
                      defaultDurationString,
                      style: OlukoFonts.olukoSmallFont(
                          customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.listGrayColor : OlukoColors.white,
                          custoFontWeight: FontWeight.w500),
                    ),
                    const SizedBox(),
                    Row(
                      children: [
                        Text(
                          defaultDateString,
                          style: OlukoFonts.olukoSmallFont(
                              customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.listGrayColor : OlukoColors.white,
                              custoFontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/courses/coach_tick.png',
                          scale: 5,
                          color: OlukoColors.grayColor,
                        ),
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
      audioPlayer.onDurationChanged.listen((duration) {
        setState(() {
          _totalDuration = duration.inMicroseconds;
        });
      });

      audioPlayer.onAudioPositionChanged.listen((duration) {
        setState(() {
          _currentDuration = duration.inMicroseconds;
          _completedPercentage = _currentDuration.toDouble() / _totalDuration.toDouble();
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
