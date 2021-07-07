import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar_with_image.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';

class MovementDetail extends StatefulWidget {
  MovementDetail({Key key}) : super(key: key);

  @override
  _MovementDetailState createState() => _MovementDetailState();
}

class _MovementDetailState extends State<MovementDetail> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return form();
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: OlukoImageBar(actions: [
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 35,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              )
            ]),
            bottomNavigationBar: Row(
              mainAxisSize: MainAxisSize.max,
              children: [OlukoPrimaryButton(
                  color: OlukoColors.white,
                  title: 'START WORKOUTS',
                  onPressed: () {},
                ),
              ],
            ),
            body: Container(
                color: Colors.black,
                child: ListView(children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                          width: MediaQuery.of(context).size.width,
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, bottom: 10, right: 10),
                                  child: Text(
                                    "Each round is considered to be compleated once all the workouts are finished.",
                                    style: OlukoFonts.olukoBigFont(
                                        custoFontWeight: FontWeight.normal,
                                        customColor: OlukoColors.white),
                                  ),
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
                                SizedBox(
                                  height: 100,
                                )
                              ])))
                ]))));
  }
}
