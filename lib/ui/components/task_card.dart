import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function() onPressed;
  final bool isPublic;
  final bool isCompleted;
  final bool isDisabled;

  TaskCard({this.task, this.onPressed, this.isCompleted = false, this.isPublic = false, this.isDisabled = false});

  @override
  _State createState() => _State();
}

class _State extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return buildTaskCard(context);
  }

  GestureDetector buildTaskCard(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? GestureDetector(
            onTap: () => widget.onPressed(),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: !widget.isDisabled ? OlukoColors.white : OlukoColors.taskCardBackgroundDisabled),
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
                                        Text(
                                          widget.task.name,
                                          style: OlukoFonts.olukoSuperBigFont(
                                              customColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                                              custoFontWeight: FontWeight.bold),
                                        ),
                                        Expanded(child: SizedBox()),
                                        // Stack(alignment: Alignment.center, children: [
                                        //   Image.asset(
                                        //     'assets/assessment/check_ellipse.png',
                                        //     scale: 4,
                                        //   ),
                                        //   widget.isCompleted
                                        //       ? Image.asset(
                                        //           'assets/assessment/check.png',
                                        //           scale: 4,
                                        //         )
                                        //       : SizedBox()
                                        // ])
                                      ]),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0, right: 10),
                                        child: Text(
                                          widget.task.shortDescription,
                                          style: OlukoFonts.olukoBigFont(
                                              customColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                                              custoFontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: !widget.isDisabled
                                    ? SizedBox(
                                        width: 80,
                                        height: 40,
                                        child: OlukoNeumorphicSecondaryButton(
                                          thinPadding: true,
                                          textColor: OlukoColors.primary,
                                          isExpanded: false,
                                          useBorder: false,
                                          title: OlukoLocalizations.get(context, 'start'),
                                          onPressed: () {
                                            print('done');
                                          },
                                        ),
                                      )
                                    : SizedBox()),
                          ),
                        ],
                      )),
                ),
              ),
            ))
        : GestureDetector(
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
                                        Text(
                                          widget.task.name,
                                          style: OlukoFonts.olukoSuperBigFont(
                                              customColor: OlukoColors.white, custoFontWeight: FontWeight.bold),
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
                                Text(
                                  widget.isPublic
                                      ? OlukoLocalizations.get(context, 'public').toUpperCase()
                                      : OlukoLocalizations.get(context, 'private').toUpperCase(),
                                  style: OlukoFonts.olukoSmallFont(
                                      customColor: OlukoColors.grayColorFadeTop, custoFontWeight: FontWeight.bold),
                                ),
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
}
