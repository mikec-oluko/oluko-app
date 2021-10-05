import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_assignment_status.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'coach_no_assigned_timer_page.dart';
import 'coach_page.dart';

class CoachMainPage extends StatefulWidget {
  const CoachMainPage();

  @override
  _CoachMainPageState createState() => _CoachMainPageState();
}

class _CoachMainPageState extends State<CoachMainPage> {
  UserResponse _currentUser;
  CoachAssignment _coachAssignment;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          _currentUser = state.user;
          BlocProvider.of<CoachAssignmentBloc>(context).getCoachAssignmentStatus(_currentUser.id);
        }
        return BlocBuilder<CoachAssignmentBloc, CoachAssignmentState>(
          builder: (context, state) {
            if (state is CoachAssignmentResponse) {
              _coachAssignment = state.coachAssignmentResponse;
              if (_coachAssignment != null) {
                if (CoachAssignmentStatus.getCoachAssignmentStatus(_coachAssignment.coachAssignmentStatus as int) ==
                    CoachAssignmentStatusEnum.approved) {
                  return CoachPage(coachId: _coachAssignment.coachId, coachAssignment: _coachAssignment);
                } else {
                  return CoachAssignedCountDown(
                    currentUser: _currentUser,
                    coachAssignment: _coachAssignment,
                  );
                }
              } else {
                return CoachAssignedCountDown(
                  currentUser: _currentUser,
                  coachAssignment: _coachAssignment,
                );
              }
            } else {
              return Container(color: OlukoColors.black, child: OlukoCircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}