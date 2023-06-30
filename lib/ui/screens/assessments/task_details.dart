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
import 'package:oluko_app/helpers/video_player_helper.dart';
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
import 'package:oluko_app/ui/newDesignComponents/oluko_custom_video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/record_again_panel_options.dart';
import 'package:oluko_app/ui/newDesignComponents/task_details_form_content.dart';
import 'package:oluko_app/ui/newDesignComponents/task_recorded_preview_card.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/permissions_utils.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:oluko_app/utils/user_utils.dart';

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
  final GlobalService _globalService = GlobalService();
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
  bool canShowPanel = false;
  double panelSize = 100;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          return BlocBuilder<AssessmentAssignmentBloc, AssessmentAssignmentState>(
            builder: (context, assessmentAssignmentState) {
              if (assessmentAssignmentState is AssessmentAssignmentSuccess) {
                _assessmentAssignment = assessmentAssignmentState.assessmentAssignment;
              }
              return BlocBuilder<TaskBloc, TaskState>(
                builder: (context, taskState) {
                  if (taskState is TaskSuccess) {
                    _tasks = taskState.values;
                    _task = _tasks[widget.taskIndex];
                    BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionOfTask(_assessmentAssignment, _task.id);
                  }
                  return _taskDetailsView();
                },
              );
            },
          );
        } else {
          return nil;
        }
      },
    );
  }

  Widget _taskDetailsView() {
    return BlocListener<TaskCardBloc, TaskCardState>(
      listener: (context, taskCardState) {
        if (taskCardState is TaskCardVideoProcessing && taskCardState.taskIndex == widget.taskIndex) {
          setState(() {
            _isLoading = true;
          });
        } else if (taskCardState is TaskCardVideoUploaded) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
        builder: (context, state) {
          if (state is GetSuccess) {
            if (state.taskSubmission != null && state.taskSubmission.task.id == _task.id) {
              isAssessmentDone = true;
              _taskSubmission = state.taskSubmission;
              _makePublic = _taskSubmission.isPublic;
            }
            _isLoading = false;
            canShowPanel = true;
          }
          if (state is TaskSubmissionLoading) {
            _isLoading = true;
          }
          return WillPopScope(
            onWillPop: () async {
              if (Navigator.canPop(context)) {
                return true;
              } else {
                Navigator.pushNamed(context, routeLabels[RouteEnum.root]);
                return false;
              }
            },
            child: Scaffold(
                backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                appBar: OlukoAppBar(
                    showTitle: true,
                    showBackButton: true,
                    title: _task.name,
                    actions: const [SizedBox(width: 30)],
                    onPressed: () {
                      _onButtonBackPress();
                    }),
                body: _ligthBody(context),
                bottomSheet: OlukoNeumorphism.isNeumorphismDesign ? _bottomPanel(context) : const SizedBox.shrink()),
          );
        },
      ),
    );
  }

  Container _bottomPanel(BuildContext context) {
    return Container(
      width: ScreenUtils.width(context),
      height: panelSize,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
      ),
      child: canShowPanel
          ? showPanel()
          : _isLoading
              ? Center(child: OlukoCircularProgressIndicator())
              : const SizedBox.shrink(),
    );
  }

  Container _ligthBody(BuildContext context) {
    return Container(
      color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
      child: ListView(
        physics: OlukoNeumorphism.listViewPhysicsEffect,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          const SizedBox(height: 20),
          showVideoPlayer(VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: _task.videoHls, videoUrl: _task.video)),
          formSection(_taskSubmission),
          if (OlukoNeumorphism.isNeumorphismDesign)
            SizedBox(height: ScreenUtils.height(context) * 0.2)
          else
            Positioned(bottom: 25, left: 0, right: 0, child: _taskSubmission != null ? recordAgainButtons(_taskSubmission) : startRecordingButton())
        ],
      ),
    );
  }

  Widget showPanel() {
    return isAssessmentDone
        ? recordAgainRequested
            ? recordAgainDialogContent()
            : recordAgainButtons(_taskSubmission)
        : _taskSubmission == null || isAssessmentDone
            ? startRecordingButton()
            : const SizedBox.shrink();
  }

  void _onButtonBackPress() {
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
  }

  Widget showVideoPlayer(String videoUrl) {
    return OlukoCustomVideoPlayer(
        videoUrl: videoUrl,
        useConstraints: true,
        roundedBorder: OlukoNeumorphism.isNeumorphismDesign,
        isOlukoControls: !UserUtils.userDeviceIsIOS(),
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) => setState(() {
              _controller = chewieController;
            }));
  }

  Widget formSection([TaskSubmission taskSubmission]) {
    return TaskDetailsFormSection(
      makeThisPublic: _makePublic,
      taskDescription: _task.description,
      recordedVideo: recordedVideos(_taskSubmission),
      switchUpdated: (value) => switchChanged(taskSubmission, value),
    );
  }

  void switchChanged(TaskSubmission taskSubmission, bool value) {
    if (taskSubmission != null) {
      setState(() {
        _makePublic = value;
        //BlocProvider.of<TaskPrivacityBloc>(context).set(value);
        BlocProvider.of<TaskSubmissionBloc>(context).updateTaskSubmissionPrivacity(_assessmentAssignment, taskSubmission.id, value);
      });
    } else {
      AppMessages.clearAndShowSnackbarTranslated(context, 'noVideoUploaded');
    }
  }

  Widget startRecordingButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
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
                  PermissionsUtils.showSettingsMessage(context, permissionsRequired: [state.permissionRequired]);
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
      ),
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
      'isLastTask': widget.isLastTask ?? lastTask(),
      'fromCompletedClass': false
    });
  }

  bool lastTask() => (_tasks.length - widget.taskIndex) == 1;

  Widget recordAgainButtons(TaskSubmission taskSubmission) {
    return Padding(
        padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20) : const EdgeInsets.only(top: 20.0),
        child: Row(
          children: [
            if (OlukoNeumorphism.isNeumorphismDesign)
              OlukoNeumorphicSecondaryButton(
                lighterButton: true,
                buttonShape: NeumorphicShape.flat,
                useBorder: true,
                thinPadding: true,
                textColor: OlukoColors.grayColor,
                onPressed: () {
                  if (OlukoNeumorphism.isNeumorphismDesign) {
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
            else
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
              padding: const EdgeInsets.symmetric(vertical: 20),
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
        Navigator.pushNamed(context, routeLabels[RouteEnum.taskDetails],
            arguments: {'taskIndex': widget.taskIndex + 1, 'isLastTask': widget.isLastTask ?? lastTask(), 'taskCompleted': false});
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

  RecordAgainPanelOptions recordAgainDialogContent() {
    return RecordAgainPanelOptions(
      recordAgainActions: () => _recordAgainAcceptAction(),
      cancelRecordAction: () => _recordAgainCancel(),
    );
  }

  void _recordAgainCancel() {
    OlukoNeumorphism.isNeumorphismDesign
        ? setState(() {
            recordAgainRequested = !recordAgainRequested;
            panelSize = 100;
          })
        : Navigator.pop(context);
  }

  Future<Object> _recordAgainAcceptAction() {
    setState(() {
      panelSize = 100;
    });
    if (_controller != null) {
      _controller.pause();
    }
    Navigator.pop(context);
    return Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecording], arguments: {
      'taskId': _task.id,
      'taskIndex': widget.taskIndex,
      'isPublic': _makePublic,
      'isLastTask': widget.isLastTask ?? lastTask(),
      'fromCompletedClass': false
    });
  }

  Widget recordedVideos(TaskSubmission taskSubmission) {
    return BlocBuilder<TaskCardBloc, TaskCardState>(builder: (context, taskCardState) {
      if (taskCardState is TaskCardVideoProcessing && taskCardState.taskIndex == widget.taskIndex || isAssessmentDone || widget.taskCompleted || _isLoading) {
        return Column(children: [
          if (taskSubmission == null)
            const SizedBox(
              height: 20,
            )
          else
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
              child: ListView(
                  physics: OlukoNeumorphism.listViewPhysicsEffect,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  scrollDirection: Axis.horizontal,
                  children: [
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
        return const SizedBox.shrink();
      }
    });
  }

  Widget taskResponse(String timeLabel, String thumbnail, TaskSubmission taskSubmission) {
    return BlocBuilder<TaskCardBloc, TaskCardState>(builder: (context, taskCardState) {
      if (taskCardState is TaskCardVideoProcessing && taskCardState.taskIndex == widget.taskIndex) {
        return const TaskRecordedPreviewCard();
      } else if (taskCardState is TaskCardVideoUploaded && taskCardState.taskId == _task.id) {
        return TaskRecordedPreviewCard(
          thumbnail: thumbnail,
          timeLabel: timeLabel,
          taskReady: thumbnail != null,
        );
      } else {
        return taskSubmission != null
            ? TaskRecordedPreviewCard(
                thumbnail: thumbnail,
                timeLabel: timeLabel,
                taskReady: thumbnail != null,
              )
            : const SizedBox.shrink();
      }
    });
  }
}
