import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/recorded_view.dart';
import 'package:oluko_app/ui/components/recorder_view.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/courses/challenge_detail_section.dart';
import 'package:oluko_app/ui/screens/courses/course_info_section.dart';
import 'package:oluko_app/ui/screens/courses/segment_detail.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:path_provider/path_provider.dart';

enum PanelEnum { audios, classDetail }

class UserChallengeDetail extends StatefulWidget {
  final Challenge challenge;
  final UserResponse userRequested;

  UserChallengeDetail({this.challenge, this.userRequested, Key key})
      : super(key: key);

  @override
  _UserChallengeDetailState createState() => _UserChallengeDetailState();
}

class FirebaseUser {}

class _UserChallengeDetailState extends State<UserChallengeDetail> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  Class _class;
  Segment _segment;
  CourseEnrollment _courseEnrollment;
  PanelController panelController = new PanelController();
  UserResponse _user;

  Widget panelContent;
  PanelEnum panelState;

  //audio
  Directory appDirectory;
  List<String> records = [];
  String record;
  bool audioRecorded;

  @override
  void initState() {
    super.initState();
    audioRecorded = false;
    getApplicationDocumentsDirectory().then((value) {
      appDirectory = value;
      appDirectory.list().listen((onData) {
        if (onData.path.contains('.aac')) {
          records.add(onData.path);
          //record = onData.path;
        }
      }).onDone(() {
        //records = records.reversed.toList();
        record = records[records.length - 1];
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    appDirectory.delete();
    super.dispose();
  }

  _onRecordComplete() {
    records.clear();
    appDirectory.list().listen((onData) {
      if (onData.path.contains('.aac')) {
        records.add(onData.path);
        //record = onData.path;
      }
    }).onDone(() {
      records.sort();
      //records = records.reversed.toList();
      record = records[records.length - 1];
      audioRecorded = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.user;
        BlocProvider.of<ClassBloc>(context)..get(widget.challenge.classId);
        BlocProvider.of<CourseEnrollmentBloc>(context)
          ..getById(widget.challenge.courseEnrollmentId);
        BlocProvider.of<SegmentBloc>(context)
          ..getById(widget.challenge.segmentId);
        return BlocBuilder<ClassBloc, ClassState>(
            builder: (context, classState) {
          return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
              builder: (context, enrollmentState) {
            return BlocBuilder<SegmentBloc, SegmentState>(
                builder: (context, segmentState) {
              if (classState is GetByIdSuccess &&
                  enrollmentState is GetEnrollmentByIdSuccess &&
                  segmentState is GetSegmentSuccess) {
                _class = classState.classObj;
                _courseEnrollment = enrollmentState.courseEnrollment;
                _segment = segmentState.segment;
                return form();
              } else {
                return SizedBox();
              }
            });
          });
        });
      } else {
        return SizedBox();
      }
    });
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            body: SlidingUpPanel(
                controller: panelController,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                minHeight: 5,
                collapsed: Container(
                  color: Colors.black,
                ),
                panel: SizedBox(),
                body: Container(
                  color: Colors.black,
                  child: classInfoSection(),
                ))));
  }

  Widget audioRecordedSection() {
    return Container(
        height: 140,
        color: Colors.black,
        child: Column(children: [
          Divider(
            height: 1,
            color: OlukoColors.divider,
            thickness: 1.5,
            indent: 0,
            endIndent: 0,
          ),
          RecordedView(
            record: record,
            showTicks: false,
            binAction: () {
              setState(() {
                audioRecorded = false;
              });
            },
          ),
          _saveButton()
        ]));
  }

  Widget _saveButton() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            OlukoPrimaryButton(
              title: OlukoLocalizations.get(context, 'saveFor') +
                  widget.userRequested.firstName,
              onPressed: () {},
            ),
          ],
        ));
  }

  Widget audioRecorderSection() {
    return Container(
        height: 70,
        child: Column(children: [
          Divider(
            height: 1,
            color: OlukoColors.divider,
            thickness: 1.5,
            indent: 0,
            endIndent: 0,
          ),
          Padding(
              padding:
                  EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
              child: Row(children: [
                Text(
                  OlukoLocalizations.get(context, 'recordAMessage') +
                      widget.userRequested.firstName,
                  textAlign: TextAlign.left,
                  style: OlukoFonts.olukoBigFont(
                      custoFontWeight: FontWeight.normal),
                ),
                Expanded(child: SizedBox()),
                RecorderView(
                  onSaved: _onRecordComplete,
                )
              ]))
        ]));
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ScreenUtils.height(context) / 4
                    : ScreenUtils.height(context) / 1.5,
            minHeight:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ScreenUtils.height(context) / 4
                    : ScreenUtils.height(context) / 1.5),
        child: Container(height: 400, child: Stack(children: widgets)));
  }

  Widget classInfoSection() {
    return ListView(children: [
      Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Column(children: [
            OverlayVideoPreview(
                image: _segment.challengeImage,
                video: _segment.challengeVideo,
                showBackButton: true,
                bottomWidgets: [
                  CourseInfoSection(
                    peopleQty: 50,
                    image: _courseEnrollment.course.image,
                    clockAction: () {},
                  ),
                ]),
            ChallengeDetailSection(segment: _segment),
            audioRecorded ? audioRecordedSection() : audioRecorderSection()
          ])),
    ]);
  }
}
