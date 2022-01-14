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
  const HomeLongPress({Key key, this.courseEnrollments, this.index}) : super(key: key);

  final List<CourseEnrollment> courseEnrollments;
  final int index;

  @override
  _HomeLongPressState createState() => _HomeLongPressState();
}

class _HomeLongPressState extends State<HomeLongPress> {
  @override
  void initState() {
    super.initState();
    if (widget.index != null &&
        widget.index is int &&
        widget.courseEnrollments != null &&
        widget.courseEnrollments[widget.index] != null &&
        widget.courseEnrollments[widget.index].course != null) {
      BlocProvider.of<SubscribedCourseUsersBloc>(context)
          .getEnrolled(widget.courseEnrollments[widget.index].course.id, widget.courseEnrollments[widget.index].createdBy);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Container(width: 180, height: 280, decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent))),
          //CourseCarouselGallery(courseEnrollments: widget.courseEnrollments, courseIndex: widget.index,),
          const SizedBox(
            height: 25,
          ),
          Text(widget.courseEnrollments[widget.index].course.name, style: OlukoFonts.olukoTitleFont()),
          const SizedBox(
            height: 20,
          ),
          BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState>(
            builder: (context, state) {
              if (state is SubscribedCourseUsersSuccess && state.users.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${OlukoLocalizations.get(context, 'activeNow')} (${state.users.length})', style: OlukoFonts.olukoBigFont()),
                    const SizedBox(
                      height: 10,
                    ),
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
}
