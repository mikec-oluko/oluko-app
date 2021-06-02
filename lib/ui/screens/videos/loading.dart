import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 0,
        top: 0,
        left: 0,
        right: 0,
        child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                ))));
  }
}