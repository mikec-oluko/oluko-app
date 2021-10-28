import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/audio_bloc.dart';
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
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
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
import 'package:oluko_app/utils/sound_recorder.dart';
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
  bool audioRecorded;
  bool submitted;
  final SoundRecorder recorder = SoundRecorder();

  @override
  void initState() {
    super.initState();
    audioRecorded = false;
    submitted = false;
    recorder.init();
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
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
                maxHeight: 250,
                minHeight: 5,
                collapsed: Container(
                  color: Colors.black,
                ),
                panel: dialogContent(),
                body: Container(
                  color: Colors.black,
                  child: classInfoSection(),
                ))));
  }

  Widget dialogContent() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/courses/gray_background.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(children: [
          SizedBox(height: 10),
          Icon(Icons.warning_amber_rounded,
              color: OlukoColors.coral, size: 100),
          SizedBox(height: 5),
          Text(OlukoLocalizations.get(context, 'deleteMessageConfirm'),
              textAlign: TextAlign.center,
              style: OlukoFonts.olukoBigFont(
                  custoFontWeight: FontWeight.w400,
                  customColor: OlukoColors.grayColor)),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OlukoOutlinedButton(
                title: OlukoLocalizations.get(context, 'no'),
                onPressed: () {
                  panelController.close();
                },
              ),
              SizedBox(width: 20),
              OlukoPrimaryButton(
                title: OlukoLocalizations.get(context, 'yes'),
                onPressed: () {
                  setState(() {
                    audioRecorded = false;
                  });
                  panelController.close();
                },
              )
            ],
          ),
        ]));
  }

  Widget audioRecordedSection() {
    return Container(
        height: !submitted ? 140 : 76,
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
              record: recorder.audioUrl /*record*/,
              showTicks: submitted,
              panelController: panelController),
          !submitted ? _saveButton() : SizedBox()
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
              onPressed: () {
                BlocProvider.of<AudioBloc>(context)
                  ..saveAudio(
                      File(recorder.audioUrl), _user.id, widget.challenge.id);
                setState(() {
                  submitted = true;
                });
              },
            ),
          ],
        ));
  }

  Widget audioRecorderSection() {
    return Container(
        height: 76,
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
                  recorder: recorder,
                  onSaved: _onRecordCompleted,
                )
              ]))
        ]));
  }

  _onRecordCompleted() {
    setState(() {
      audioRecorded = true;
    });
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
