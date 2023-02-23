import 'package:flutter/widgets.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class AssessmentVideosComponent extends StatefulWidget {
  final List<TaskSubmission> assessmentVideosContent;
  final UserResponse currentUser;
  const AssessmentVideosComponent({this.assessmentVideosContent, this.currentUser}) : super();

  @override
  State<AssessmentVideosComponent> createState() => _AssessmentVideosComponentState();
}

class _AssessmentVideosComponentState extends State<AssessmentVideosComponent> {
  @override
  Widget build(BuildContext context) {
    return _buildCarouselSection(
        titleForSection: OlukoLocalizations.get(context, 'assessmentVideos'),
        routeForSection: RouteEnum.profileAssessmentVideos,
        contentForSection: TransformListOfItemsToWidget.getWidgetListFromContent(
            requestedUser: widget.currentUser, assessmentVideoData: widget.assessmentVideosContent, requestedFromRoute: ActualProfileRoute.userProfile));
  }

  Widget _buildCarouselSection({RouteEnum routeForSection, String titleForSection, List<Widget> contentForSection}) {
    return CarouselSmallSection(
        routeToGo: routeForSection,
        title: titleForSection,
        userToGetData: widget.currentUser,
        children: contentForSection.isNotEmpty
            ? contentForSection
            : [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: OlukoCircularProgressIndicator(),
                )
              ]);
  }
}
