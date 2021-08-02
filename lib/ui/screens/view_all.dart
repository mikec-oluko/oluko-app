import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/utils/course_utils.dart';

class ViewAll extends StatefulWidget {
  List<Course> courses;

  ViewAll({this.courses, Key key}) : super(key: key);

  @override
  _ViewAllState createState() => _ViewAllState();
}

class _ViewAllState extends State<ViewAll> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: CourseUtils.searchResults(context,
            SearchResults(searchResults: widget.courses), 0.69333, 3, 5));
  }
}
