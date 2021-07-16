import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/task_card.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/title_header.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/task_details.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class AssessmentVideos extends StatefulWidget {
  AssessmentVideos({Key key}) : super(key: key);

  @override
  _AssessmentVideosState createState() => _AssessmentVideosState();
}

class _AssessmentVideosState extends State<AssessmentVideos> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  AssessmentBloc _assessmentBloc;
  TaskBloc _taskBloc;
  Assessment assessment;
  User user;

  @override
  void initState() {
    _assessmentBloc = AssessmentBloc();
    _taskBloc = TaskBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        user = authState.firebaseUser;
        return MultiBlocProvider(
            providers: [
              BlocProvider<AssessmentBloc>(
                //TODO: Change this when we have multiple assessments
                create: (context) =>
                    _assessmentBloc..getById('ndRa0ldHCwCUaDxEQm25'),
              ),
              BlocProvider<TaskBloc>(
                create: (context) => _taskBloc,
              ),
            ],
            child: BlocBuilder<AssessmentBloc, AssessmentState>(
                builder: (context, state) {
              if (state is AssessmentSuccess) {
                assessment = state.assessment;
                _taskBloc..get(assessment);
                return form();
              } else {
                return SizedBox();
              }
            }));
      } else {
        return Text("Not logged user");
      }
    });
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            body: Container(
                color: Colors.black,
                child: ListView(children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(children: [
                            SizedBox(height: 20),
                            SizedBox(height: 20),
                            Stack(children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(
                                      Icons.chevron_left,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: TitleHeader(
                                        'Assessment',
                                        bold: true,
                                      )),
                                ],
                              ),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Text(
                                      'Skip',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  )),
                            ]),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 25),
                              child: OrientationBuilder(
                                builder: (context, orientation) {
                                  return ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.portrait
                                              ? ScreenUtils.height(context) / 4
                                              : ScreenUtils.height(context) /
                                                  1.5,
                                          minHeight: MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.portrait
                                              ? ScreenUtils.height(context) / 4
                                              : ScreenUtils.height(context) /
                                                  1.5),
                                      child: Container(
                                          height: 400,
                                          child: Stack(
                                              children: showVideoPlayer(
                                                  assessment.video))));
                                },
                              ),
                            ),
                            TitleBody(
                              assessment.description,
                              bold: true,
                            ),
                            Column(
                              children: [
                                BlocBuilder<TaskBloc, TaskState>(
                                    builder: (context, state) {
                                  if (state is TaskSuccess) {
                                    return ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: state.values.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, num index) {
                                          Task task = state.values[index];
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15.0),
                                              child: TaskCard(
                                                task: task,
                                                onPressed: () {
                                                  if (_controller != null) {
                                                    _controller.pause();
                                                  }
                                                  return Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return TaskDetails(tasks: state.values, index: index,
                                                        user: user, task: task);
                                                  })).then((value) =>
                                                      this.setState(() {
                                                        _controller = null;
                                                      }));
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

  List<Widget> showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
        videoUrl: assessment.video,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));

    return widgets;
  }
}
