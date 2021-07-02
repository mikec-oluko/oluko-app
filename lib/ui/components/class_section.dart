import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';

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
                          Text(
                            widget.classObj.name,
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, right: 10),
                            child: Text(
                              widget.classObj.description,
                              style: TextStyle(
                                  fontSize: 17, color: Colors.white60),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    child: Image.network(
                      widget.classObj.image,
                      height: 75,
                      width: 75,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                    width: double.infinity,
                    child: OlukoOutlinedButton(
                      title: 'Start',
                      onPressed: () => widget.onPressed(),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
