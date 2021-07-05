import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';

import 'oluko_primary_button.dart';

class ClassSection extends StatefulWidget {
  final Class classObj;
  final Function() onPressed;

  ClassSection({this.classObj, this.onPressed});

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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        children: [
                          Text(
                            widget.classObj.name,
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
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
                          padding: const EdgeInsets.only(top: 8.0, right: 10),
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
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                      width: double.infinity,
                      child: OlukoPrimaryButton(
                        title: segment.objectName,
                        color: OlukoColors.grayColor,
                        onPressed: () => widget.onPressed(),
                      )),
                ),                           
            ],
          ),
        ),
      ),
    );
  }
}
