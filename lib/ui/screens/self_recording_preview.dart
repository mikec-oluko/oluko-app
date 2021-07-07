import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/progress_bar.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/task_details.dart';

class SelfRecordingPreview extends StatefulWidget {
  SelfRecordingPreview({this.task, this.filePath, key}) : super(key: key);

  Task task;
  String filePath;

  @override
  _SelfRecordingPreviewState createState() => _SelfRecordingPreviewState();
}

class _SelfRecordingPreviewState extends State<SelfRecordingPreview> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  VideoBloc _videoBloc;
  TaskSubmissionBloc _taskSubmissionBloc;

  String taskSubmissionId;

  //TODO: remove hardcoded reference
  CollectionReference reference = FirebaseFirestore.instance
      .collection("projects")
      .doc(GlobalConfiguration().getValue("projectId"))
      .collection("assessmentAssignments")
      .doc('8dWwPNggqruMQr0OSV9f')
      .collection('taskSubmissions');

  @override
  void initState() {
    _videoBloc = VideoBloc();
    _taskSubmissionBloc = TaskSubmissionBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<TaskBloc>(
            create: (context) => TaskBloc()..get(),
          ),
          BlocProvider<VideoBloc>(
            create: (context) => _videoBloc,
          ),
          BlocProvider<TaskSubmissionBloc>(
            create: (context) => _taskSubmissionBloc,
          ),
        ],
        child: BlocListener<TaskSubmissionBloc, TaskSubmissionState>(
            listener: (context, state) {
              if (state is CreateSuccess) {
                setState(() {
                  taskSubmissionId = state.taskSubmissionId;
                });
                _videoBloc
                  ..createVideo(context, File(widget.filePath), 3.0 / 4.0,
                      state.taskSubmissionId);
              }
            },
            child: form()));
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: OlukoAppBar(title: widget.task.name),
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
                                  _taskSubmissionBloc
                                    ..createTaskSubmission(
                                        reference, widget.task);
                                },
                              )),
                          BlocConsumer<VideoBloc, VideoState>(
                              listener: (context, state) {
                            if (state is VideoSuccess) {
                              _taskSubmissionBloc
                                ..updateTaskSubmissionVideo(
                                    reference.doc(taskSubmissionId),
                                    state.video);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TaskDetails(
                                          task: widget.task,
                                          showRecordedVideos: true)));
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
