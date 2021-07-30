import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/progress_bar.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/assessments/task_details.dart';

class SelfRecordingPreview extends StatefulWidget {
  SelfRecordingPreview({this.filePath, this.taskIndex, Key key})
      : super(key: key);

  final String filePath;
  final int taskIndex;

  @override
  _SelfRecordingPreviewState createState() => _SelfRecordingPreviewState();
}

class _SelfRecordingPreviewState extends State<SelfRecordingPreview> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;

  Task _task;
  List<Task> _tasks;
  AssessmentAssignment _assessmentAssignment;
  TaskSubmission _taskSubmission;

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
            return BlocBuilder<TaskBloc, TaskState>(
                builder: (context, taskState) {
              return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
                  builder: (context, taskSubmissionState) {
                if (assessmentAssignmentState is AssessmentAssignmentSuccess &&
                    taskState is TaskSuccess &&
                    (taskSubmissionState is GetSuccess ||
                        taskSubmissionState is CreateSuccess)) {
                  _assessmentAssignment =
                      assessmentAssignmentState.assessmentAssignment;
                  _tasks = taskState.values;
                  _task = _tasks[widget.taskIndex];
                  if (taskSubmissionState is GetSuccess) {
                    _taskSubmission = taskSubmissionState.taskSubmission;
                  }
                  return BlocListener<TaskSubmissionBloc, TaskSubmissionState>(
                      listener: (context, state) {
                        if (state is CreateSuccess) {
                          _taskSubmission = state.taskSubmission;
                          BlocProvider.of<VideoBloc>(context)
                            ..createVideo(context, File(widget.filePath),
                                3.0 / 4.0, state.taskSubmission.id);
                        }
                      },
                      child: form());
                } else {
                  return SizedBox();
                }
              });
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
            appBar: OlukoAppBar(title: _task.name),
            body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: OlukoPrimaryButton(
                                title: 'Done',
                                onPressed: () async {
                                  _controller.pause();
                                  if (_taskSubmission == null) {
                                    BlocProvider.of<TaskSubmissionBloc>(context)
                                      ..createTaskSubmission(
                                          _assessmentAssignment, _task);
                                  } else {
                                    BlocProvider.of<VideoBloc>(context)
                                      ..createVideo(
                                          context,
                                          File(widget.filePath),
                                          3.0 / 4.0,
                                          _taskSubmission.id);
                                  }
                                },
                              )),
                          BlocConsumer<VideoBloc, VideoState>(
                              listener: (context, state) {
                            if (state is VideoSuccess) {
                              BlocProvider.of<TaskSubmissionBloc>(context)
                                ..updateTaskSubmissionVideo(
                                    _assessmentAssignment,
                                    _taskSubmission.id,
                                    state.video);
                              Navigator.pushNamed(
                                  context, routeLabels[RouteEnum.taskDetails],
                                  arguments: {'taskIndex': widget.taskIndex});
                            }
                          }, builder: (context, state) {
                            if (state is VideoProcessing) {
                              return ProgressBar(
                                  processPhase: state.processPhase,
                                  progress: state.progress);
                            } else {
                              return ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height /
                                              1.5),
                                  child: Stack(children: showVideoPlayer()));
                            }
                          })
                        ],
                      ),
                    )))));
  }

  List<Widget> showVideoPlayer() {
    List<Widget> widgets = [];
    widgets.add(OlukoVideoPlayer(
        filePath: widget.filePath,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    return widgets;
  }
}
