import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class TaskDetails extends StatefulWidget {
  TaskDetails({this.taskIndex, Key key}) : super(key: key);

  final int taskIndex;

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  bool _makePublic = false;
  AssessmentAssignment _assessmentAssignment;
  Task _task;
  List<Task> _tasks;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        return BlocBuilder<AssessmentAssignmentBloc, AssessmentAssignmentState>(
          builder: (context, assessmentAssignmentState) {
            return BlocBuilder<TaskBloc, TaskState>(builder: (context, taskState) {
              if (assessmentAssignmentState is AssessmentAssignmentSuccess && taskState is TaskSuccess) {
                _assessmentAssignment = assessmentAssignmentState.assessmentAssignment;
                _tasks = taskState.values;
                _task = _tasks[widget.taskIndex];
                BlocProvider.of<TaskSubmissionBloc>(context)..getTaskSubmissionOfTask(_assessmentAssignment, _task);
                return form();
              } else {
                return SizedBox();
              }
            });
          },
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
            appBar: OlukoAppBar(title: _task.name, actions: [SizedBox(width: 30)]),
            body: Container(
                color: Colors.black,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - kToolbarHeight,
                      child: _content(),
                    )))));
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) => this.setState(() {
              _controller = chewieController;
            })));

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).orientation == Orientation.portrait
                ? ScreenUtils.height(context) / 4
                : ScreenUtils.height(context) / 1.5,
            minHeight: MediaQuery.of(context).orientation == Orientation.portrait
                ? ScreenUtils.height(context) / 4
                : ScreenUtils.height(context) / 1.5),
        child: Container(height: 400, child: Stack(children: widgets)));
  }

  Widget formSection([TaskSubmission taskSubmission]) {
    return Container(
        //height: MediaQuery.of(context).size.height / 1.75,
        child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              OlukoLocalizations.of(context).find('makeThisPublic'),
              style: OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.bold),
            ),
            Switch(
              value: _makePublic,
              onChanged: (bool value) => this.setState(() {
                _makePublic = value;
                if (taskSubmission != null) {
                  BlocProvider.of<TaskSubmissionBloc>(context)
                    ..updateTaskSubmissionPrivacity(_assessmentAssignment, taskSubmission.id, value);
                }
              }),
              trackColor: MaterialStateProperty.all(Colors.grey),
              activeColor: OlukoColors.primary,
            )
          ],
        ),
      ),
      Text(
        _task.description,
        style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
      ),
      BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(builder: (context, state) {
        if (state is GetSuccess && state.taskSubmission != null) {
          return recordedVideos(state.taskSubmission);
        } else {
          return SizedBox();
        }
      })
    ]));
  }

  Widget _content() {
    return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(builder: (context, state) {
      if (state is GetSuccess && state.taskSubmission != null) {
        _makePublic = state.taskSubmission.isPublic;
        return ListView(
          children: [
            SizedBox(height: 20),
            showVideoPlayer(_task.video),
            formSection(state.taskSubmission),
            recordAgainButtons(state.taskSubmission)
          ],
        );
      } else {
        return Stack(
          children: [
            ListView(
              children: [
                SizedBox(height: 20),
                showVideoPlayer(_task.video),
                formSection(),
              ],
            ),
            Positioned(bottom: 25, left: 0, right: 0, child: startRecordingButton()),
          ],
        );
      }
    });
  }

  Widget startRecordingButton() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        OlukoPrimaryButton(
          title: OlukoLocalizations.of(context).find('startRecording'),
          onPressed: () {
            if (_controller != null) {
              _controller.pause();
            }
            Navigator.pop(context);
            return Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecording],
                arguments: {'taskIndex': widget.taskIndex, 'isPublic': _makePublic});
          },
        ),
      ],
    );
  }

  Widget recordAgainButtons(TaskSubmission taskSubmission) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            OlukoOutlinedButton(
              thinPadding: true,
              title: OlukoLocalizations.of(context).find('recordAgain'),
              onPressed: () {
                DialogUtils.getDialog(context, _confirmDialogContent(taskSubmission), showExitButton: false);
              },
            ),
            SizedBox(width: 20),
            OlukoPrimaryButton(
              title: OlukoLocalizations.of(context).find('next'),
              onPressed: () {
                if (_controller != null) {
                  _controller.pause();
                }
                if (widget.taskIndex < _tasks.length - 1) {
                  Navigator.pop(context);
                  return Navigator.pushNamed(context, routeLabels[RouteEnum.taskDetails], arguments: {'taskIndex': widget.taskIndex + 1});
                } else {
                  Navigator.pushNamed(context, routeLabels[RouteEnum.assessmentVideos]);
                }
              },
            ),
          ],
        ));
  }

  List<Widget> _confirmDialogContent(TaskSubmission taskSubmission) {
    return [
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: TitleBody(OlukoLocalizations.of(context).find('recordAgainQuestion'), bold: true)),
            Text(OlukoLocalizations.of(context).find('recordAgainWarning'), textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont()),
            Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    OlukoPrimaryButton(
                      title: OlukoLocalizations.of(context).find('no'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 20),
                    OlukoOutlinedButton(
                      title: OlukoLocalizations.of(context).find('yes'),
                      onPressed: () {
                        if (_controller != null) {
                          _controller.pause();
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                        return Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecording],
                            arguments: {'taskIndex': widget.taskIndex});
                      },
                    ),
                  ],
                ))
          ]))
    ];
  }

  Widget recordedVideos(TaskSubmission taskSubmission) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: TitleBody(
              OlukoLocalizations.of(context).find('recordedVideo'),
              bold: true,
            )),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.taskSubmissionVideo],
            arguments: {'task': _task, 'videoUrl': taskSubmission.video.url}),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            height: 150,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              taskResponse(
                  TimeConverter.durationToString(Duration(milliseconds: taskSubmission.video.duration)), taskSubmission.video.thumbUrl),
            ]),
          ),
        ),
      )
    ]);
  }

  Widget taskResponse(String timeLabel, String thumbnail) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Stack(alignment: AlignmentDirectional.center, children: [
          thumbnail == null ? Icon(Icons.no_photography) : Image.network(thumbnail),
          Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/assessment/play.png",
                height: 40,
                width: 60,
              )),
          Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(150),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    timeLabel,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )),
        ]),
      ),
    );
  }
}
