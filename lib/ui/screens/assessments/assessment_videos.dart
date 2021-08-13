import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_list_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/task_submission_service.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/task_card.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/movement_utils.dart';
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
    return BlocListener<AssessmentAssignmentBloc, AssessmentAssignmentState>(
      listener: (context, assessmentAssignmentState) {
        if (assessmentAssignmentState is AssessmentAssignmentSuccess) {
          BlocProvider.of<TaskSubmissionListBloc>(context)
            ..get(assessmentAssignmentState.assessmentAssignment);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
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
                ..getOrCreate(authState.firebaseUser, _assessment);
              return form();
            } else {
              return SizedBox();
            }
          });
        } else {
          return SizedBox();
        }
      }),
    );
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
                        BlocBuilder<TaskSubmissionListBloc,
                                TaskSubmissionListState>(
                            builder: (context, taskSubmissionListState) {
                          if (taskSubmissionListState
                              is GetTaskSubmissionSuccess) {
                            return taskCardsSection(
                                taskSubmissionListState.taskSubmissions);
                          } else {
                            return Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: CircularProgressIndicator());
                          }
                        }),
                        SizedBox(
                          height: 10,
                        ),
                        BlocBuilder<AssessmentAssignmentBloc,
                                AssessmentAssignmentState>(
                            builder: (context, assessmentAssignmentState) {
                          if (assessmentAssignmentState
                                  is AssessmentAssignmentSuccess &&
                              assessmentAssignmentState
                                      .assessmentAssignment.compleatedAt !=
                                  null) {
                            return Row(children: [
                              OlukoPrimaryButton(
                                title:
                                    OlukoLocalizations.of(context).find('done'),
                                onPressed: () {
                                  MovementUtils.movementDialog(
                                      context, _confirmDialogContent(),
                                      showExitButton: false);
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

  Widget taskCardsSection(List<TaskSubmission> taskSubmissions) {
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
                  TaskSubmission taskSubmission =
                      TaskSubmissionService.getTaskSubmissionOfTask(
                          task, taskSubmissions);
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TaskCard(
                        task: task,
                        isCompleted: taskSubmission != null,
                        isPublic: isPublic(taskSubmission),
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

  bool isPublic(TaskSubmission taskSubmission) {
    if (taskSubmission == null) {
      return false;
    } else {
      return taskSubmission.isPublic;
    }
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

  List<Widget> _confirmDialogContent() {
    return [
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Stack(alignment: Alignment.center, children: [
              Image.asset(
                'assets/assessment/green_ellipse.png',
                scale: 2,
              ),
              Image.asset(
                'assets/assessment/gray_check.png',
                scale: 5,
              )
            ]),
            Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
                child: Text(
                  OlukoLocalizations.of(context).find('done!'),
                  style: OlukoFonts.olukoSuperBigFont(
                      customColor: OlukoColors.white,
                      custoFontWeight: FontWeight.bold),
                )),
            Text(
              OlukoLocalizations.of(context).find('assessmentMessagePart1'),
              style:
                  OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
            ),
            Text(
              OlukoLocalizations.of(context).find('assessmentMessagePart2'),
              style:
                  OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    OlukoPrimaryButton(
                      title: OlukoLocalizations.of(context).find('goBack'),
                      thinPadding: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 20),
                    OlukoOutlinedButton(
                      title: OlukoLocalizations.of(context).find('ok'),
                      onPressed: () {
                        if (_controller != null) {
                          _controller.pause();
                        }
                        return Navigator.pushNamed(
                            context, routeLabels[RouteEnum.root]);
                      },
                    ),
                  ],
                ))
          ]))
    ];
  }
}
