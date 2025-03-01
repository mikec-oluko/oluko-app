import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/assessment_visibility_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_list_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/oluko_permissions.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/task_submission_service.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/task_card.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_custom_video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/user_utils.dart';

class AssessmentVideos extends StatefulWidget {
  const AssessmentVideos({this.isFirstTime, this.isForCoachPage = false, this.assessmentsDone = false, Key key}) : super(key: key);
  final bool isFirstTime;
  final bool isForCoachPage;
  final bool assessmentsDone;

  @override
  _AssessmentVideosState createState() => _AssessmentVideosState();
}

class _AssessmentVideosState extends State<AssessmentVideos> {
  final String _assessmentKey = 'emnsmBgZ13UBRqTS26Qd';
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  Assessment _assessment;
  UserResponse _user;
  AssessmentAssignment _assessmentAssignment;
  List<TaskSubmission> taskSubmissionsCompleted = [];
  int assessmentsTasksQty;
  bool isLastTask = false;
  bool _showDonePanel = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _assessmentAssignment = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return _popUpAction(context);
        },
        child: BlocListener<AssessmentAssignmentBloc, AssessmentAssignmentState>(
          listener: (context, assessmentAssignmentState) {
            _assessmentSuccessAction(assessmentAssignmentState, context);
          },
          child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
            if (authState is AuthSuccess) {
              _user = authState.user;
              BlocProvider.of<AssessmentBloc>(context).getById(_assessmentKey);
              return BlocBuilder<AssessmentBloc, AssessmentState>(builder: (context, assessmentState) {
                if (assessmentState is AssessmentSuccess && assessmentState.assessment != null) {
                  _assessment = assessmentState.assessment;
                  assessmentsTasksQty = UserUtils.getUserAssessmentsQty(_assessment, _user.currentPlan) ?? 0;
                  BlocProvider.of<TaskBloc>(context).get(_assessment);
                  BlocProvider.of<AssessmentAssignmentBloc>(context).getOrCreate(_user.id, _assessment);
                  return _assessmentForm();
                } else {
                  return const SizedBox.shrink();
                }
              });
            } else {
              return const SizedBox.shrink();
            }
          }),
        ));
  }

  Widget _assessmentForm() {
    return Form(
        key: _formKey,
        child: Scaffold(backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark, appBar: _getOlukoAppBar(), body: _assessmentsView()));
  }

  Container _assessmentsView() {
    return Container(
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        child: ListView(
            physics: OlukoNeumorphism.listViewPhysicsEffect,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(children: [
                    _assessmentVideoComponent(),
                    _assessmentDescriptionSection(),
                    _assessmentCardsSection(),
                  ])),
              _coachPageSpaceSection(),
              _assessmentDoneButtonPanel(),
            ]));
  }

  Visibility _assessmentDoneButtonPanel() => Visibility(visible: _showDonePanel, child: assessmentDoneBottomPanel(context));

  SizedBox _coachPageSpaceSection() => SizedBox(height: widget.isForCoachPage ? 0 : 20);

  BlocBuilder<AssessmentAssignmentBloc, AssessmentAssignmentState> _assessmentCardsSection() {
    return BlocBuilder<AssessmentAssignmentBloc, AssessmentAssignmentState>(builder: (context, assessmentAssignmentState) {
      if (assessmentAssignmentState is AssessmentAssignmentSuccess) {
        _assessmentAssignment = assessmentAssignmentState.assessmentAssignment;
        return Column(
          children: [
            BlocBuilder<TaskSubmissionListBloc, TaskSubmissionListState>(builder: (context, taskSubmissionListState) {
              if (taskSubmissionListState is GetTaskSubmissionSuccess) {
                taskSubmissionsCompleted = taskSubmissionListState.taskSubmissions;
                final completedTask = taskSubmissionListState.taskSubmissions.length;
                var enabledTask = 0;
                for (var i = 0; i < assessmentsTasksQty; i++) {
                  if (!OlukoPermissions.isAssessmentTaskDisabled(_user, i)) {
                    enabledTask++;
                  }
                }
                if (completedTask == enabledTask && _assessmentAssignment.completedAt == null) {
                  BlocProvider.of<TaskSubmissionBloc>(context).setCompleted(_assessmentAssignment.id).then((value) =>
                      {_assessmentAssignment.completedAt = value, BlocProvider.of<AssessmentAssignmentBloc>(context).getOrCreate(_user.id, _assessment)});
                } else if (completedTask != enabledTask && _assessmentAssignment.completedAt != null) {
                  BlocProvider.of<TaskSubmissionBloc>(context).setIncompleted(_assessmentAssignment.id);
                  _assessmentAssignment.completedAt = null;
                }
                return widget.isForCoachPage && OlukoNeumorphism.isNeumorphismDesign
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: taskCardsSection(taskSubmissionListState.taskSubmissions),
                      )
                    : taskCardsSection(taskSubmissionListState.taskSubmissions);
              } else {
                return const Padding(padding: EdgeInsets.only(top: 30), child: CircularProgressIndicator());
              }
            }),
          ],
        );
      }
      return const SizedBox();
    });
  }

  Padding _assessmentDescriptionSection() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: widget.isForCoachPage && OlukoNeumorphism.isNeumorphismDesign
            ? Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    OlukoLocalizations.get(context, 'coachPageAssessmentsText'),
                    textAlign: TextAlign.left,
                    style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white),
                  ),
                ),
              )
            : Text(
                _assessment.description,
                textAlign: TextAlign.left,
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white),
              ));
  }

  Padding _assessmentVideoComponent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: OrientationBuilder(
        builder: (context, orientation) {
          return widget.isForCoachPage
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: showVideoPlayer(VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: _assessment.videoHls, videoUrl: _assessment.video)),
                )
              : showVideoPlayer(VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: _assessment.videoHls, videoUrl: _assessment.video));
        },
      ),
    );
  }

  OlukoAppBar<dynamic> _getOlukoAppBar() {
    return OlukoAppBar(
      showActions: widget.isFirstTime,
      onPressed: widget.isForCoachPage
          ? () {
              if (_controller != null) {
                _controller.pause();
              }
              Navigator.popAndPushNamed(context, routeLabels[RouteEnum.root], arguments: {
                'tab': 1,
              });
            }
          : () {
              if (_controller != null) {
                _controller.pause();
              }
              Navigator.pop(context);
            },
      showTitle: true,
      showBackButton: widget.isFirstTime != true && widget.isForCoachPage != true,
      title: widget.isForCoachPage ? OlukoLocalizations.get(context, 'coach') : OlukoLocalizations.get(context, 'assessment'),
      actions: [skipButton()],
    );
  }

  Widget assessmentDoneBottomPanel(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
            bottom: widget.isForCoachPage
                ? ScreenUtils.smallScreen(context)
                    ? 0
                    : 48
                : 0),
        child: Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
          ),
          child: Row(children: [const Expanded(child: SizedBox()), Padding(padding: const EdgeInsets.only(right: 20), child: _doneButton())]),
        ));
  }

  Widget _doneButton() {
    return SizedBox(
      width: 100,
      child: OlukoNeumorphicPrimaryButton(
        title: OlukoLocalizations.get(context, 'done'),
        onPressed: () {
          if (_controller != null) {
            _controller.pause();
          }
          if (widget.isFirstTime) {
            BlocProvider.of<AssessmentVisibilityBloc>(context).setAsSeen(_user.id);
          }
          Navigator.pushNamed(
            context,
            routeLabels[RouteEnum.assessmentNeumorphicDone],
          );
        },
        isExpanded: false,
        customHeight: 60,
      ),
    );
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

  Widget taskCardsSection(List<TaskSubmission> taskSubmissions) {
    return Column(
      children: [
        BlocBuilder<TaskBloc, TaskState>(builder: (context, taskState) {
          if (taskState is TaskSuccess) {
            return ListView.builder(
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: taskState.values.length,
                shrinkWrap: true,
                itemBuilder: (context, int index) {
                  final Task task = taskState.values[index];
                  TaskSubmission taskSubmission = TaskSubmissionService.getTaskSubmissionOfTask(task, taskSubmissions);
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TaskCard(
                        task: task,
                        index: index,
                        isCompleted: taskSubmission != null && taskSubmission.video != null,
                        isPublic: isPublic(taskSubmission),
                        isDisabled: OlukoPermissions.isAssessmentTaskDisabled(_user, index),
                        onPressed: () {
                          taskCardOnPressed(index, taskSubmission);
                        },
                      ));
                });
          } else {
            return Padding(
                padding: const EdgeInsets.all(50.0),
                child: OlukoNeumorphism.isNeumorphismDesign
                    ? Container(
                        color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
                        child: OlukoCircularProgressIndicator())
                    : OlukoCircularProgressIndicator());
          }
        }),
      ],
    );
  }

  taskCardOnPressed(int index, TaskSubmission taskSubmission) {
    if (_controller != null) {
      _controller.pause();
    }
    if (OlukoPermissions.isAssessmentTaskDisabled(_user, index)) {
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'yourCurrentPlanDoesntIncludeAssessment'));
    } else {
      if ((assessmentsTasksQty - taskSubmissionsCompleted.length) == 1) {
        setState(() {
          isLastTask = true;
        });
      }
      BlocProvider.of<TaskSubmissionBloc>(context).setLoaderTaskSubmissionOfTask();
      return Navigator.pushNamed(context, routeLabels[RouteEnum.taskDetails],
              arguments: {'taskIndex': index, 'isLastTask': isLastTask, 'taskCompleted': taskSubmission != null && taskSubmission.video != null})
          .then((value) => BlocProvider.of<AssessmentBloc>(context).getById(_assessmentKey));
    }
    ;
  }

  bool isPublic(TaskSubmission taskSubmission) {
    if (taskSubmission == null) {
      return false;
    } else {
      return taskSubmission.isPublic;
    }
  }

  Widget skipButton() {
    if (widget.isFirstTime) {
      return GestureDetector(
          onTap: () async {
            await BlocProvider.of<AssessmentVisibilityBloc>(context).setAsSeen(_user.id);
            AppNavigator().returnToHome(context);
            BlocProvider.of<AssessmentVisibilityBloc>(context).setAssessmentVisibilityDefaultState();
          },
          child: Align(
              child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    OlukoLocalizations.get(context, 'skip'),
                    style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
                  ))));
    } else {
      return SizedBox();
    }
  }

  Future<bool> popUp(BuildContext context) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: OlukoColors.black,
        content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: ScreenUtils.height(context) * 0.4,
              child: Column(children: [
                Stack(alignment: Alignment.center, children: [
                  Image.asset(
                    'assets/assessment/green_ellipse.png',
                    scale: 2,
                  ),
                  Image.asset(
                    'assets/assessment/gray_check.png',
                    scale: 5,
                  )
                ]),
                Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
                    child: Text(
                      OlukoLocalizations.get(context, 'done!'),
                      style: OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.bold),
                    )),
                Text(
                  OlukoLocalizations.get(context, 'assessmentMessagePart1'),
                  textAlign: TextAlign.center,
                  style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
                ),
                Text(
                  OlukoLocalizations.get(context, 'assessmentMessagePart2'),
                  textAlign: TextAlign.center,
                  style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
                ),
              ]),
            )),
        actions: [
          Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Row(
                children: [
                  OlukoOutlinedButton(
                    title: OlukoLocalizations.get(context, 'goBack'),
                    thinPadding: true,
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  OlukoPrimaryButton(
                    title: OlukoLocalizations.get(context, 'ok'),
                    onPressed: () {
                      if (_controller != null) {
                        _controller.pause();
                      }
                      Navigator.pop(context);
                      result = true;
                    },
                  ),
                ],
              ))
        ],
      ),
    );

    return result;
  }

  bool _popUpAction(BuildContext context) {
    if (widget.isFirstTime) {
      return false;
    }
    if (Navigator.canPop(context)) {
      return true;
    } else {
      Navigator.pushNamed(context, routeLabels[RouteEnum.root]);
      return false;
    }
  }

  void _assessmentSuccessAction(AssessmentAssignmentState assessmentAssignmentState, BuildContext context) {
    if (assessmentAssignmentState is AssessmentAssignmentSuccess) {
      BlocProvider.of<TaskSubmissionListBloc>(context).get(assessmentAssignmentState.assessmentAssignment);
      if (assessmentAssignmentState.assessmentAssignment.completedAt != null) {
        if (!widget.assessmentsDone) {
          if (!_showDonePanel) {
            setState(() {
              _showDonePanel = true;
            });
          }
        }
      }
    }
  }
}
