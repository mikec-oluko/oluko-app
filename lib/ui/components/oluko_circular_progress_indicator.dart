import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OlukoCircularProgressIndicator extends StatefulWidget {
  OlukoCircularProgressIndicator();

  @override
  _State createState() => _State();
}

class _State extends State<OlukoCircularProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(strokeWidth: 1),
    );
  }
}
