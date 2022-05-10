import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_card_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_list_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/progress_bar.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/time_converter.dart';


class SelfRecordingPreview extends StatefulWidget {
  const SelfRecordingPreview({this.filePath, this.taskIndex, this.isLastTask = false, this.isPublic, Key key, this.taskId}) : super(key: key);
  final String taskId;
  final String filePath;
  final int taskIndex;
  final bool isPublic;
  final bool isLastTask;

  @override
  _SelfRecordingPreviewState createState() => _SelfRecordingPreviewState();
}

class _SelfRecordingPreviewState extends State<SelfRecordingPreview> {
  GlobalService _globalService = GlobalService();

  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;

  Task _task;
  List<Task> _tasks;
  AssessmentAssignment _assessmentAssignment;
  TaskSubmission _taskSubmission;
  Assessment _assessment;
  VideoState videoState;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return /*WillPopScope(
        onWillPop: () => () async {
              if (videoState is VideoSuccess) {
                return true;
              }
              AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.of(context).find('videoIsStillProcessing'));
              return false;
            }(),
        child:*/
        BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        return BlocBuilder<AssessmentBloc, AssessmentState>(builder: (context, assessmentState) {
          return BlocBuilder<AssessmentAssignmentBloc, AssessmentAssignmentState>(
            builder: (context, assessmentAssignmentState) {
              return BlocBuilder<TaskBloc, TaskState>(builder: (context, taskState) {
                return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(builder: (context, taskSubmissionState) {
                  if (assessmentState is AssessmentSuccess &&
                      assessmentAssignmentState is AssessmentAssignmentSuccess &&
                      taskState is TaskSuccess &&
                      (taskSubmissionState is GetSuccess || taskSubmissionState is CreateSuccess)) {
                    _assessment = assessmentState.assessment;
                    _assessmentAssignment = assessmentAssignmentState.assessmentAssignment;
                    _tasks = taskState.values;
                    _task = _tasks[widget.taskIndex];
                    if (taskSubmissionState is GetSuccess && taskSubmissionState.taskSubmission != null && taskSubmissionState.taskSubmission.task.id==widget.taskId) {
                      _taskSubmission = taskSubmissionState.taskSubmission;
                    }
                    if (taskSubmissionState is CreateSuccess) {
                      _taskSubmission = taskSubmissionState.taskSubmission;
                      createVideo(_taskSubmission, _assessmentAssignment, _assessment);
                    }
                    return form();
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
    }) /*)*/;
  }

  createVideo(TaskSubmission taskSubmission, AssessmentAssignment assessmentAssignment, Assessment assessment) {
    BlocProvider.of<VideoBloc>(context)
        .createVideo(context, File(widget.filePath), 3.0 / 4.0, taskSubmission.id, null, assessmentAssignment, assessment, taskSubmission);
    _globalService.videoProcessing = true;
    BlocProvider.of<TaskCardBloc>(context).taskLoading(widget.taskIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_globalService.comesFromCoach) {
        Navigator.pop(context);
      } else {
        Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.assessmentVideos]));
      }
      navigateToTaskDetails();
    });
  }

  navigateToTaskDetails() {
    Navigator.pushNamed(context, routeLabels[RouteEnum.taskDetails], arguments: {
      'taskIndex': widget.taskIndex,
      'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask,
      'taskCompleted': true
    });
  }

  Widget form() {
    /*return Form(
        key: _formKey,
        child: BlocConsumer<VideoBloc, VideoState>(listener: (context, state) {
          videoState = state;
          if (state is VideoSuccess) {
            BlocProvider.of<TaskSubmissionBloc>(context).updateTaskSubmissionVideo(_assessmentAssignment, _taskSubmission.id, state.video);
            BlocProvider.of<TaskSubmissionBloc>(context).checkCompleted(_assessmentAssignment, _assessment);
            BlocProvider.of<TaskSubmissionListBloc>(context).get(_assessmentAssignment);
            //navigateToTaskDetails();
          }
        }, builder: (context, state) {
          if (state is VideoProcessing) {
            return progressScaffold(state);
          } else {*/
    return OlukoNeumorphism.isNeumorphismDesign ? neumorphicContentScaffold() : contentScaffold();
    // }
    // }));
  }

  Widget contentScaffold() {
    // TODO: UPDATED FOR NEUMORPHIC
    return Scaffold(
        appBar: OlukoAppBar(
          title: _task.name,
          actions: [retakeButton()],
          showTitle: true,
        ),
        body: Container(
          color: Colors.black,
          child: ListView(
            children: [
              content(),
            ],
          ),
        ));
  }

  Widget neumorphicContentScaffold() {
    // TODO: UPDATED FOR NEUMORPHIC
    return Scaffold(
        extendBody: true,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(height: MediaQuery.of(context).size.height, child: neumorphicContent()),
              Positioned(top: 80, right: 20, child: retakeButton()),
              Positioned(
                  top: 70,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, size: 24, color: OlukoColors.white),
                  )),
              Positioned(
                bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth : Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _controller != null
                            ? Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text('${TimeConverter.durationToString(_controller.videoPlayerController.value.duration)} min',
                                    style:
                                        OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.normal)),
                              )
                            : SizedBox.shrink(),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: OlukoNeumorphicPrimaryButton(
                              isExpanded: false,
                              customHeight: 60,
                              title: OlukoLocalizations.get(context, 'submit'),
                              onPressed: () async {
                                _controller.pause();
                                if (!_globalService.videoProcessing) {
                                  if (_taskSubmission == null) {
                                    BlocProvider.of<TaskSubmissionBloc>(context)
                                        .createTaskSubmission(_assessmentAssignment, _task, widget.isPublic, widget.isLastTask);
                                  } else {
                                    createVideo(_taskSubmission, _assessmentAssignment, _assessment);
                                  }
                                } else {
                                  showDialog();
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  showDialog() {
    return DialogUtils.getDialog(
        context,
        [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                OlukoLocalizations.get(context, 'videoIsStillProcessing'),
                textAlign: TextAlign.center,
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
              ))
        ],
        showExitButton: true);
  }

  Widget progressScaffold(VideoProcessing state) {
    return Scaffold(
        appBar: OlukoAppBar(title: _task.name, showBackButton: false, actions: [SizedBox(width: 30)]),
        body: Container(
          color: Colors.black,
          child: Container(
            child: ProgressBar(processPhase: state.processPhase, progress: state.progress),
          ),
        ));
  }

  List<Widget> showVideoPlayer() {
    List<Widget> widgets = [];
    widgets.add(OlukoVideoPlayer(
        isOlukoControls: true,
        filePath: widget.filePath,
        whenInitialized: (ChewieController chewieController) => setState(() {
              _controller = chewieController;
              !_controller.isPlaying ? _controller.play() : null;
            })));
    if (_controller == null) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    }
    return widgets;
  }

