import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course_enrollment.dart';

class ProfileHelperFunctions {
  static List<ChallengeNavigation> getChallenges(List<CourseEnrollment> courseEnrollment) {
    List<ChallengeNavigation> challengesForUser = [];
    ChallengeNavigation newChallenge;
    int classIndex;
    int segmentIndex;
    int courseIndex;

    courseEnrollment.forEach((courseEnrolled) {
      courseIndex = courseEnrollment.indexOf(courseEnrolled);
      courseEnrolled.classes.forEach((enrolledClass) {
        classIndex = courseEnrolled.classes.indexOf(enrolledClass);
        enrolledClass.segments.forEach((enrolledSegment) {
          segmentIndex = enrolledClass.segments.indexOf(enrolledSegment);
          if (enrolledSegment.isChallenge == true) {
            newChallenge = ChallengeNavigation(
                enrolledCourse: courseEnrolled,
                challengeSegment: enrolledSegment,
                segmentIndex: segmentIndex,
                segmentId: enrolledSegment.id,
                classIndex: classIndex,
                classId: enrolledClass.id,
                courseIndex: courseIndex,
                previousSegmentFinish: segmentIndex == 0 ? true : courseEnrolled.classes[classIndex].segments[segmentIndex - 1].completedAt != null,);

            if (challengesForUser.isEmpty) {
              if (newChallenge != null) {
                challengesForUser.add(newChallenge);
              }
            } else {
              if (newChallenge != null) {
                if (!challengesForUser.contains(newChallenge)) {
                  challengesForUser.add(newChallenge);
                }
              }
            }
          }
        });
      });
    });
    return challengesForUser;
  }

  static List<ChallengeNavigation> getActiveChallenges(List<Challenge> challenges, List<ChallengeNavigation> segmentChallenges) {
    segmentChallenges.forEach((segmentChallenge) {
      challenges.forEach((activeChallenge) {
        if (segmentChallenge.classId == activeChallenge.classId && segmentChallenge.segmentId == activeChallenge.segmentId) {
          segmentChallenge.challengeForAudio = activeChallenge;
        }
      });
    });
    return segmentChallenges;
  }

  static String returnTitleForConnectButton(UserConnectStatus connectStatus) {
    switch (connectStatus) {
      case UserConnectStatus.connected:
        return 'remove';
      case UserConnectStatus.notConnected:
        return 'connect';
      case UserConnectStatus.requestPending:
        return 'cancelConnectionRequested';
      case UserConnectStatus.requestReceived:
        return 'confirm';
      default:
        return 'fail';
    }
  }
}
