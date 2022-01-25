import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/course_carousel_galery.dart';
import 'package:oluko_app/ui/components/user_item_bubbles.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class HomeLongPress extends StatefulWidget {
  HomeLongPress({Key key, this.courseEnrollments, this.index}) : super(key: key);

  final List<CourseEnrollment> courseEnrollments;
  int index;

  @override
  _HomeLongPressState createState() => _HomeLongPressState();
}

class _HomeLongPressState extends State<HomeLongPress> {

  @override
  Widget build(BuildContext context) {
    if (widget.index != null &&
        widget.index is int &&
        widget.courseEnrollments != null &&
        widget.courseEnrollments[widget.index] != null &&
        widget.courseEnrollments[widget.index].course != null) {
      BlocProvider.of<SubscribedCourseUsersBloc>(context)
          .getEnrolled(widget.courseEnrollments[widget.index].course.id, widget.courseEnrollments[widget.index].createdBy);
    }

    return Scaffold(
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      appBar: OlukoAppBar(showLogo: true, showBackButton: false, showDivider: false, showTitle: false),
      body: body(),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(OlukoLocalizations.get(context, 'enrolledCourses'), style: OlukoFonts.olukoBigFont()),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: CourseCarouselGallery(
                courseEnrollments: widget.courseEnrollments,
                courseIndex: widget.index,
                onCourseChange: (index) => _onCourseChange(index),
                onCourseDeleted: (index) => _onCourseDeleted(index)),
          ),
          const SizedBox(
            height: 25,
          ),
          Text(widget.courseEnrollments[widget.index].course.name, style: OlukoFonts.olukoTitleFont()),
          const SizedBox(
            height: 20,
          ),
          BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState>(
            builder: (context, state) {
              if (state is SubscribedCourseUsersLoading) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${OlukoLocalizations.get(context, 'activeNow')} (0)', style: OlukoFonts.olukoBigFont()),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Center(child: Text(OlukoLocalizations.get(context, 'loadingWhithDots'), style: OlukoFonts.olukoMediumFont())),
                    ),
                  ],
                );
              } else if (state is SubscribedCourseUsersSuccess && state.users.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${OlukoLocalizations.get(context, 'activeNow')} (${state.users.length})', style: OlukoFonts.olukoBigFont()),
                    UserItemBubbles(
                      content: state.users,
                      currentUserId: widget.courseEnrollments[0].createdBy,
                    )
                  ],
                );
              } else {
                return Text('${OlukoLocalizations.get(context, 'activeNow')} (0)', style: OlukoFonts.olukoBigFont());
              }
            },
          ),
        ],
      ),
    );
  }

  _onCourseChange(int index) {
    setState(() {
      widget.index = index;
    });
  }

  _onCourseDeleted(int index) {
    if (widget.courseEnrollments.length <= 1) {
      Navigator.pop(context);
    } else {
      int newPosition;
      if (index > 0) {
        newPosition = index - 1;
      } else {
        newPosition = index + 1;
      }
      setState(() {
        widget.index = newPosition;
        widget.courseEnrollments.removeAt(index);
      });
    }
  }
}
