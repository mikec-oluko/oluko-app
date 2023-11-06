import 'package:flutter/widgets.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ProfileHelperFunctions {
  static List<ChallengeNavigation> getChallenges(List<CourseEnrollment> courseEnrollment) {
    return courseEnrollment
        .expand((courseEnrolled) => courseEnrolled.classes
            .expand((enrolledClass) => enrolledClass.segments.where((enrolledSegment) => enrolledSegment.isChallenge).map((enrolledSegment) {
                  int courseIndex = courseEnrollment.indexOf(courseEnrolled);
                  int classIndex = courseEnrolled.classes.indexOf(enrolledClass);
                  int segmentIndex = enrolledClass.segments.indexOf(enrolledSegment);

                  return ChallengeNavigation(
                    enrolledCourse: courseEnrolled,
                    challengeSegment: enrolledSegment,
                    segmentIndex: segmentIndex,
                    segmentId: enrolledSegment.id,
                    classIndex: classIndex,
                    classId: enrolledClass.id,
                    courseIndex: courseIndex,
                    previousSegmentFinish: segmentIndex == 0 ? true : enrolledClass.segments[segmentIndex - 1].completedAt != null,
                  );
                }))
            .toSet()
            .toList())
        .toList();
  }

  static List<ChallengeNavigation> getActiveChallenges(List<Challenge> challenges, List<ChallengeNavigation> segmentChallenges) {
    Map<String, Challenge> challengeMap = {};
    for (var activeChallenge in challenges) {
      String key = '${activeChallenge.classId}_${activeChallenge.segmentId}';
      challengeMap[key] = activeChallenge;
    }
    for (var segmentChallenge in segmentChallenges) {
      String key = '${segmentChallenge.classId}_${segmentChallenge.segmentId}';
      Challenge activeChallenge = challengeMap[key];
      if (activeChallenge != null) {
        segmentChallenge.challengeForAudio = activeChallenge;
        segmentChallenge.challengeSegment.image ??= activeChallenge.image;
      }
    }
    return segmentChallenges;
  }

  static String returnTitleForConnectButton(UserConnectStatus connectStatus, BuildContext context) {
    switch (connectStatus) {
      case UserConnectStatus.connected:
        return OlukoLocalizations.get(context, 'remove');
      case UserConnectStatus.notConnected:
        return OlukoLocalizations.get(context, 'connect');
      case UserConnectStatus.requestPending:
        return OlukoLocalizations.get(context, 'connectionRequestCancelled');
      case UserConnectStatus.requestReceived:
        return OlukoLocalizations.get(context, 'confirm');
      default:
        return OlukoLocalizations.get(context, 'fail');
    }
  }
}
