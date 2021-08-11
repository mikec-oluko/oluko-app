import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/segment_section.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/courses/segment_detail.dart';
import 'package:oluko_app/ui/screens/video_overlay.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class InsideClass extends StatefulWidget {
  InsideClass({this.courseEnrollment, this.classIndex, Key key})
      : super(key: key);

  final CourseEnrollment courseEnrollment;
  final int classIndex;

  @override
  _InsideClassesState createState() => _InsideClassesState();
}

class FirebaseUser {}

class _InsideClassesState extends State<InsideClass> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  Class _class;
  User _user;
  List<Segment> _segments;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.firebaseUser;
        BlocProvider.of<ClassBloc>(context)
          ..get(widget.courseEnrollment.classes[widget.classIndex].id);
        return BlocBuilder<ClassBloc, ClassState>(
            builder: (context, classState) {
          if (classState is GetByIdSuccess) {
            _class = classState.classObj;
            BlocProvider.of<SegmentBloc>(context)..getAll(_class);
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
      } else {
        return SizedBox();
      }
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
            body: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    ListView(children: [
                      /*Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: OrientationBuilder(
                          builder: (context, orientation) {
                            return showVideoPlayer(_class.video);
                          },
                        ),
                      ),*/

                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                            ).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height));
                          },
                          blendMode: BlendMode.dstIn,
                          child: Stack(children: [
                            Stack(alignment: Alignment.center, children: [
                              AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.asset(
                                    'assets/courses/profile_photos.png',
                                    fit: BoxFit.cover,
                                  )),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (_, __, ___) =>
                                        VideoOverlay(videoUrl: _class.video),
                                  ),
                                ),
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      'assets/assessment/play.png',
                                      height: 50,
                                      width: 50,
                                    )),
                              )
                            ]),
                            Padding(
                                padding: EdgeInsets.only(top: 15),
                                child: Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.chevron_left,
                                            size: 35, color: Colors.white),
                                        onPressed: () =>
                                            Navigator.pop(context)),
                                  ],
                                )),
                          ]),
                        ),
                      ),
                      Padding(
                          padding:
                              EdgeInsets.only(right: 15, left: 15, top: 25),
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _startButton(),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: Text(
                                          _class.name,
                                          style: OlukoFonts.olukoTitleFont(
                                              custoFontWeight: FontWeight.bold),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, right: 10),
                                      child: Text(
                                        OlukoLocalizations.of(context)
                                                .find('class') +
                                            " " +
                                            (widget.classIndex + 1).toString() +
                                            " " +
                                            OlukoLocalizations.of(context)
                                                .find('of') +
                                            " " +
                                            widget
                                                .courseEnrollment.classes.length
                                                .toString(),
                                        style: OlukoFonts.olukoBigFont(
                                            custoFontWeight: FontWeight.normal,
                                            customColor: OlukoColors.primary),
                                      ),
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: CourseProgressBar(value: 0.5)),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20.0),
                                      child: Text(
                                        _class.description,
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

  Widget _startButton() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        OlukoPrimaryButton(
          title: OlukoLocalizations.of(context).find('start'),
          onPressed: () {
            int segmentIndex =
                CourseEnrollmentService.getFirstUncompletedSegmentIndex(
                    widget.courseEnrollment.classes[widget.classIndex]);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SegmentDetail(
                        user: _user,
                        segments: _segments,
                        segmentIndex: segmentIndex,
                        classIndex: widget.classIndex,
                        courseEnrollment: widget.courseEnrollment)));
          },
        ),
      ],
    );
  }
}
