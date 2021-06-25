import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/task_card.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/title_header.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/task_details.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class AsessmentVideos extends StatefulWidget {
  final Assessment assessment;

  AsessmentVideos({Key key, this.assessment}) : super(key: key);

  @override
  _AsessmentVideosState createState() => _AsessmentVideosState();
}

class _AsessmentVideosState extends State<AsessmentVideos> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  SignUpResponse profileInfo;
  Assessment _mainAssessment;

  @override
  Widget build(BuildContext context) {
    //TODO Remove BlocBuilder & MainAssessment assignation when we got Assessment List view.
    return BlocBuilder<AssessmentBloc, AssessmentState>(
        builder: (context, state) {
      if (state is AssessmentSuccess) {
        _mainAssessment =
            widget.assessment != null ? widget.assessment : state.values[0];
        return BlocProvider(
          create: (context) => TaskBloc()..getForAssessment(_mainAssessment),
          child: form(),
        );
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
                                              children: showVideoPlayer())));
                                },
                              ),
                            ),
                            TitleBody(
                              'Complete the below tasks to get a coach assigned',
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
                                                    return TaskDetails(
                                                        task: task);
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

  List<Widget> showVideoPlayer() {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
        videoUrl: _mainAssessment.video,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));

    return widgets;
  }
}
