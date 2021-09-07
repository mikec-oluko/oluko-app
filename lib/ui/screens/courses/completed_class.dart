import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/time_converter.dart';

class CompletedClass extends StatefulWidget {
  final CourseEnrollment courseEnrollment;
  final int classIndex;

  CompletedClass({Key key, this.courseEnrollment, this.classIndex})
      : super(key: key);

  @override
  _CompletedClassState createState() => _CompletedClassState();
}

class _CompletedClassState extends State<CompletedClass> {
  User _user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.firebaseUser;
        return form();
      } else {
        return SizedBox();
      }
    });
  }

  form() {
    return Scaffold(
        appBar: OlukoAppBar(
          showDivider: false,
          title: ' ',
          actions: [],
        ),
        backgroundColor: Colors.black,
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(children: [
              getClassCard(),
              SizedBox(height: 20),
              getCompletedSegments(),
              getPhotoFrame(),
              SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: Row(mainAxisSize: MainAxisSize.max, children: [
                    OlukoPrimaryButton(
                        title: OlukoLocalizations.of(context).find('done'),
                        onPressed: () {})
                  ])),
              SizedBox(height: 20),
            ])));
  }

  Widget getPhotoFrame() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Stack(alignment: Alignment.center, children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 30, left: 10),
                child: RotationTransition(
                    turns: AlwaysStoppedAnimation(-0.01),
                    child: Container(
                      height: 153,
                      width: 153,
                      decoration: BoxDecoration(
                        image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: new AssetImage(
                              'assets/assessment/task_response_thumbnail.png'),
                        ),
                      ),
                    ))),
            Image.asset(
              'assets/courses/empty_frame.png',
              scale: 3,
            )
          ]),
          Padding(
              padding: const EdgeInsets.only(bottom: 33, left: 18),
              child: RotationTransition(
                  turns: AlwaysStoppedAnimation(-0.01),
                  child: Text(
                    'Add Your Selfie...',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: OlukoColors.black),
                    textAlign: TextAlign.start,
                  ))),
        ]));
  }

  Widget getClassCard() {
    return Container(
      height: 210,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: OlukoColors.listGrayColor),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, bottom: 13, top: 17),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 174,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: OlukoColors.challengeLockedFilterColor,
                      image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: new NetworkImage(widget
                            .courseEnrollment.classes[widget.classIndex].image),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 0),
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.courseEnrollment.classes[widget.classIndex]
                                .name,
                            style: OlukoFonts.olukoBigFont(
                                custoFontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: 11),
                          Text(
                            TimeConverter.toClassProgress(
                                widget.classIndex,
                                widget.courseEnrollment.classes.length,
                                context),
                            style: OlukoFonts.olukoMediumFont(
                                custoFontWeight: FontWeight.normal,
                                customColor: OlukoColors.white),
                          ),
                          Image.asset(
                            'assets/courses/completed_logo.png',
                            scale: 7,
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCompletedSegments() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: getSegments()));
  }

  List<Widget> getSegments() {
    List<Widget> segments = [];
    widget.courseEnrollment.classes[widget.classIndex].segments
        .forEach((segment) {
      segments.add(Row(children: [
        Image.asset(
          'assets/self_recording/completed_tick.png',
          scale: 2.5,
        ),
        SizedBox(width: 10),
        Text(
          segment.name,
          style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.bold),
          textAlign: TextAlign.start,
        ),
      ]));
      segments.add(SizedBox(height: 5));
    });
    return segments;
  }
}
