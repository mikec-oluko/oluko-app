import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/models/enums/movement_videos_action_enum.dart';

class CollapsedMovementVideosSection extends StatefulWidget {
  final Widget action;

  CollapsedMovementVideosSection({this.action});

  @override
  _State createState() => _State();
}

class _State extends State<CollapsedMovementVideosSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/courses/gray_background.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(children: [
          SizedBox(height: 15),
          Row(children: [
            Padding(
                padding: EdgeInsets.only(left: 20),
                //TODO: update text translation
                child: Text("Movement Videos",
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold))),
            SizedBox(width: 10),
            Icon(Icons.directions_run, color: Colors.white, size: 30),
            Expanded(child: SizedBox()),
            widget.action
          ]),
          SizedBox(height: 10),
          Image.asset(
            'assets/courses/horizontal_vector.png',
            scale: 2,
          )
        ]));
  }
}
