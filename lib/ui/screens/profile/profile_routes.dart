import 'package:flutter/material.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ProfileRoutes {
  static const String userInformationRoute = '/profile-view-own-profile';
  static const String profileSettingsRoute = '/profile-settings';
  static const String profileSubscriptionRoute = '/profile-subscription';
  static const String profileMyAccountRoute = '/profile-my-account';
  static const String profileChallengesRoute = '/profile-challenges';
  static const String profileHelpAndSupportRoute = '/profile-help-and-support';
  static const String profileTransformationJourneyRoute =
      '/profile-transformation-journey';

  static String returnRouteName(String pageTitle) {
    switch (pageTitle) {
      case ProfileViewConstants.profileOptionsMyAccount:
        return ProfileRoutes.profileMyAccountRoute;
      case ProfileViewConstants.profileOptionsAssessmentVideos:
        return '/';
      case ProfileViewConstants.profileOptionsTransformationJourney:
        return ProfileRoutes.profileTransformationJourneyRoute;
      case ProfileViewConstants.profileOptionsSubscription:
        return ProfileRoutes.profileSubscriptionRoute;
      case ProfileViewConstants.profileOptionsSettings:
        return ProfileRoutes.profileSettingsRoute;
      case ProfileViewConstants.profileOptionsHelpAndSupport:
        return ProfileRoutes.profileHelpAndSupportRoute;
      default:
        return '/';
    }
  }

  static Future<void> returnToHome({BuildContext context}) async {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  static goToChallenges() => ProfileRoutes.profileChallengesRoute;

  static goToTransformationJourney() =>
      ProfileRoutes.profileTransformationJourneyRoute;
}