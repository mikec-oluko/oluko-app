import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/class_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/class_section.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/screen_utils.dart';

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

  //TODO: remove hardcoded reference
  DocumentReference courseReference = FirebaseFirestore.instance
      .collection("projects")
      .doc(GlobalConfiguration().getValue("projectId"))
      .collection("courses")
      .doc('CC5HBkSV8DthLQNKyBlc');

  @override
  void initState() {
    super.initState();
    _courseBloc = CourseBloc();
    _classBloc = ClassBloc();
  }

  @override
  Widget build(BuildContext context) {
    /*CourseRepository.create(Course(
        name: "6 Weeks to great abs",
        imageUrl:
            "https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fcourse_sample_1.png?alt=media&token=2de41e42-fd00-4acc-8027-662792090253",
        video: "https://oluko-mvt.s3.us-west-1.amazonaws.com/assessments/85b2f81c1fe74f9cb5e804c57db30137/85b2f81c1fe74f9cb5e804c57db30137_2.mp4"));*/
    /*ClassRepository.create(Class(name: "Strength",
    video: "https://oluko-mvt.s3.us-west-1.amazonaws.com/assessments/85b2f81c1fe74f9cb5e804c57db30137/85b2f81c1fe74f9cb5e804c57db30137_2.mp4",
    image: "https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/classes_sample_images%2Fclass_sample_2.png?alt=media&token=f3ac6b80-a2f5-4612-ab72-ea72f88ad00e",
    description: "Contrary to popular belief, Lor em Ipsum is not sim ply rando mie text. Pular belief, Lor em Ipsum is not sim ply rando mie text."), courseReference);*/
    return MultiBlocProvider(
        providers: [
          BlocProvider<CourseBloc>(
            create: (context) => _courseBloc..getById("CC5HBkSV8DthLQNKyBlc"),
          ),
          BlocProvider<ClassBloc>(
            create: (context) => _classBloc,
          ),
        ],
        child: BlocBuilder<CourseBloc, CourseState>(builder: (context, state) {
          if (state is GetCourseSuccess) {
            _classBloc..getAll(state.course);
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
            appBar: OlukoAppBar(title: "Course"),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 25),
                                  child: OrientationBuilder(
                                    builder: (context, orientation) {
                                      return ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? ScreenUtils.height(context) /
                                                      4
                                                  : ScreenUtils.height(context) /
                                                      1.5,
                                              minHeight: MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? ScreenUtils.height(context) /
                                                      4
                                                  : ScreenUtils.height(context) /
                                                      1.5),
                                          child: Container(
                                              height: 400,
                                              child: Stack(
                                                  children:
                                                      showVideoPlayer())));
                                    },
                                  ),
                                ),
                                Text(
                                  course.name,
                                  style: OlukoFonts.olukoTitleFont(
                                      custoFontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, right: 10),
                                  child: Text(
                                    "6 Weeks, " +
                                        course.classes.length.toString() +
                                        " Classes.",
                                    style: OlukoFonts.olukoBigFont(
                                        custoFontWeight: FontWeight.normal,
                                        customColor: OlukoColors.grayColor),
                                  ),
                                ),
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
                                                          .symmetric(
                                                      vertical: 15.0),
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
                                            child: Text('Loading...',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                )),
                                          ),
                                        );
                                      }
                                    }),
                                  ],
                                ),
                                SizedBox(
                                  height: 100,
                                )
                              ])))
                ]))));
  }

  List<Widget> showVideoPlayer() {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
        //videoUrl: _mainAssessment.video,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));

    return widgets;
  }
}
