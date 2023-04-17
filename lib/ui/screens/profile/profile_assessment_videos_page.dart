import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_error_message_view.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ProfileAssessmentVideosPage extends StatefulWidget {
  final UserResponse userRequested;
  const ProfileAssessmentVideosPage({this.userRequested});

  @override
  _ProfileAssessmentVideosPageState createState() => _ProfileAssessmentVideosPageState();
}

class _ProfileAssessmentVideosPageState extends State<ProfileAssessmentVideosPage> {
  List<Widget> _contentGallery;
  UserResponse _profileInfo;
  List<TaskSubmission> _assessmentVideoContent = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        _profileInfo = state.user;
        return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
          builder: (context, state) {
            if (state is GetUserTaskSubmissionSuccess) {
              _assessmentVideoContent = state.taskSubmissions;
              if (_profileInfo.id != widget.userRequested.id) {
                _assessmentVideoContent = _assessmentVideoContent.where((assessment) => assessment.isPublic).toList();
              }
              _contentGallery = TransformListOfItemsToWidget.getWidgetListFromContent(
                  assessmentVideoData: _assessmentVideoContent,
                  requestedFromRoute: ActualProfileRoute.userAssessmentVideos,
                  requestedUser: widget.userRequested);
            }
            return page(context, _profileInfo);
          },
        );
      } else {
        return SizedBox();
      }
    });
  }

  Scaffold page(BuildContext context, UserResponse profileInfo) {
    return Scaffold(
        appBar: OlukoAppBar(
            showBackButton: OlukoNeumorphism.isNeumorphismDesign,
            title: ProfileViewConstants.profileOptionsAssessmentVideos,
            showSearchBar: false,
            showTitle: true),
        body: _contentGallery == null
            ? Container(color: OlukoNeumorphismColors.appBackgroundColor, child: OlukoCircularProgressIndicator())
            : Container(
                constraints: BoxConstraints.expand(),
                color: OlukoNeumorphismColors.appBackgroundColor,
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                    child: _contentGallery.length != 0
                        ? GridView.count(
                            crossAxisCount: 3,
                            children: _contentGallery,
                          )
                        : OlukoErrorMessage(),
                  ),
                ]),
              ));
  }
}
