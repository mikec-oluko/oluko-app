import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/black_app_bar_with_image.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class MovementDetail extends StatefulWidget {
  MovementDetail({Key key}) : super(key: key);

  @override
  _MovementDetailState createState() => _MovementDetailState();
}

class _MovementDetailState extends State<MovementDetail> {
  final _formKey = GlobalKey<FormState>();
  final toolbarHeight = kToolbarHeight * 2;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoImageBar(),
      backgroundColor: Colors.black,
      body: Container(
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context) - kToolbarHeight * 2,
        child: _viewBody(),
      ),
    );
  }

  _viewBody() {
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
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Text(
                            "Intense Airsquat",
                            style: OlukoFonts.olukoTitleFont(
                                custoFontWeight: FontWeight.bold),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Text(
                            "Description:",
                            style: OlukoFonts.olukoBigFont(
                                custoFontWeight: FontWeight.bold),
                          )),
                      Column(
                        children: [
                          Text(
                            "Each round is considered to be compleated once all the workouts are finished.",
                            style: OlukoFonts.olukoBigFont(
                                custoFontWeight: FontWeight.normal,
                                customColor: OlukoColors.white),
                          ),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Text(
                            "Workouts:",
                            style: OlukoFonts.olukoBigFont(
                                custoFontWeight: FontWeight.bold),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10, right: 10),
                        child: Text(
                          "8 Rounds.\n• 30 sec airsquads\n• 30 sec rest",
                          style: OlukoFonts.olukoBigFont(
                              custoFontWeight: FontWeight.normal,
                              customColor: OlukoColors.white),
                        ),
                      ),
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
                        child: Text('COACH RECOMMENDED'),
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
                        'Start video recording & workout together',
                        style: OlukoFonts.olukoMediumFont(),
                      ),
                    ),
                    Checkbox(
                        value: false,
                        onChanged: (bool value) {},
                        fillColor: MaterialStateProperty.all(Colors.white)),
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
                      'Segment 1/4',
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
        Row(children: [
          OlukoPrimaryButton(title: 'START WORKOUTS', color: Colors.white)
        ])
      ],
    );
  }
}
