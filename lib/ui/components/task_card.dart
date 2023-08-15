import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/task_card_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function() onPressed;
  final bool isPublic;
  final bool isCompleted;
  final bool isDisabled;
  final bool useStartButton;
  final int index;

  TaskCard({this.task, this.onPressed, this.isCompleted = false, this.isPublic = false, this.isDisabled = false, this.useStartButton = false, this.index});

  @override
  _State createState() => _State();
}

class _State extends State<TaskCard> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign ? neumorphicTaskCard(context) : taskCard(context);
  }

  GestureDetector taskCard(BuildContext context) {
    return GestureDetector(
        onTap: () => widget.onPressed(),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: !widget.isDisabled ? OlukoColors.taskCardBackground : OlukoColors.taskCardBackgroundDisabled),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15, right: 10, left: 10),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        widget.task.name,
                                        style: OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: SizedBox()),
                                    Stack(alignment: Alignment.center, children: [
                                      Image.asset(
                                        'assets/assessment/check_ellipse.png',
                                        scale: 4,
                                      ),
                                      widget.isCompleted
                                          ? Image.asset(
                                              'assets/assessment/check.png',
                                              scale: 4,
                                            )
                                          : SizedBox()
                                    ])
                                  ]),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, right: 10),
                                    child: Text(
                                      widget.task.shortDescription,
                                      style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(children: [
                            getPrivacy(context),
                            Expanded(child: SizedBox()),
                            !widget.isDisabled
                                ? Stack(alignment: Alignment.center, children: [
                                    Image.asset(
                                      'assets/assessment/green_ellipse.png',
                                      scale: 4,
                                    ),
                                    Image.asset(
                                      'assets/home/right_icon.png',
                                      scale: 4,
                                    )
                                  ])
                                : SizedBox(),
                          ])),
                    ],
                  )),
            ),
          ),
        ));
  }

  Widget getPrivacy(BuildContext context) {
    bool public = widget.isPublic;
    return BlocListener<TaskSubmissionBloc, TaskSubmissionState>(
      listenWhen: (previous, current) {
        return current is PrivacyUpdatedSuccess;
      },
      listener: (context, state) {
        if (state is PrivacyUpdatedSuccess) {
          public = state.isPublic;
        }
      },
      child: Text(
        public ? OlukoLocalizations.get(context, 'public').toUpperCase() : OlukoLocalizations.get(context, 'private').toUpperCase(),
        style: OlukoFonts.olukoSmallFont(
            customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.grayColorFadeTop, customFontWeight: FontWeight.bold),
      ),
    );
  }

  GestureDetector neumorphicTaskCard(BuildContext context) {
    return GestureDetector(
        onTap: () => widget.onPressed(),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: !widget.isDisabled
                  ? !widget.isCompleted
                      ? OlukoColors.white
                      : OlukoNeumorphismColors.olukoNeumorphicBackgroundLight
                  : widget.isCompleted
                      ? OlukoNeumorphismColors.olukoNeumorphicBackgroundLight
                      : OlukoColors.taskCardBackgroundDisabled),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 0, right: 10, left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(
                                      widget.task.name,
                                      style: OlukoFonts.olukoSuperBigFont(
                                          customColor: widget.isCompleted ? OlukoColors.white : OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
                                          customFontWeight: FontWeight.bold),
                                    ),
                                    Expanded(child: SizedBox()),
                                    getCardCheck(),
                                  ]),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, right: 10),
                                    child: Text(
                                      widget.task.shortDescription,
                                      style: OlukoFonts.olukoBigFont(
                                          customColor: widget.isCompleted ? OlukoColors.grayColor : OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
                                          customFontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  getPrivacySection(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        ));
  }

  Widget getCardCheck() {
    return BlocListener<TaskCardBloc, TaskCardState>(
        listener: (context, taskCardState) {
          if (taskCardState is TaskCardVideoProcessing && taskCardState.taskIndex == widget.index) {
            setState(() {
              isLoading = true;
            });
          }
        },
        child: cardCheck());
  }

  Widget cardCheck() {
    if (isLoading && !widget.isCompleted) {
      return SizedBox(height: 21, width: 21, child: OlukoCircularProgressIndicator());
    } else {
      return Stack(alignment: Alignment.center, children: [
        Image.asset(
          widget.isCompleted ? 'assets/assessment/neumorphic_green_circle.png' : 'assets/assessment/neumorphic_green_outlined.png',
          scale: 4,
        ),
        widget.isCompleted
            ? Image.asset(
                'assets/assessment/neumorphic_check.png',
                scale: 4,
              )
            : const SizedBox.shrink()
      ]);
    }
    ;
  }

  Widget getPrivacySection() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
          padding: const EdgeInsets.only(top: 30).copyWith(bottom: 20),
          child: !widget.isDisabled
              ? SizedBox(
                  width: widget.isCompleted ? 60 : 80,
                  height: widget.isCompleted ? 15 : 40,
                  child: widget.useStartButton
                      ? OlukoNeumorphicSecondaryButton(
                          thinPadding: true,
                          textColor: OlukoColors.primary,
                          isExpanded: false,
                          useBorder: false,
                          title: OlukoLocalizations.get(context, 'start'),
                          onPressed: () {
                            print('done');
                          },
                        )
                      : widget.isCompleted
                          ? Container(
                              color: OlukoNeumorphismColors.olukoNeumorphicBlueBackgroundColor,
                              child: Center(
                                child: getPrivacy(context),
                              ),
                            )
                          : SizedBox.shrink(),
                )
              : SizedBox.shrink()),
    );
  }
}
