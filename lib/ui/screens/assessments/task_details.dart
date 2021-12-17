import 'dart:developer';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/oluko_permissions.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class TaskDetails extends StatefulWidget {
  const TaskDetails({this.taskIndex, this.isLastTask = false, Key key, this.isComingFromCoach = false}) : super(key: key);

  final int taskIndex;
  final bool isLastTask;
  final bool isComingFromCoach;

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  bool _makePublic;
  AssessmentAssignment _assessmentAssignment;
  TaskSubmission _taskSubmission;
  Task _task;
  List<Task> _tasks;
  UserResponse _user;
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      if (Navigator.canPop(context)) {
        return true;
      } else {
        Navigator.pushNamed(context, routeLabels[RouteEnum.root]);
        return false;
      }
    }, child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        return BlocBuilder<AssessmentAssignmentBloc, AssessmentAssignmentState>(
          builder: (context, assessmentAssignmentState) {
            return BlocBuilder<TaskBloc, TaskState>(builder: (context, taskState) {
              if (assessmentAssignmentState is AssessmentAssignmentSuccess && taskState is TaskSuccess) {
                _assessmentAssignment = assessmentAssignmentState.assessmentAssignment;
                _tasks = taskState.values;
                _task = _tasks[widget.taskIndex];
                BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionOfTask(_assessmentAssignment, _task);
                return form();
              } else {
                return nil;
              }
            });
          },
        );
      } else {
        return nil;
      }
    }));
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: OlukoAppBar(
                title: _task.name,
                actions: [SizedBox(width: 30)],
                onPressed: () {
                  if (_controller != null) {
                    _controller.pause();
                  }
                  Navigator.pop(context);
                  if (!Navigator.canPop(context)) {
                    Navigator.pushNamed(context, routeLabels[RouteEnum.root], arguments: {
                      'tab': 1,
                    });
                  }
                }),
            body: Container(
                color: Colors.black,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - kToolbarHeight,
                      child: _content(),
                    )))));
  }

  Widget showVideoPlayer(String videoUrl) {
    final List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) => setState(() {
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
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              OlukoLocalizations.get(context, 'makeThisPublic'),
              style: OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.bold),
            ),
            Switch(
              value: _makePublic ?? false,
              onChanged: (bool value) => setState(() {
                if (taskSubmission != null) {
                  _makePublic = value;
                  BlocProvider.of<TaskSubmissionBloc>(context)
                      .updateTaskSubmissionPrivacity(_assessmentAssignment, taskSubmission.id, value);
                } else {
                  AppMessages.showSnackbarTranslated(context, 'noVideoUploaded');
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
      recordedVideos(_taskSubmission),
    ]));
  }

  Widget _content() {
    return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(buildWhen: (previous, current) {
      if (current is GetSuccess) {
        if (current.taskSubmission != null && current.taskSubmission.task.id != _task.id) {
          return false;
        }
        if (previous is GetSuccess && current.taskSubmission != null && current.taskSubmission.id == previous?.taskSubmission?.id) {
          return false;
        }
        if (previous is! GetSuccess &&
            _taskSubmission != null &&
            current.taskSubmission != null &&
            current.taskSubmission.id == _taskSubmission.id) {
          return false;
        }
      }
      return true;
    }, builder: (context, state) {
      if (state is GetSuccess && state.taskSubmission != null && state.taskSubmission?.task?.id == _task.id) {
        _taskSubmission = state.taskSubmission;
        _makePublic ??= _taskSubmission.isPublic;

        return ListView(
          children: [
            const SizedBox(height: 20),
            showVideoPlayer(_task.video),
            formSection(state.taskSubmission),
            recordAgainButtons(state.taskSubmission)
          ],
        );
      } else {
        _taskSubmission = null;
        return Stack(
          children: [
            ListView(
              children: [
                const SizedBox(height: 20),
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
      children: [
        OlukoPrimaryButton(
          title: OlukoLocalizations.get(context, 'startRecording'),
          onPressed: () {
            if (_controller != null) {
              _controller.pause();
            }
            Navigator.pop(context);
            return Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecording], arguments: {
              'taskIndex': widget.taskIndex,
              'isPublic': _makePublic ?? false,
              'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask
            });
          },
        ),
        const SizedBox(width: 15),
        BlocListener<GalleryVideoBloc, GalleryVideoState>(
            listener: (context, state) {
              if (state is Success && state.pickedFile != null) {
                Navigator.pop(context);
                Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecordingPreview], arguments: {
                  'taskIndex': widget.taskIndex,
                  'filePath': state.pickedFile.path,
                  'isPublic': _makePublic ?? false,
                  'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask
                });
              }
            },
            child: GestureDetector(
              onTap: () {
                BlocProvider.of<GalleryVideoBloc>(context).getVideoFromGallery();
              },
              child: const Icon(
                Icons.file_upload,
                size: 30,
                color: OlukoColors.grayColor,
              ),
            )),
      ],
    );
  }

  Widget recordAgainButtons(TaskSubmission taskSubmission) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Row(
          children: [
            OlukoOutlinedButton(
              thinPadding: true,
              title: OlukoLocalizations.get(context, 'recordAgain'),
              onPressed: () {
                DialogUtils.getDialog(context, _confirmDialogContent(taskSubmission), showExitButton: false);
              },
            ),
            const SizedBox(width: 20),
            BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
              if (authState is AuthSuccess) {
                _user = authState.user;
                return OlukoPrimaryButton(
                  isDisabled: OlukoPermissions.isAssessmentTaskDisabled(_user, widget.taskIndex + 1),
                  title: OlukoLocalizations.get(context, 'next'),
                  onPressed: () {
                    if (OlukoPermissions.isAssessmentTaskDisabled(_user, widget.taskIndex + 1)) {
                      AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'yourCurrentPlanDoesntIncludeAssessment'));
                    } else {
                      if (_controller != null) {
                        _controller.pause();
                      }
                      //Navigator.pop(context);
                      if (widget.taskIndex < _tasks.length - 1) {
                        Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.taskDetails], arguments: {
                          'taskIndex': widget.taskIndex + 1,
                          'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask
                        });
                      } else {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.assessmentVideos],
                              arguments: {'isFirstTime': false});
                        }
                      }
                    }
                  },
                );
              } else {
                return null;
              }
            })
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
                child: TitleBody(OlukoLocalizations.get(context, 'recordAgainQuestion'), bold: true)),
            Text(OlukoLocalizations.get(context, 'recordAgainWarning'), textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont()),
            Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Row(
                  children: [
                    OlukoPrimaryButton(
                      title: OlukoLocalizations.get(context, 'no'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 20),
                    OlukoOutlinedButton(
                      title: OlukoLocalizations.get(context, 'yes'),
                      onPressed: () {
                        if (_controller != null) {
                          _controller.pause();
                        }
                        Navigator.pop(context);
                        //Navigator.pop(context);
                        return Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecording], arguments: {
                          'taskIndex': widget.taskIndex,
                          'isPublic': _makePublic,
                          'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask
                        });
                      },
                    ),
                  ],
                ))
          ]))
    ];
  }

  Widget recordedVideos(TaskSubmission taskSubmission) {
    return taskSubmission == null
        ? const SizedBox()
        : Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: TitleBody(
                    OlukoLocalizations.get(context, 'recordedVideo'),
                    bold: true,
                  )),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 150,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  GestureDetector(
                      onTap: () {
                        if (_controller != null) {
                          _controller.pause();
                        }
                        if (taskSubmission.video != null && taskSubmission.video.url != null) {
                          Navigator.pushNamed(context, routeLabels[RouteEnum.taskSubmissionVideo],
                              arguments: {'task': _task, 'videoUrl': taskSubmission.video.url});
                        }
                      },
                      child: taskResponse(
                          TimeConverter.durationToString(
                              Duration(milliseconds: taskSubmission == null ? 0 : taskSubmission?.video?.duration)),
                          taskSubmission?.video?.thumbUrl,
                          taskSubmission)),
                ]),
              ),
            ),
          ]);
  }

  Widget taskResponse(String timeLabel, String thumbnail, TaskSubmission taskSubmission) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
          onTap: () {
            if (_controller != null) {
              _controller.pause();
            }
            Navigator.pushNamed(context, routeLabels[RouteEnum.taskSubmissionVideo],
                arguments: {'task': _task, 'videoUrl': taskSubmission.video.url});
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Stack(alignment: AlignmentDirectional.center, children: [
              if (thumbnail == null) const Icon(Icons.no_photography) else Image.network(thumbnail),
              Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/assessment/play.png',
                    height: 40,
                    width: 60,
                  )),
              Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        timeLabel,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )),
            ]),
          )),
    );
  }
}
