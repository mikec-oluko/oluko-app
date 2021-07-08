import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/segment.dart';
import 'oluko_primary_button.dart';

class SegmentSection extends StatefulWidget {
  final Segment segment;
  final Function() onPressed;

  SegmentSection({this.segment, this.onPressed});

  @override
  _State createState() => _State();
}

class _State extends State<SegmentSection> {
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
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              widget.segment.name,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              for (var movement in widget.segment.movements)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      OlukoPrimaryButton(
                        title: movement.objectName,
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
