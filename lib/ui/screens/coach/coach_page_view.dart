import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_introduction_video_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_timeline_bloc.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/coach_app_bar.dart';
import 'package:oluko_app/ui/components/coach_sliding_up_panel.dart';

class CoachPageView extends StatefulWidget {
  UserResponse currentAuthUser;
  CoachUser coachUser;
  List<CoachTimelineGroup> coachTimelineContent;
  CoachPageView({Key key, this.currentAuthUser, this.coachUser, this.coachTimelineContent}) : super(key: key);

  @override
  State<CoachPageView> createState() => _CoachPageViewState();
}

class _CoachPageViewState extends State<CoachPageView> {
  @override
  Widget build(BuildContext context) {
    return CoachSlidingUpPanel(
      content: Scaffold(
        appBar: _getCoachAppBar(context),
        body: CoachSlidingUpPanel(
          content: SizedBox(),
          timelineItemsContent: widget.coachTimelineContent,
          isIntroductionVideoComplete: true,
          currentUser: widget.currentAuthUser,
          onCurrentUserSelected: () => BlocProvider.of<CoachTimelineBloc>(context).emitTimelineTabsUpdate(contentForTimelinePanel: widget.coachTimelineContent),
        ),
      ),
      // content: _coachViewPageContent(context),
      // timelineItemsContent: _timelinePanelContent,
      // isIntroductionVideoComplete: coachAssignment.introductionCompleted,
      // currentUser: _currentAuthUser,
      // onCurrentUserSelected: () => BlocProvider.of<CoachTimelineBloc>(context).emitTimelineTabsUpdate(contentForTimelinePanel: _timelinePanelContent),
    );
  }

  CoachAppBar _getCoachAppBar(BuildContext context) => CoachAppBar(coachUser: widget.coachUser, currentUser: widget.currentAuthUser, onNavigationAction: () {}
      // onNavigationAction: () =>
      // !coachAssignment.introductionCompleted ? BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation() : () {},
      );
}
