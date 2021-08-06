import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/task_submission_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_error_message_view.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ProfileAssessmentVideosPage extends StatefulWidget {
  const ProfileAssessmentVideosPage();

  @override
  _ProfileAssessmentVideosPageState createState() =>
      _ProfileAssessmentVideosPageState();
}

class _ProfileAssessmentVideosPageState
    extends State<ProfileAssessmentVideosPage> {
  List<Widget> _contentGallery;
  UserResponse _profileInfo;
  List<TaskSubmission> _assessmentVideoContent = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        _profileInfo = state.user;
        BlocProvider.of<TaskSubmissionBloc>(context)
            .getTaskSubmissionByUserId(_profileInfo.id);
        return BlocConsumer<TaskSubmissionBloc, TaskSubmissionState>(
          listener: (context, state) {
            if (state is GetUserTaskSubmissionSuccess) {
              _assessmentVideoContent = state.taskSubmissions;
              _contentGallery =
                  TransformListOfItemsToWidget.getWidgetListFromContent(
                      assessmentVideoData: _assessmentVideoContent);
            }
          },
          builder: (context, state) {
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
        title: ProfileViewConstants.profileOptionsAssessmentVideos,
        showSearchBar: false,
      ),
      body: _contentGallery == null
          ? Container(
              color: Colors.black, child: OlukoCircularProgressIndicator())
          : BlocConsumer<TaskSubmissionBloc, TaskSubmissionState>(
              listener: (context, state) {
                if (state is GetUserTaskSubmissionSuccess) {
                  _assessmentVideoContent = state.taskSubmissions;
                  _contentGallery =
                      TransformListOfItemsToWidget.getWidgetListFromContent(
                          assessmentVideoData: _assessmentVideoContent);
                }
              },
              builder: (context, state) {
                return Container(
                  constraints: BoxConstraints.expand(),
                  color: OlukoColors.black,
                  child: SafeArea(
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
                  ),
                );
              },
            ),
    );
  }
}