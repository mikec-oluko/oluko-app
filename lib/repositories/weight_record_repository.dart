import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/weight_record.dart';

class WeightRecordRepository {
  FirebaseFirestore firestoreInstance;

  WeightRecordRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserWeightRecordsStream(String userId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> userWeightRecorsStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('records')
        .snapshots();
    return userWeightRecorsStream;
  }

  Future<List<WeightRecord>> getFriendRecords(String friendUserId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(friendUserId)
        .collection('records')
        .get();

    List<WeightRecord> friendWeightRecords = mapQueryToRecord(querySnapshot);
    return friendWeightRecords;
  }

  static List<WeightRecord> mapQueryToRecord(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> recordsData = ds.data() as Map<String, dynamic>;
      return WeightRecord.fromJson(recordsData);
    }).toList();
  }
}
