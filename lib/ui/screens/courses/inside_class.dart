import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/segment_section.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/courses/segment_detail.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class InsideClass extends StatefulWidget {
  InsideClass({this.course, this.classIndex, Key key}) : super(key: key);

  final Course course;
  final int classIndex;

  @override
  _InsideClassesState createState() => _InsideClassesState();
}

class FirebaseUser {}

class _InsideClassesState extends State<InsideClass> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  List<Class> _classes;
  CourseEnrollment _courseEnrollment;
  User _user;
  List<Segment> _segments;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      return BlocBuilder<ClassBloc, ClassState>(builder: (context, classState) {
        return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
            builder: (context, courseEnrollmentState) {
          if (authState is AuthSuccess &&
              classState is GetSuccess &&
              courseEnrollmentState is GetEnrollmentSuccess) {
            _user = authState.firebaseUser;
            _classes = classState.classes;
            _courseEnrollment = courseEnrollmentState.courseEnrollment;
            BlocProvider.of<SegmentBloc>(context)
              ..getAll(_classes[widget.classIndex]);
            return BlocBuilder<SegmentBloc, SegmentState>(
                builder: (context, segmentState) {
              if (segmentState is GetSegmentsSuccess) {
                _segments = segmentState.segments;
                return form();
              } else {
                return SizedBox();
              }
            });
          } else {
            return SizedBox();
          }
        });
      });
    });

    /*return MultiBlocProvider(
        providers: [
          BlocProvider<SegmentBloc>(
            create: (context) => _segmentBloc..getAll(widget.actualClass),
          )
        ],
        child:
            BlocBuilder<SegmentBloc, SegmentState>(builder: (context, state) {
          if (state is GetSegmentsSuccess) {
            return form(state.segments);
          } else {
            return SizedBox();
          }
        }));*/
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: OlukoAppBar(
                title: OlukoLocalizations.of(context).find('class')),
            body: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    ListView(children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: OrientationBuilder(
                          builder: (context, orientation) {
                            return showVideoPlayer(
                                _classes[widget.classIndex].video);
                          },
                        ),
                      ),
                      //TODO: Calculate progress here, take it from classes view
                      /*widget.classProgress > 0
                          ? CourseProgressBar(value: widget.classProgress)
                          : SizedBox(),*/
                      Padding(
                          padding:
                              EdgeInsets.only(right: 15, left: 15, top: 25),
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _classes[widget.classIndex].name,
                                      style: OlukoFonts.olukoTitleFont(
                                          custoFontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, right: 10),
                                      child: Text(
                                        widget.course.name,
                                        style: OlukoFonts.olukoSuperBigFont(
                                            custoFontWeight: FontWeight.bold,
                                            customColor: OlukoColors.primary),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, right: 10),
                                      child: Text(
                                        _classes[widget.classIndex].description,
                                        style: OlukoFonts.olukoBigFont(
                                            custoFontWeight: FontWeight.normal,
                                            customColor: OlukoColors.grayColor),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: _segments.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, num index) {
                                              Segment segment =
                                                  _segments[index];
                                              return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: SegmentSection(
                                                    segment: segment,
                                                    onPressed: () {},
                                                  ));
                                            }),
                                      ],
                                    ),
                                  ]))),
                      SizedBox(
                        height: 150,
                      )
                    ]),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                            color: Colors.black,
                            child: _startButton(_segments)))
                  ],
                ))));
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

  Widget _startButton(List<Segment> segments) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            OlukoPrimaryButton(
              title: OlukoLocalizations.of(context).find('start'),
              onPressed: () {
                int segmentIndex =
                    CourseEnrollmentService.getFirstUncompletedSegmentIndex(
                        _courseEnrollment.classes[widget.classIndex]);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SegmentDetail(
                            user: _user,
                            segments: segments,
                            segmentIndex: segmentIndex,
                            classIndex: widget.classIndex,
                            courseEnrollment: _courseEnrollment)));
              },
            ),
          ],
        ));
  }
}
