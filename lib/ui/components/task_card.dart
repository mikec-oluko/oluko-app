import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function() onPressed;
  final bool isPublic;
  final bool isCompleted;

  TaskCard(
      {this.task,
      this.onPressed,
      this.isCompleted = false,
      this.isPublic = false});

  @override
  _State createState() => _State();
}

class _State extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => widget.onPressed(),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: OlukoColors.taskCardBackground),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                  padding: const EdgeInsets.only(
                      top: 15, bottom: 15, right: 10, left: 10),
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
                                          customColor: OlukoColors.white,
                                          custoFontWeight: FontWeight.bold),
                                    ),
                                    Expanded(child: SizedBox()),
                                    Stack(
                                        alignment: Alignment.center,
                                        children: [
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
                                    padding: const EdgeInsets.only(
                                        top: 8.0, right: 10),
                                    child: Text(
                                      widget.task.description,
                                      style: OlukoFonts.olukoBigFont(
                                          customColor: OlukoColors.grayColor),
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
                                  ? OlukoLocalizations.of(context)
                                      .find('public')
                                      .toUpperCase()
                                  : OlukoLocalizations.of(context)
                                      .find('private')
                                      .toUpperCase(),
                              style: OlukoFonts.olukoSmallFont(
                                  customColor: OlukoColors.grayColorFadeTop,
                                  custoFontWeight: FontWeight.bold),
                            ),
                            Expanded(child: SizedBox()),
                            Stack(alignment: Alignment.center, children: [
                              Image.asset(
                                'assets/assessment/green_ellipse.png',
                                scale: 4,
                              ),
                              Image.asset(
                                'assets/home/right_icon.png',
                                scale: 4,
                              )
                            ]),
                          ])),
                    ],
                  )),
            ),
          ),
        ));
  }
}
