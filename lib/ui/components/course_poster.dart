import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';

class CoursePoster extends StatefulWidget {
  final String image;

  CoursePoster({this.image});

  @override
  _State createState() => _State();
}

class _State extends State<CoursePoster> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Container(
              child: Column(children: [classContainer(140.0, 108.0)]))),
    );
  }

  Widget classContainer(double height, double width) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          border: Border.all(
            color: OlukoColors.white,
            width: 1,
          ),
        ),
        child: Container(
            child: Column(children: [
          Stack(alignment: Alignment.bottomRight, children: [
            ClipRRect(
              child: Image.network(
                widget.image,
                height: height,
                width: width,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
          ]),
        ])));
  }
}
