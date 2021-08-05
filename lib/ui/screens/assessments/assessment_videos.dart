import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/task_card.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        //TODO: Change this when we have multiple assessments
        BlocProvider.of<AssessmentBloc>(context)
          ..getById('emnsmBgZ13UBRqTS26Qd');
        return BlocBuilder<AssessmentBloc, AssessmentState>(
            builder: (context, assessmentState) {
          if (assessmentState is AssessmentSuccess) {
            _assessment = assessmentState.assessment;
            BlocProvider.of<TaskBloc>(context)..get(_assessment);
            BlocProvider.of<AssessmentAssignmentBloc>(context)
              ..getOrCreate(authState.firebaseUser,_assessment);
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
            appBar: OlukoAppBar(
              title: OlukoLocalizations.of(context).find('assessment'),
              actions: [skipButton()],
            ),
            body: Container(
                color: Colors.black,
                child: ListView(children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: OrientationBuilder(
                            builder: (context, orientation) {
                              return showVideoPlayer(_assessment.video);
                            },
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              _assessment.description,
                              style: OlukoFonts.olukoSuperBigFont(
                                  customColor: OlukoColors.white),
                            )),
                        taskCardsSection(),
                        SizedBox(
                          height: 10,
                        ),
                        BlocBuilder<AssessmentAssignmentBloc,
                                AssessmentAssignmentState>(
                            builder: (context, assessmentAssignmentState) {
                          if (assessmentAssignmentState
                                  is AssessmentAssignmentSuccess &&
                              assessmentAssignmentState
                                      .assessmentAssignment.completedAt !=
                                  null) {
                            return Row(children: [
                              OlukoPrimaryButton(
                                title:
                                    OlukoLocalizations.of(context).find('done'),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, routeLabels[RouteEnum.root]);
                                },
                              )
                            ]);
                          } else {
                            return SizedBox();
                          }
                        }),
                        SizedBox(
                          height: 50,
                        ),
                      ])),
                ]))));
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

  Widget taskCardsSection() {
    return Column(
      children: [
        BlocBuilder<TaskBloc, TaskState>(builder: (context, taskState) {
          if (taskState is TaskSuccess) {
            return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: taskState.values.length,
                shrinkWrap: true,
                itemBuilder: (context, num index) {
                  Task task = taskState.values[index];
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TaskCard(
                        task: task,
                        onPressed: () {
                          if (_controller != null) {
                            _controller.pause();
                          }
                          return Navigator.pushNamed(
                              context, routeLabels[RouteEnum.taskDetails],
                              arguments: {'taskIndex': index});
                        },
                      ));
                });
          } else {
            return Padding(
                padding: const EdgeInsets.all(50.0),
                child: OlukoCircularProgressIndicator());
          }
        }),
      ],
    );
  }

  Widget skipButton() {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, routeLabels[RouteEnum.root]);
        },
        child: Align(
            alignment: Alignment.center,
            child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  OlukoLocalizations.of(context).find('skip'),
                  style: OlukoFonts.olukoBigFont(
                      customColor: OlukoColors.grayColor),
                ))));
  }
}
