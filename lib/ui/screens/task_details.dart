import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/self_recording.dart';
import 'package:oluko_app/ui/screens/task_submission_recorded_video.dart';
import 'package:oluko_app/ui/screens/task_submission_review.dart';
import 'package:oluko_app/ui/screens/self_recording_preview.dart';
import 'package:oluko_app/ui/screens/task_submission_review_preview.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class TaskDetails extends StatefulWidget {
  TaskDetails({this.task, this.showRecordedVideos = false, Key key})
      : super(key: key);

  final Task task;
  final bool showRecordedVideos;

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  bool _makePublic = false;
  TaskSubmissionBloc _taskSubmissionBloc;

  @override
  void initState() {
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
        BlocProvider<TaskSubmissionBloc>(
          create: (context) =>
              _taskSubmissionBloc..getTaskSubmissionOfTask(widget.task),
        ),
      ],
      child: form(),
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
                      child: ListView(
                        children: [
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).orientation ==
                                              Orientation.portrait
                                          ? ScreenUtils.height(context) / 4
                                          : ScreenUtils.height(context) / 1.5,
                                  minHeight:
                                      MediaQuery.of(context).orientation ==
                                              Orientation.portrait
                                          ? ScreenUtils.height(context) / 4
                                          : ScreenUtils.height(context) / 1.5),
                              child: Stack(children: showVideoPlayer())),
                          BlocBuilder<TaskBloc, TaskState>(
                              builder: (context, state) {
                            return formSection();
                          }),
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
      height: MediaQuery.of(context).size.height / 1.75,
      child: BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
        return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              formFields(state),
              BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
                  builder: (context, state) {
                if (state is GetSuccess && state.taskSubmission != null) {
                  return SizedBox() /*Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      OlukoPrimaryButton(
                        title: 'Send Feedback',
                        onPressed: () {
                          if (_controller != null) {
                            _controller.pause();
                          }
                          return Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TaskSubmissionReview(
                                      taskSubmission: state.taskSubmission)));
                        },
                      ),
                    ],
                  )*/;
                } else {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      OlukoPrimaryButton(
                        title: OlukoLocalizations.of(context)
                            .find('startRecording'),
                        onPressed: () {
                          if (_controller != null) {
                            _controller.pause();
                          }
                          return Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SelfRecording(task: widget.task)));
                        },
                      ),
                    ],
                  );
                }
              }),     
            ]);
      }),
    );
  }

  Widget formFields(TaskState state) {
    if (state is TaskSuccess) {
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
    } else {
      return SizedBox();
    }
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
