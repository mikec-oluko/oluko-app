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
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/task_card.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/title_header.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/assessments/task_details.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class AssessmentVideos extends StatefulWidget {
  AssessmentVideos({Key key}) : super(key: key);

  @override
  _AssessmentVideosState createState() => _AssessmentVideosState();
}

class _AssessmentVideosState extends State<AssessmentVideos> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  Assessment _assessment;
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
        //TODO: Change this when we have multiple assessments
        BlocProvider.of<AssessmentBloc>(context)
          ..getById('emnsmBgZ13UBRqTS26Qd');
        return BlocBuilder<AssessmentBloc, AssessmentState>(
            builder: (context, assessmentState) {
          if (assessmentState is AssessmentSuccess) {
            _assessment = assessmentState.assessment;
            BlocProvider.of<TaskBloc>(context)..get(_assessment);
            return form();
          } else {
            return SizedBox();
          }
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
                                      '', // REMOVE FOR MVT 'Skip',
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
                                                  _assessment.video))));
                                },
                              ),
                            ),
                            TitleBody(
                              _assessment.description,
                              bold: true,
                            ),
                            Column(
                              children: [
                                BlocBuilder<TaskBloc, TaskState>(
                                    builder: (context, taskState) {
                                  if (taskState is TaskSuccess) {
                                    return ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: taskState.values.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, num index) {
                                          Task task = taskState.values[index];
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
                                                  return Navigator.pushNamed(
                                                      context,
                                                      routeLabels[RouteEnum
                                                          .taskDetails],
                                                      arguments: {
                                                        'taskIndex': index
                                                      });
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
        videoUrl: _assessment.video,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));

    return widgets;
  }
}
