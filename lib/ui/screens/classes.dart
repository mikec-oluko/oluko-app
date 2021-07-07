import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/class_bloc.dart';
import 'package:oluko_app/blocs/statistics_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/class_section.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/statistics_chart.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class Classes extends StatefulWidget {
  Classes({Key key}) : super(key: key);

  @override
  _ClassesState createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  CourseBloc _courseBloc;
  ClassBloc _classBloc;
  StatisticsBloc _statisticsBloc;

  //TODO: remove hardcoded reference
  DocumentReference segmentReference = FirebaseFirestore.instance
      .collection("projects")
      .doc(GlobalConfiguration().getValue("projectId"))
      .collection("segments")
      .doc('jwKrMyYxnmeN6HqWGHw9');

  @override
  void initState() {
    super.initState();
    _courseBloc = CourseBloc();
    _classBloc = ClassBloc();
    _statisticsBloc = StatisticsBloc();
  }

  @override
  Widget build(BuildContext context) {
    //MovementRepository.create(Movement(name: "Chin-Ups"),segmentReference);
    return MultiBlocProvider(
        providers: [
          BlocProvider<CourseBloc>(
            //TODO: change this when the view is in the correct place
            create: (context) => _courseBloc..getById("CC5HBkSV8DthLQNKyBlc"),
          ),
          BlocProvider<ClassBloc>(
            create: (context) => _classBloc,
          ),
          BlocProvider<StatisticsBloc>(
            create: (context) => _statisticsBloc,
          ),
        ],
        child: BlocBuilder<CourseBloc, CourseState>(builder: (context, state) {
          if (state is GetCourseSuccess) {
            _classBloc..getAll(state.course);
            _statisticsBloc..get(state.course.statisticsReference);
            return form(state.course);
          } else {
            return SizedBox();
          }
        }));
  }

  Widget form(Course course) {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: OlukoAppBar(
                title: OlukoLocalizations.of(context).find('course')),
            body: Container(
                color: Colors.black,
                child: ListView(children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: OrientationBuilder(
                      builder: (context, orientation) {
                        return showVideoPlayer();
                      },
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.name,
                                  style: OlukoFonts.olukoTitleFont(
                                      custoFontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, right: 10),
                                  child: Text(
                                    //TODO: change weeks number
                                    TimeConverter.toCourseDuration(
                                        6, course.classes.length, context),
                                    style: OlukoFonts.olukoBigFont(
                                        custoFontWeight: FontWeight.normal,
                                        customColor: OlukoColors.grayColor),
                                  ),
                                ),
                                BlocBuilder<StatisticsBloc, StatisticsState>(
                                    builder: (context, state) {
                                  if (state is StatisticsSuccess) {
                                    return Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        child: StatisticChart(
                                            courseStatistics:
                                                state.courseStatistics));
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.all(50.0),
                                      child: Center(
                                        child: Text(
                                            OlukoLocalizations.of(context)
                                                .find('loadingWhithDots'),
                                            style: TextStyle(
                                              color: Colors.white,
                                            )),
                                      ),
                                    );
                                  }
                                }),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, right: 10),
                                  child: Text(
                                    course.description,
                                    style: OlukoFonts.olukoBigFont(
                                        custoFontWeight: FontWeight.normal,
                                        customColor: OlukoColors.grayColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 25.0),
                                  child: TitleBody('Classes'),
                                ),
                                Column(
                                  children: [
                                    BlocBuilder<ClassBloc, ClassState>(
                                        builder: (context, state) {
                                      if (state is GetSuccess) {
                                        return ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: state.classes.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, num index) {
                                              Class classObj =
                                                  state.classes[index];
                                              return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: ClassSection(
                                                    classObj: classObj,
                                                    onPressed: () {
                                                      /*if (_controller != null) {
                                                    _controller.pause();
                                                  }
                                                  return Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return TaskDetails(
                                                        task: task);
                                                  })).then((value) =>
                                                      this.setState(() {
                                                        _controller = null;
                                                      }));*/
                                                    },
                                                  ));
                                            });
                                      } else {
                                        return Padding(
                                          padding: const EdgeInsets.all(50.0),
                                          child: Center(
                                            child: Text(
                                                OlukoLocalizations.of(context)
                                                    .find('loadingWhithDots'),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                )),
                                          ),
                                        );
                                      }
                                    }),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        OlukoPrimaryButton(
                                          title: OlukoLocalizations.of(context)
                                              .find('enroll'),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 100,
                                )
                              ])))
                ]))));
  }

  Widget showVideoPlayer() {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
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
}
