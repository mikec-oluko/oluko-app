import 'package:flutter/widgets.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class TransformationJourneyComponent extends StatefulWidget {
  final List<TransformationJourneyUpload> transformationJourneyContent;
  final UserResponse userToDisplay;
  const TransformationJourneyComponent({this.transformationJourneyContent, this.userToDisplay}) : super();

  @override
  State<TransformationJourneyComponent> createState() => _TransformationJourneyComponentState();
}

class _TransformationJourneyComponentState extends State<TransformationJourneyComponent> {
  @override
  Widget build(BuildContext context) {
    return widget.transformationJourneyContent.isNotEmpty
        ? _buildCarouselSection(
            titleForSection: OlukoLocalizations.get(context, 'transformationJourney'),
            routeForSection: RouteEnum.profileTransformationJourney,
            contentForSection: TransformListOfItemsToWidget.getWidgetListFromContent(
                tansformationJourneyData: widget.transformationJourneyContent,
                requestedFromRoute: ActualProfileRoute.userProfile,
                requestedUser: widget.userToDisplay))
        : const SizedBox();
  }

  Widget _buildCarouselSection({RouteEnum routeForSection, String titleForSection, List<Widget> contentForSection}) {
    return CarouselSmallSection(
        routeToGo: routeForSection,
        title: titleForSection,
        userToGetData: widget.userToDisplay,
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
