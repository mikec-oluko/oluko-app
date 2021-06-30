import 'package:flutter/material.dart';

class ProgressBar extends StatefulWidget {
  final String processPhase;
  final double progress;
  ProgressBar({this.processPhase, this.progress});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ProgressBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        padding: EdgeInsets.all(30.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 30.0),
                child: Text(
                  widget.processPhase,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              LinearProgressIndicator(
                value: widget.progress,
              )
            ]));
  }
}
