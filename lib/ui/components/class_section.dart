import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/models/class.dart';
import 'package:mvt_fitness/ui/components/course_progress_bar.dart';
import 'oluko_primary_button.dart';

class ClassSection extends StatefulWidget {
  final Class classObj;
  final double classProgresss;
  final Function() onPressed;

  ClassSection({this.classObj, this.classProgresss, this.onPressed});

  @override
  _State createState() => _State();
}

class _State extends State<ClassSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              Divider(
                color: OlukoColors.grayColor,
                height: 50,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    child: Image.network(
                      widget.classObj.image,
                      height: 100,
                      width: 100,
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
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              widget.classObj.name,
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          widget.classProgresss > 0
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 160.0),
                                  child: CourseProgressBar(
                                      value: widget.classProgresss))
                              : SizedBox()
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
                          padding: const EdgeInsets.only(
                              top: 16.0, bottom: 16, right: 10),
                          child: Text(
                            widget.classObj.description,
                            style:
                                TextStyle(fontSize: 17, color: Colors.white60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              for (var segment in widget.classObj.segments)
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
