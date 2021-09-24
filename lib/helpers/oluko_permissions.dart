import 'package:oluko_app/models/user_response.dart';

class OlukoPermissions {
  static bool isAssessmentTaskDisabled(UserResponse user, num index) => user.currentPlan < 1 && index > 1;
}
