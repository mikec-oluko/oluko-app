import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/friend_request_model.dart';
import 'package:oluko_app/models/user_response.dart';

class CommunityTabUtils {
  static bool friendNotificationsAreSeen(List<FriendRequestModel> friendNotifications) {
    bool haveNotifications = friendNotifications.any((element) => !element.view);
    return haveNotifications;
  }
}