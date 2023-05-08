import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/models/class.dart';

class ClassItem {
  Class classObj;
  bool expanded;
  GlobalKey globalKey;
  Timestamp scheduledDate;
  ClassItem({this.classObj, this.expanded, this.globalKey, this.scheduledDate});
}
