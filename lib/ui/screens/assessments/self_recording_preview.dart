import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_list_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/progress_bar.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class SelfRecordingPreview extends StatefulWidget {
  const SelfRecordingPreview(
      {this.filePath,
      this.taskIndex,
      this.isLastTask = false,
      this.isPublic,
      Key key})
      : super(key: key);

  final String filePath;
  final int taskIndex;
  final bool isPublic;
  final bool isLastTask;

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
  Assessment _assessment;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        return BlocBuilder<AssessmentBloc, AssessmentState>(
            builder: (context, assessmentState) {
          return BlocBuilder<AssessmentAssignmentBloc,
              AssessmentAssignmentState>(
            builder: (context, assessmentAssignmentState) {
              return BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, taskState) {
                return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
                    builder: (context, taskSubmissionState) {
                  if (assessmentState is AssessmentSuccess &&
                      assessmentAssignmentState
                          is AssessmentAssignmentSuccess &&
                      taskState is TaskSuccess &&
                      (taskSubmissionState is GetSuccess ||
                          taskSubmissionState is CreateSuccess)) {
                    _assessment = assessmentState.assessment;
                    _assessmentAssignment =
                        assessmentAssignmentState.assessmentAssignment;
                    _tasks = taskState.values;
                    _task = _tasks[widget.taskIndex];
                    if (taskSubmissionState is GetSuccess) {
                      _taskSubmission = taskSubmissionState.taskSubmission;
                    }
                    return BlocListener<TaskSubmissionBloc,
                            TaskSubmissionState>(
                        listener: (context, state) {
                          if (state is CreateSuccess) {
                            _taskSubmission = state.taskSubmission;
                            BlocProvider.of<VideoBloc>(context).createVideo(
                                context,
                                File(widget.filePath),
                                3.0 / 4.0,
                                state.taskSubmission.id);
                          }
                        },
                        child: form());
                  } else {
                    return const SizedBox();
                  }
                });
              });
            },
          );
        });
      } else {
        return const SizedBox();
      }
    });
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: BlocConsumer<VideoBloc, VideoState>(listener: (context, state) {
          if (state is VideoSuccess) {
            BlocProvider.of<TaskSubmissionBloc>(context)
                .updateTaskSubmissionVideo(
                    _assessmentAssignment, _taskSubmission.id, state.video);
            BlocProvider.of<TaskSubmissionBloc>(context)
                .checkCompleted(_assessmentAssignment, _assessment);
            BlocProvider.of<TaskSubmissionListBloc>(context)
                .get(_assessmentAssignment);
            Navigator.pop(context);
            Navigator.pushNamed(context, routeLabels[RouteEnum.taskDetails],
                arguments: {
                  'taskIndex': widget.taskIndex,
                  'isLastTask': _tasks.length - widget.taskIndex == 1
                      ? true
                      : widget.isLastTask
                });
          }
        }, builder: (context, state) {
          if (state is VideoProcessing) {
            return progressScaffold(state);
          } else {
            return contentScaffold();
          }
        }));
  }

  Widget contentScaffold() {
    return Scaffold(
        appBar: OlukoAppBar(title: _task.name, actions: [retakeButton()]),
        body: Container(
          color: Colors.black,
          child: ListView(
            children: [
              content(),
            ],
          ),
        ));
  }

  Widget progressScaffold(VideoProcessing state) {
    return Scaffold(
        appBar: OlukoAppBar(title: _task.name, actions: [SizedBox(width: 30)]),
        body: Container(
          color: Colors.black,
          child: Container(
            child: ProgressBar(
                processPhase: state.processPhase, progress: state.progress),
          ),
        ));
  }

  List<Widget> showVideoPlayer() {
    List<Widget> widgets = [];
    widgets.add(OlukoVideoPlayer(
        filePath: widget.filePath,
        whenInitialized: (ChewieController chewieController) => setState(() {
              _controller = chewieController;
            })));
    if (_controller == null) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    }
    return widgets;
  }

  Widget retakeButton() {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecording],
              arguments: {
                'taskIndex': widget.taskIndex,
                'isLastTask': _tasks.length - widget.taskIndex == 1
                    ? true
                    : widget.isLastTask
              });
        },
        child: Align(
            child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 8),
                child: Text(
                  OlukoLocalizations.get(context, 'retake'),
                  style:
                      OlukoFonts.olukoBigFont(customColor: OlukoColors.primary),
                ))));
  }

  Widget content() {
    return Column(children: [
      ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height / 1.5),
          child: Stack(children: showVideoPlayer())),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Row(children: [
            OlukoPrimaryButton(
              title: OlukoLocalizations.get(context, 'done'),
              onPressed: () async {
                _controller.pause();
                if (_taskSubmission == null) {
                  BlocProvider.of<TaskSubmissionBloc>(context)
                      .createTaskSubmission(_assessmentAssignment, _task,
                          widget.isPublic, widget.isLastTask);
                } else {
                  BlocProvider.of<VideoBloc>(context).createVideo(context,
                      File(widget.filePath), 3.0 / 4.0, _taskSubmission.id);
                }
              },
            )
          ]))
    ]);
  }
}
