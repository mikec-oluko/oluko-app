import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'oluko_primary_button.dart';

class ClassSection extends StatefulWidget {
  final Class classObj;
  final int index;
  final int total;
  final double classProgresss;
  final Function() onPressed;

  ClassSection({this.classObj, this.index, this.total, this.classProgresss, this.onPressed});

  @override
  _State createState() => _State();
}

class _State extends State<ClassSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              /*Divider(
                color: OlukoColors.grayColor,
                height: 50,
              ),*/
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    child: Image.network(
                      widget.classObj.image,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0, top: 0, bottom: 10),
                            child: Text(
                              widget.classObj.name,
                              style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                OlukoLocalizations.get(context, 'class').toUpperCase() +
                                    " " +
                                    (widget.index + 1).toString() +
                                    "/" +
                                    widget.total.toString(),
                                style: OlukoFonts.olukoSmallFont(custoFontWeight: FontWeight.bold, customColor: OlukoColors.white),
                              )),
                          /*widget.classProgresss > 0
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 160.0),
                                  child: CourseProgressBar(
                                      value: widget.classProgresss))
                              : SizedBox()*/
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 0, right: 10),
                          child: Text(
                            widget.classObj.description,
                            style: OlukoFonts.olukoMediumFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              /*for (var segment in widget.classObj.segments)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      OlukoPrimaryButton(
                        title: segment.name,
                        color: OlukoColors.listGrayColor,
                        textColor: Colors.white,
                        textAlign: TextAlign.start,
                        onPressed: () => widget.onPressed(),
                      ),
                    ],
                  ),
                ),*/
            ],
          ),
        ),
      ),
    );
  }
}
