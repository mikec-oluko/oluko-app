import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/black_app_bar_with_image.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class MovementDetail extends StatefulWidget {
  MovementDetail({Key key}) : super(key: key);

  @override
  _MovementDetailState createState() => _MovementDetailState();
}

class _MovementDetailState extends State<MovementDetail> {
  final toolbarHeight = kToolbarHeight * 2;
  bool startRecordingAndWorkoutTogether = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoImageBar(actions: []),
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.94), BlendMode.darken),
                fit: BoxFit.cover,
                image: NetworkImage(
                    'https://c0.wallpaperflare.com/preview/26/779/700/fitness-men-sports-gym.jpg'))),
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context) - toolbarHeight,
        child: _viewBody(),
      ),
    );
  }

  Widget _viewBody() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MovementUtils.movementTitle("Intense Airsquat"),
                      SizedBox(height: 25),
                      MovementUtils.description(
                          "Each round is considered to be completed once all the workouts are finished."),
                      SizedBox(height: 25),
                      MovementUtils.workout(
                          ['30 sec airsquats', '30 sec rest']),
                    ],
                  ),
                )
              ]),
              _menuOptions()
            ]),
      ),
    );
  }

  _menuOptions() {
    return Column(
      children: [
        //Coach recommended section
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: OlukoColors.listGrayColor),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(OlukoLocalizations.of(context)
                            .find('coachRecommended')),
                      ))
                ]),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.videocam_outlined,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        OlukoLocalizations.of(context)
                            .find('startVideoAndWorkoutTogether'),
                        style: OlukoFonts.olukoMediumFont(),
                      ),
                    ),
                    Checkbox(
                      value: startRecordingAndWorkoutTogether,
                      onChanged: (bool value) {
                        this.setState(() {
                          startRecordingAndWorkoutTogether = value;
                        });
                      },
                      fillColor: MaterialStateProperty.all(Colors.white),
                      checkColor: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        //Segment section
        Container(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${OlukoLocalizations.of(context).find('segment')} 1/4',
                      style: OlukoFonts.olukoMediumFont(),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 15,
                      ),
                      Icon(
                        Icons.adjust,
                        color: Colors.white,
                        size: 15,
                      ),
                      Icon(
                        Icons.adjust,
                        color: Colors.white,
                        size: 15,
                      ),
                      Icon(
                        Icons.adjust,
                        color: Colors.white,
                        size: 15,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        //Submit button
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Row(children: [
            OlukoPrimaryButton(
              title: OlukoLocalizations.of(context).find('startWorkouts'),
              color: Colors.white,
              onPressed: () => MovementUtils.movementDialog(
                  context, _confirmDialogContent()),
            )
          ]),
        )
      ],
    );
  }

  _confirmDialogContent() {
    return [
      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
            OlukoLocalizations.of(context).find('coachRecommendsRecording'),
            textAlign: TextAlign.center,
            style: OlukoFonts.olukoBigFont()),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          children: [
            OlukoPrimaryButton(
              color: Colors.white,
              title:
                  OlukoLocalizations.of(context).find('recordAndStartSegment'),
            ),
          ],
        ),
      ),
      TextButton(
        onPressed: () {},
        child: Text(
          OlukoLocalizations.of(context).find('continueWithoutRecording'),
          style: OlukoFonts.olukoMediumFont(),
        ),
      )
    ];
  }
}
