import 'package:cloud_firestore/cloud_firestore.dart';

DateTime fromTimestampToDate(Timestamp timestamp) {
  return timestamp.toDate();
}
