import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class CoachAudioSentComponent extends StatefulWidget {
  const CoachAudioSentComponent({Key key}) : super(key: key);

  @override
  State<CoachAudioSentComponent> createState() => _CoachAudioSentComponentState();
}

class _CoachAudioSentComponentState extends State<CoachAudioSentComponent> {
  @override
  Widget build(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign ? neumorphicCoachAudioComponent(context) : defaultAudioSent(context);
  }

  Padding neumorphicCoachAudioComponent(BuildContext context) {
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
                        Image.asset(
                          'assets/assessment/play.png',
                          scale: 3.5,
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
                      '0:50',
                      style: OlukoFonts.olukoSmallFont(
                          customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.listGrayColor : OlukoColors.white,
                          custoFontWeight: FontWeight.w500),
                    ),
                    const SizedBox(),
                    Row(
                      children: [
                        Text(
                          '10:00AM 22jul, 2022',
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
                  Image.asset(
                    'assets/assessment/play.png',
                    scale: 5,
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
}
