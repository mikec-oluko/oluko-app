import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalRecord {
  String title;
  String date;
  String image;

  PersonalRecord({this.date, this.image, this.title});
}
