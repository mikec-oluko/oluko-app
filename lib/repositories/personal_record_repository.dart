import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/personal_record_param.dart';
import 'package:oluko_app/models/personal_record.dart';
import 'package:oluko_app/models/segment.dart';

class PersonalRecordRepository {
  FirebaseFirestore firestoreInstance;

  PersonalRecordRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static PersonalRecord create(int totalScore, PersonalRecordParam parameter, CourseEnrollment courseEnrollment, Segment segment, bool doneFromProfile) {
    DocumentReference projectReference = FirebaseFirestore.instance.collection("projects").doc(GlobalConfiguration().getString('projectId'));

    CollectionReference personalRecordReference = projectReference.collection("personalRecords");

    DocumentReference segmentReference = projectReference.collection("segments").doc(segment.id);

    DocumentReference courseEnrollmentReference = projectReference.collection("courseEnrollments").doc(courseEnrollment.id);

    PersonalRecord personalRecord = PersonalRecord(
        userId: courseEnrollment.userId,
        courseImage: courseEnrollment.course.image,
        challengeId: segment.id,
        challengeReference: segmentReference,
        value: totalScore,
        segmentImage: segment.image,
        doneFromProfile: doneFromProfile,
        parameter: parameter,
        courseEnrollmentId: courseEnrollment.id,
        courseEnrollmentReference: courseEnrollmentReference);

    final DocumentReference docRef = personalRecordReference.doc();
    personalRecord.id = docRef.id;
    docRef.set(personalRecord.toJson());
    return personalRecord;
  }

  static Future<List<PersonalRecord>> getByUserAndChallengeId(String userId, String challengeId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('personalRecords')
        .where('user_id', isEqualTo: userId)
        .where('challenge_id', isEqualTo: challengeId)
        .get();
    List<PersonalRecord> PRList = mapQueryToPR(docRef);
    if (!PRList.isEmpty) {
      PRList = sortPRs(PRList);
    }
    return PRList;
  }

  static List<PersonalRecord> sortPRs(List<PersonalRecord> list) {
    PersonalRecordParam param = list[0].parameter;
    PersonalRecord bestPR;
    int bestPRIndex = 0;
    for (var i = 1; i < list.length; i++) {
      int current = list[i].value;
      int bestPRvalue = list[bestPRIndex].value;
      if (param == PersonalRecordParam.duration) {
        if (current < bestPRvalue) {
          bestPRIndex = i;
        }
      } else {
        if (current > bestPRvalue) {
          bestPRIndex = i;
        }
      }
    }
    bestPR = list[bestPRIndex];
    list.removeAt(bestPRIndex);

    list.sort((b, a) => a.createdAt.compareTo(b.createdAt));
    list.insert(0, bestPR);
    return list;
  }

  static List<PersonalRecord> mapQueryToPR(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> PRData = ds.data() as Map<String, dynamic>;
      return PersonalRecord.fromJson(PRData);
    }).toList();
  }
}
