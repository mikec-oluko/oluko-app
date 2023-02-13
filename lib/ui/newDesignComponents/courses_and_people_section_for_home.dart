import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/ui/components/course_carousel_galery.dart';
import 'package:oluko_app/ui/components/user_item_bubbles.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class HomeCoursesAndPeople extends StatefulWidget {
  final List<CourseEnrollment> courseEnrollments;
  final int courseIndex;
  final Map<String, UserProgress> usersProgress;
  final Function(int) onCourseChange;
  final Function(int) onCourseTap;
  const HomeCoursesAndPeople({this.courseEnrollments, this.courseIndex, this.usersProgress, this.onCourseChange, this.onCourseTap}) : super();

  @override
  State<HomeCoursesAndPeople> createState() => _HomeCoursesAndPeopleState();
}

class _HomeCoursesAndPeopleState extends State<HomeCoursesAndPeople> {
  @override
  Widget build(BuildContext context) {
    return _courseAndPeopleContent(context);
  }

  Column _courseAndPeopleContent(
    BuildContext context,
  ) {
    return Column(
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
            onCourseChange: (index) => widget.onCourseChange(index),
            onCourseDeleted: (index) => () {},
            onCourseTap: (index) => widget.onCourseTap(index),
            courseIndex: widget.courseIndex,
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Text(widget.courseEnrollments[widget.courseIndex].course.name, style: OlukoFonts.olukoTitleFont()),
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
                    padding: const EdgeInsets.only(top: 15),
                    child: Center(child: Text(OlukoLocalizations.get(context, 'loadingWhithDots'), style: OlukoFonts.olukoMediumFont())),
                  ),
                ],
              );
            } else if (state is SubscribedCourseUsersSuccess && state.users.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${OlukoLocalizations.get(context, 'activeNow')} (${state.users.length})', style: OlukoFonts.olukoBigFont()),
                  const SizedBox(
                    height: 10,
                  ),
                  UserItemBubbles(
                    userProgressListBloc: BlocProvider.of<UserProgressListBloc>(context),
                    usersProgess: widget.usersProgress,
                    content: state.users,
                    currentUserId: widget.courseEnrollments[widget.courseIndex].createdBy,
                  )
                ],
              );
            } else {
              return Text('${OlukoLocalizations.get(context, 'activeNow')} (0)', style: OlukoFonts.olukoBigFont());
            }
          },
        ),
      ],
    );
  }
}
