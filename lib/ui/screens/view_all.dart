import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ViewAll extends StatefulWidget {
  List<Course> courses;
  String title;

  ViewAll({this.courses, this.title, Key key}) : super(key: key);

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
        appBar: OlukoAppBar(
          title: widget.title != null ? widget.title : OlukoLocalizations.get(context, 'viewAll'),
          showTitle: true,
          showBackButton: true,
        ),
        backgroundColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : Colors.black,
        body: CourseUtils.searchResults(context, SearchResults(searchResults: widget.courses), 0.69333, 3, 5));
  }
}
