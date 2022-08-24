import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/routes.dart';

class ProfileRoutes {
  static String returnRouteName(ProfileOptionsTitle pageTitle) {
    switch (pageTitle) {
      case ProfileOptionsTitle.myAccount:
        return routeLabels[RouteEnum.profileMyAccount];
      case ProfileOptionsTitle.assessmentVideos:
        return routeLabels[RouteEnum.assessmentVideos];
      case ProfileOptionsTitle.transformationJourney:
        return routeLabels[RouteEnum.profileTransformationJourney];
      //case ProfileOptionsTitle.subscription:
        //return routeLabels[RouteEnum.profileSubscription];
      case ProfileOptionsTitle.settings:
        return routeLabels[RouteEnum.profileSettings];
      case ProfileOptionsTitle.helpAndSupport:
        return routeLabels[RouteEnum.profileHelpAndSupport];
      default:
        return routeLabels[RouteEnum.root];
    }
  }
}
