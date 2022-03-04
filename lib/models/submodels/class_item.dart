import 'package:flutter/material.dart';
import 'package:oluko_app/models/class.dart';

class ClassItem {
  Class classObj;
  bool expanded;
  GlobalKey globalKey;
  ClassItem({this.classObj, this.expanded, this.globalKey});
}
