import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/course_carousel_galery.dart';
import 'package:oluko_app/ui/components/user_item_bubbles.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class HomeLongPress extends StatefulWidget {
  HomeLongPress(this.currentUser, this.courseEnrollments, this.index, {Key key}) : super(key: key);

  final UserResponse currentUser;
  final List<CourseEnrollment> courseEnrollments;
  int index;

  @override
  _HomeLongPressState createState() => _HomeLongPressState();
}

class _HomeLongPressState extends State<HomeLongPress> {
  Map<String, UserProgress> _usersProgress = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<UserProgressListBloc>(context).get(widget.currentUser.id);
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
      appBar: OlukoAppBar(showLogo: true, showBackButton: true, showDivider: false, showTitle: false),
      body: ListView(
        physics: OlukoNeumorphism.listViewPhysicsEffect,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        children: [
          body(),
        ],
      ),
    );
  }

  Widget body() {
    return BlocConsumer<UserProgressListBloc, UserProgressListState>(
        listener: (context, userProgressListState) {},
        builder: (context, userProgressListState) {
          if (userProgressListState is GetUserProgressSuccess) {
            _usersProgress = userProgressListState.usersProgress;
          }
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
                            padding: const EdgeInsets.only(top: 15),
                            child: Center(child: Text(OlukoLocalizations.get(context, 'loadingWithDots'), style: OlukoFonts.olukoMediumFont())),
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
                            usersProgess: _usersProgress,
                            content: state.users,
                            currentUserId: widget.courseEnrollments[widget.index].createdBy,
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
        });
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
      int newPosition = index;
      if (index == widget.courseEnrollments.length - 1) {
        newPosition = index - 1;
      }
      setState(() {
        widget.courseEnrollments.removeAt(index);
        widget.index = newPosition;
      });
    }
  }
}
