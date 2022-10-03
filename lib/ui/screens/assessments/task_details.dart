import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_card_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/oluko_permissions.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_switch.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/permissions_utils.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:oluko_app/utils/user_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class TaskDetails extends StatefulWidget {
  const TaskDetails({this.taskIndex, this.isLastTask = false, Key key, this.isComingFromCoach = false, this.taskCompleted = false}) : super(key: key);

  final int taskIndex;
  final bool isLastTask;
  final bool isComingFromCoach;
  final bool taskCompleted;
  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  GlobalService _globalService = GlobalService();
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  bool _makePublic = false;
  AssessmentAssignment _assessmentAssignment;
  TaskSubmission _taskSubmission;
  Task _task;
  List<Task> _tasks;
  UserResponse _user;
  bool isFirstTime = true;
  bool isAssessmentDone = false;
  bool recordAgainRequested = false;
  double panelSize = 100;
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (Navigator.canPop(context)) {
            return true;
          } else {
            Navigator.pushNamed(context, routeLabels[RouteEnum.root]);
            return false;
          }
        },
        child: BlocListener<TaskCardBloc, TaskCardState>(listener: (context, taskCardState) {
          if (taskCardState is TaskCardVideoProcessing && taskCardState.taskIndex == widget.taskIndex) {
            setState(() {
              _isLoading = true;
            });
          } else if (taskCardState is TaskCardVideoUploaded) {
            setState(() {
              _isLoading = false;
            });
          }
        }, child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
          if (authState is AuthSuccess) {
            return BlocBuilder<AssessmentAssignmentBloc, AssessmentAssignmentState>(
              builder: (context, assessmentAssignmentState) {
                if (assessmentAssignmentState is AssessmentAssignmentSuccess) {
                  return BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, taskState) {
                      if (taskState is TaskSuccess) {
                        _assessmentAssignment = assessmentAssignmentState.assessmentAssignment;
                        _tasks = taskState.values;
                        _task = _tasks[widget.taskIndex];
                        BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionOfTask(_assessmentAssignment, _task.id);
                        return OlukoNeumorphism.isNeumorphismDesign ? neumorphicForm() : form();
                      } else {
                        return nil;
                      }
                    },
                  );
                } else {
                  return nil;
                }
              },
            );
          } else {
            return nil;
          }
        })));
  }

  Widget neumorphicForm() {
    Widget _panelContent = startRecordingButton();
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: OlukoAppBar(
            showTitle: true,
            showBackButton: true,
            title: _task.name,
            actions: [SizedBox(width: 30)],
            onPressed: () {
              if (_controller != null) {
                _controller.pause();
              }
              if (!Navigator.canPop(context)) {
                Navigator.pushNamed(context, routeLabels[RouteEnum.root], arguments: {
                  'tab': 1,
                });
              } else {
                Navigator.pop(context);
              }
            }),
        body: BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
          buildWhen: (previous, current) => previous is! GetSuccess && current is GetSuccess,
          builder: (context, state) {
            if (state is GetSuccess && state.taskSubmission != null && state.taskSubmission.task.id == _task.id) {
              isAssessmentDone = true;
              _makePublic = state.taskSubmission.isPublic;
              _panelContent = isAssessmentDone ? recordAgainButtons(_taskSubmission) : startRecordingButton();
            } else if (state is TaskSubmissionLoading) {
              _panelContent = Center(child: OlukoCircularProgressIndicator());
            } else {
              _panelContent = startRecordingButton();
            }
            return recordAgainRequested
                ? SlidingUpPanel(
                    controller: _panelController,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                    maxHeight: panelSize,
                    panel: recordAgainDialogContent(),
                    body: viewContent(),
                  )
                : SlidingUpPanel(
                    controller: _panelController,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                    maxHeight: panelSize,
                    panel: recordAgainRequested
                        ? recordAgainDialogContent()
                        : Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: isAssessmentDone || widget.taskCompleted
                                  ? recordAgainButtons(_taskSubmission)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [Container(height: 60, width: MediaQuery.of(context).size.width / 1.2, child: _panelContent)]),
                            ),
                          ),
                    body: viewContent(),
                  );
          },
        ),
      ),
    );
  }

  Container viewContent() {
    return Container(
        color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              child: _content(),
            )));
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: OlukoAppBar(
                showTitle: true,
                showBackButton: true,
                title: _task.name,
                actions: [SizedBox(width: 30)],
                onPressed: () {
                  if (_controller != null) {
                    _controller.pause();
                  }
                  if (!Navigator.canPop(context)) {
                    Navigator.pushNamed(context, routeLabels[RouteEnum.root], arguments: {
                      'tab': 1,
                    });
                  } else {
                    Navigator.pop(context);
                  }
                }),
            body: Container(
                color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
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
        isOlukoControls: !UserUtils.userDeviceIsIOS(),
        showOptions: true,
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) {
          _controller = chewieController;
        }));

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).orientation == Orientation.portrait ? ScreenUtils.height(context) / 4 : ScreenUtils.height(context) / 1.5,
            minHeight: MediaQuery.of(context).orientation == Orientation.portrait ? ScreenUtils.height(context) / 4 : ScreenUtils.height(context) / 1.5),
        child: Container(height: 400, child: Stack(children: widgets)));
  }

  Widget formSection([TaskSubmission taskSubmission]) {
    return Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              OlukoLocalizations.get(context, 'makeThisPublic'),
              style: OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.bold),
            ),
            OlukoNeumorphism.isNeumorphismDesign
                ? OlukoNeumorphicSwitch(
                    value: _makePublic ?? false,
                    onSwitchChange: (bool value) {
                      if (taskSubmission != null) {
                        setState(() {
                          _makePublic = value;
                          //BlocProvider.of<TaskPrivacityBloc>(context).set(value);
                          BlocProvider.of<TaskSubmissionBloc>(context).updateTaskSubmissionPrivacity(_assessmentAssignment, taskSubmission.id, value);
                        });
                      } else {
                        AppMessages.clearAndShowSnackbarTranslated(context, 'noVideoUploaded');
                      }
                      ;
                    },
                  )
                : Switch(
                    value: _makePublic ?? false,
                    onChanged: (bool value) => setState(() {
                      if (taskSubmission != null) {
                        _makePublic = value;
                        BlocProvider.of<TaskSubmissionBloc>(context).updateTaskSubmissionPrivacity(_assessmentAssignment, taskSubmission.id, value);
                      } else {
                        AppMessages.clearAndShowSnackbarTranslated(context, 'noVideoUploaded');
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
        if (previous is GetSuccess &&
            current.taskSubmission != null &&
            current.taskSubmission.id == previous?.taskSubmission?.id &&
            current.taskSubmission.video != null &&
            current.taskSubmission.video.url == previous?.taskSubmission?.video?.url &&
            _taskSubmission.video != null) {
          return false;
        }
        if (previous is! GetSuccess && _taskSubmission != null && current.taskSubmission != null && current.taskSubmission.id == _taskSubmission.id) {
          return false;
        }
      }
      return true;
    }, builder: (context, state) {
      if (state is TaskSubmissionLoading) {
        return Stack(
          children: [
            ListView(
              children: [
                const SizedBox(height: 20),
                showVideoPlayer(_task.videoHls ?? _task.video),
                formSection(),
              ],
            ),
            if (!OlukoNeumorphism.isNeumorphismDesign) const Positioned(bottom: 25, left: 0, right: 0, child: SizedBox.shrink()),
          ],
        );
      }

      if (state is GetSuccess && state.taskSubmission != null && state.taskSubmission?.task?.id == _task.id) {
        _taskSubmission = state.taskSubmission;
        _makePublic ??= _taskSubmission.isPublic;
        isAssessmentDone = true;
        return ListView(
          children: [
            const SizedBox(height: 20),
            showVideoPlayer(_task.videoHls ?? _task.video),
            formSection(state.taskSubmission),
            if (OlukoNeumorphism.isNeumorphismDesign) SizedBox(height: ScreenUtils.height(context) * 0.4) else recordAgainButtons(state.taskSubmission)
          ],
        );
      } else {
        _taskSubmission = null;
        return Stack(
          children: [
            ListView(
              children: [
                const SizedBox(height: 20),
                showVideoPlayer(_task.videoHls ?? _task.video),
                formSection(),
              ],
            ),
            if (!OlukoNeumorphism.isNeumorphismDesign) Positioned(bottom: 25, left: 0, right: 0, child: startRecordingButton()),
          ],
        );
      }
    });
  }

  Widget startRecordingButton() {
    return Row(
      children: [
        if (OlukoNeumorphism.isNeumorphismDesign)
          OlukoNeumorphicPrimaryButton(
            thinPadding: true,
            title: OlukoLocalizations.get(context, 'startRecording'),
            onPressed: () {
              startRecordingAction();
            },
          )
        else
          OlukoPrimaryButton(
            title: OlukoLocalizations.get(context, 'startRecording'),
            onPressed: () {
              startRecordingAction();
            },
          ),
        const SizedBox(width: 15),
        BlocListener<GalleryVideoBloc, GalleryVideoState>(
            listener: (context, state) {
              if (state is Success && state.pickedFile != null) {
                Navigator.pop(context);
                Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecordingPreview], arguments: {
                  'taskId': _task.id,
                  'taskIndex': widget.taskIndex,
                  'filePath': state.pickedFile.path,
                  'isPublic': _makePublic ?? false,
                  'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask,
                  'fromCompletedClass': false
                });
              } else if (state is PermissionsRequired) {
                PermissionsUtils.showSettingsMessage(context);
              } else if (state is UploadFailure && state.badFormat) {
                AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'badVideoFormat'));
              }
            },
            child: GestureDetector(
              onTap: () {
                if (!_globalService.videoProcessing) {
                  BlocProvider.of<GalleryVideoBloc>(context).getVideoFromGallery();
                } else {
                  showDialog();
                }
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

  void startRecordingAction() {
    if (_controller != null) {
      _controller.pause();
    }
    Navigator.pop(context);
    Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecording], arguments: {
      'taskId': _task.id,
      'taskIndex': widget.taskIndex,
      'isPublic': _makePublic ?? false,
      'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask,
      'fromCompletedClass': false
    });
  }

  Widget recordAgainButtons(TaskSubmission taskSubmission) {
    return Padding(
        padding: OlukoNeumorphism.isNeumorphismDesign ? EdgeInsets.only(top: 20.0).copyWith(bottom: 20) : EdgeInsets.only(top: 20.0),
        child: Row(
          children: [
            OlukoNeumorphism.isNeumorphismDesign
                ? OlukoNeumorphicSecondaryButton(
                    lighterButton: true,
                    buttonShape: NeumorphicShape.flat,
                    useBorder: true,
                    thinPadding: true,
                    textColor: OlukoColors.grayColor,
                    onPressed: () {
                      if (OlukoNeumorphism.isNeumorphismDesign) {
                        _panelController.animatePanelToPosition(1.0);
                        setState(() {
                          recordAgainRequested = !recordAgainRequested;
                          panelSize = 250;
                        });
                      } else {
                        DialogUtils.getDialog(context, _confirmDialogContent(taskSubmission), showExitButton: false);
                      }
                    },
                    title: OlukoLocalizations.get(context, 'recordAgain'),
                  )
                : OlukoOutlinedButton(
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
                return OlukoNeumorphism.isNeumorphismDesign
                    ? OlukoNeumorphicPrimaryButton(
                        title: OlukoLocalizations.get(context, 'next'),
                        onPressed: () {
                          nextAssessmentButtonOnPress(context);
                        },
                      )
                    : OlukoPrimaryButton(
                        isDisabled: OlukoPermissions.isAssessmentTaskDisabled(_user, widget.taskIndex + 1),
                        title: OlukoLocalizations.get(context, 'next'),
                        onPressed: () {
                          nextAssessmentButtonOnPress(context);
                        },
                      );
              } else {
                return null;
              }
            })
          ],
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

  void nextAssessmentButtonOnPress(BuildContext context) {
    if (OlukoPermissions.isAssessmentTaskDisabled(_user, widget.taskIndex + 1)) {
      goToAssessmentVideos();
    } else {
      if (_controller != null) {
        _controller.pause();
      }
      if (widget.taskIndex < _tasks.length - 1) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Navigator.pushNamed(context, routeLabels[RouteEnum.taskDetails], arguments: {
          'taskIndex': widget.taskIndex + 1,
          'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask,
          'taskCompleted': false /**TODO: */
        });
      } else {
        goToAssessmentVideos();
      }
    }
  }

  void goToAssessmentVideos() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.assessmentVideos],
          arguments: {'isFirstTime': false, 'assessmentsDone': _tasks.length - widget.taskIndex == 1});
    }
  }

  List<Widget> _confirmDialogContent(TaskSubmission taskSubmission) => [recordAgainDialogContent()];

  Padding recordAgainDialogContent() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Padding(padding: const EdgeInsets.only(bottom: 15.0), child: TitleBody(OlukoLocalizations.get(context, 'recordAgainQuestion'), bold: true)),
          Text(OlukoLocalizations.get(context, 'recordAgainWarning'), textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont()),
          Padding(
              padding: const EdgeInsets.only(top: OlukoNeumorphism.isNeumorphismDesign ? 80 : 25.0),
              child: Row(
                mainAxisAlignment: OlukoNeumorphism.isNeumorphismDesign ? MainAxisAlignment.end : MainAxisAlignment.center,
                children: [
                  OlukoNeumorphism.isNeumorphismDesign
                      ? TextButton(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              OlukoLocalizations.get(context, 'yes'),
                              style: OlukoFonts.olukoBigFont(),
                            ),
                          ),
                          onPressed: () {
                            if (_controller != null) {
                              _controller.pause();
                            }
                            Navigator.pop(context);
                            return Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecording], arguments: {
                              'taskId': _task.id,
                              'taskIndex': widget.taskIndex,
                              'isPublic': _makePublic,
                              'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask,
                              'fromCompletedClass': false
                            });
                          },
                        )
                      : OlukoPrimaryButton(
                          title: OlukoLocalizations.get(context, 'no'),
                          onPressed: () {
                            OlukoNeumorphism.isNeumorphismDesign
                                ? setState(() {
                                    recordAgainRequested = !recordAgainRequested;
                                  })
                                : Navigator.pop(context);
                          },
                        ),
                  const SizedBox(width: 20),
                  OlukoNeumorphism.isNeumorphismDesign
                      ? Container(
                          width: 80,
                          height: 50,
                          child: OlukoNeumorphicPrimaryButton(
                            thinPadding: true,
                            isExpanded: false,
                            title: OlukoLocalizations.get(context, 'no'),
                            onPressed: () {
                              OlukoNeumorphism.isNeumorphismDesign
                                  ? setState(() {
                                      recordAgainRequested = !recordAgainRequested;
                                    })
                                  : Navigator.pop(context);
                            },
                          ),
                        )
                      : OlukoOutlinedButton(
                          title: OlukoLocalizations.get(context, 'yes'),
                          onPressed: () {
                            if (_controller != null) {
                              _controller.pause();
                            }
                            Navigator.pop(context);
                            return Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecording], arguments: {
                              'taskId': _task.id,
                              'taskIndex': widget.taskIndex,
                              'isPublic': _makePublic,
                              'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask,
                              'fromCompletedClass': false
                            });
                          },
                        ),
                ],
              ))
        ]));
  }

  Widget recordedVideos(TaskSubmission taskSubmission) {
    return BlocBuilder<TaskCardBloc, TaskCardState>(builder: (context, taskCardState) {
      if (taskCardState is TaskCardVideoProcessing && taskCardState.taskIndex == widget.taskIndex || isAssessmentDone || widget.taskCompleted || _isLoading) {
        return Column(children: [
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
                            Duration(milliseconds: taskSubmission == null || taskSubmission.video == null ? 0 : taskSubmission?.video?.duration)),
                        taskSubmission?.video?.thumbUrl,
                        taskSubmission)),
              ]),
            ),
          ),
        ]);
      } else {
        return const SizedBox();
      }
    });
  }

  Widget taskResponse(String timeLabel, String thumbnail, TaskSubmission taskSubmission) {
    return BlocBuilder<TaskCardBloc, TaskCardState>(builder: (context, taskCardState) {
      if (taskCardState is TaskCardVideoProcessing && taskCardState.taskIndex == widget.taskIndex) {
        return Padding(padding: const EdgeInsets.only(left: 45), child: OlukoCircularProgressIndicator());
      } else if (taskCardState is TaskCardVideoUploaded && taskCardState.taskId == _task.id) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Stack(alignment: AlignmentDirectional.center, children: [
              if (thumbnail == null) const Image(image: AssetImage('assets/assessment/thumbnail.jpg')) else Image(image: CachedNetworkImageProvider(thumbnail)),
              Align(
                  alignment: Alignment.center,
                  child: OlukoNeumorphism.isNeumorphismDesign
                      ? Container(
                          width: 50,
                          height: 50,
                          child: OlukoBlurredButton(
                            childContent: Icon(
                              Icons.play_arrow,
                              color: OlukoColors.white,
                            ),
                          ),
                        )
                      : Image.asset(
                          'assets/assessment/play.png',
                          scale: 5,
                          height: 40,
                          width: 60,
                        )),
              Positioned(
                  top: OlukoNeumorphism.isNeumorphismDesign ? 10 : null,
                  bottom: !OlukoNeumorphism.isNeumorphismDesign ? 10 : null,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: OlukoColors.black.withAlpha(150),
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
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Stack(alignment: AlignmentDirectional.center, children: [
              if (thumbnail == null) const Image(image: AssetImage('assets/assessment/thumbnail.jpg')) else Image(image: CachedNetworkImageProvider(thumbnail)),
              Align(
                  alignment: Alignment.center,
                  child: OlukoNeumorphism.isNeumorphismDesign
                      ? Container(
                          width: 50,
                          height: 50,
                          child: OlukoBlurredButton(
                            childContent: Icon(
                              Icons.play_arrow,
                              color: OlukoColors.white,
                            ),
                          ),
                        )
                      : Image.asset(
                          'assets/assessment/play.png',
                          scale: 5,
                          height: 40,
                          width: 60,
                        )),
              Positioned(
                  top: OlukoNeumorphism.isNeumorphismDesign ? 10 : null,
                  bottom: !OlukoNeumorphism.isNeumorphismDesign ? 10 : null,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: OlukoColors.black.withAlpha(150),
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
          ),
        );
      }
    });
  }
}