  Widget retakeButton() {
    return GestureDetector(
        onTap: () {
          _controller.pause();
          Navigator.pop(context);
          Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecording], arguments: {
            'taskId':widget.taskId,
            'taskIndex': widget.taskIndex,
            'isPublic': widget.isPublic,
            'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask,
            'fromCompletedClass': false
          });
        },
        child: Align(
            child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 8),
                child: Text(
                  OlukoLocalizations.get(context, 'retake'),
                  style:
                      OlukoFonts.olukoBigFont(customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary),
                ))));
  }

  Widget content() {
    return Column(children: [
      ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 1.5), child: Stack(children: showVideoPlayer())),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Row(children: [
            OlukoPrimaryButton(
              title: OlukoLocalizations.get(context, 'done'),
              onPressed: () async {
                _controller.pause();
                if (_taskSubmission == null) {
                  BlocProvider.of<TaskSubmissionBloc>(context)
                      .createTaskSubmission(_assessmentAssignment, _task, widget.isPublic, widget.isLastTask);
                } else {
                  createVideo(_taskSubmission, _assessmentAssignment, _assessment);
                }
              },
            )
          ]))
    ]);
  }

  Widget neumorphicContent() {
    return Column(children: [
      ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 100), child: Stack(children: showVideoPlayer())),
    ]);
  }
}
