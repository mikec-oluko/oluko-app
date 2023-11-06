import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/ui/components/user_item_bubbles.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ActiveNowUsers extends StatefulWidget {
  final List<CourseEnrollment> courseEnrollments;
  final int courseIndex;
  final Map<String, UserProgress> usersProgress;
  const ActiveNowUsers({this.courseEnrollments, this.courseIndex, this.usersProgress, Key key}) : super(key: key);

  @override
  State<ActiveNowUsers> createState() => _ActiveNowUsersState();
}

class _ActiveNowUsersState extends State<ActiveNowUsers> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState>(
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
    );
  }
}
