import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/task_submission_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/self_recording.dart';
import 'package:oluko_app/ui/screens/task_submission_recorded_video.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class TaskDetails extends StatefulWidget {
  TaskDetails({this.task, this.user, this.tasks, this.index, Key key})
      : super(key: key);

  final Task task;
  User user;
  List<Task> tasks;
  int index;

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  bool _makePublic = false;

  TaskSubmissionBloc _taskSubmissionBloc;
  AssessmentAssignmentBloc _assessmentAssignmentBloc;

  AssessmentAssignment assessmentAssignment;

  @override
  void initState() {
    _taskSubmissionBloc = TaskSubmissionBloc();
    _assessmentAssignmentBloc = AssessmentAssignmentBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AssessmentAssignmentBloc>(
          create: (context) =>
              _assessmentAssignmentBloc..getOrCreate(widget.user),
        ),
        BlocProvider<TaskSubmissionBloc>(
          create: (context) => _taskSubmissionBloc,
        ),
      ],
      child: BlocBuilder<AssessmentAssignmentBloc, AssessmentAssignmentState>(
          builder: (context, state) {
        if (state is AssessmentAssignmentSuccess) {
          assessmentAssignment = state.assessmentAssignment;
          _taskSubmissionBloc
            ..getTaskSubmissionOfTask(assessmentAssignment, widget.task);
          return form();
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
            appBar: OlukoAppBar(title: widget.task.name),
            body: Container(
                color: Colors.black,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height:
                          MediaQuery.of(context).size.height - kToolbarHeight,
                      child: Stack(
                        children: [
                          ListView(
                            children: [
                              ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight: MediaQuery.of(context)
                                                  .orientation ==
                                              Orientation.portrait
                                          ? ScreenUtils.height(context) / 4
                                          : ScreenUtils.height(context) / 1.5,
                                      minHeight: MediaQuery.of(context)
                                                  .orientation ==
                                              Orientation.portrait
                                          ? ScreenUtils.height(context) / 4
                                          : ScreenUtils.height(context) / 1.5),
                                  child: Stack(children: showVideoPlayer())),
                              formSection(),
                            ],
                          ),
                          Positioned(
                              bottom: 25,
                              left: 0,
                              right: 0,
                              child: _actionButtons()),
                        ],
                      ),
                    )))));
  }

  List<Widget> showVideoPlayer() {
    List<Widget> widgets = [];
    widgets.add(OlukoVideoPlayer(
        autoPlay: false,
        videoUrl: widget.task.video,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    return widgets;
  }

  Widget formSection() {
    return Container(
        //height: MediaQuery.of(context).size.height / 1.75,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          formFields(),
        ]));
  }

  _actionButtons() {
    return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
        builder: (context, state) {
      if (state is GetSuccess && state.taskSubmission != null) {
        return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                OlukoOutlinedButton(
                  thinPadding: true,
                  title: OlukoLocalizations.of(context).find('recordAgain'),
                  onPressed: () {
                    MovementUtils.movementDialog(
                        context, _confirmDialogContent(state.taskSubmission),
                        showExitButton: false);
                  },
                ),
                SizedBox(width: 20),
                OlukoPrimaryButton(
                  title: OlukoLocalizations.of(context).find('next'),
                  onPressed: () {
                    if (widget.index < widget.tasks.length - 1) {
                      return Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return TaskDetails(
                            tasks: widget.tasks,
                            index: widget.index + 1,
                            user: widget.user,
                            task: widget.tasks[widget.index + 1]);
                      }));
                    }
                  },
                ),
              ],
            ));
      } else {
        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            OlukoPrimaryButton(
              title: OlukoLocalizations.of(context).find('startRecording'),
              onPressed: () {
                if (_controller != null) {
                  _controller.pause();
                }
                return Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelfRecording(
                            task: widget.task,
                            assessmentAssignment: assessmentAssignment,
                            user: widget.user)));
              },
            ),
          ],
        );
      }
    });
  }

  List<Widget> _confirmDialogContent(TaskSubmission taskSubmission) {
    return [
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: TitleBody(
                    OlukoLocalizations.of(context).find('recordAgainQuestion'),
                    bold: true)),
            Text(OlukoLocalizations.of(context).find('recordAgainWarning'),
                textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont()),
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelfRecording(
                                    recordedTaskSubmission: taskSubmission,
                                    task: widget.task,
                                    assessmentAssignment: assessmentAssignment,
                                    user: widget.user)));
                      },
                    ),
                  ],
                ))
          ]))
    ];
  }

  Widget formFields() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TitleBody(
                'Make this public',
                bold: true,
              ),
              Switch(
                value: _makePublic,
                onChanged: (bool value) => this.setState(() {
                  _makePublic = value;
                }),
                trackColor: MaterialStateProperty.all(Colors.grey),
                activeColor: OlukoColors.primary,
              )
            ],
          ),
        ),
        Text(
          widget.task.description,
          style: OlukoFonts.olukoMediumFont(),
        ),
        BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
            builder: (context, state) {
          if (state is GetSuccess && state.taskSubmission != null) {
            return recordedVideos(state.taskSubmission);
          } else {
            return SizedBox();
          }
        })
      ],
    );
  }

  recordedVideos(TaskSubmission taskSubmission) {
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
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TaskSubmissionRecordedVideo(
                    task: widget.task, videoUrl: taskSubmission.video.url))),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            height: 150,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              taskResponse(
                  TimeConverter.fromMillisecondsToSecondsStringFormat(
                      taskSubmission.video.duration),
                  taskSubmission.video.thumbUrl),
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
          Image.network(thumbnail),
          Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/assessment/play.png",
                height: 40,
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
