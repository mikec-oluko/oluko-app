import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/repositories/weight_record_repository.dart';

class WeightRecordService {
  static Future<Map<UserResponse, List<WeightRecord>>> getFriendsWeight(List<UserResponse> friends) async {
    Map<UserResponse, List<WeightRecord>> friendsRecords = {};
    if (friends != null) {
      await Future.wait(
        friends.map((friend) async {
          final List<WeightRecord> friendRecord = await WeightRecordRepository().getFriendRecords(friend.id);
          friendsRecords[friend] = friendRecord;
        }),
      );
    }
    return friendsRecords;
  }
}
