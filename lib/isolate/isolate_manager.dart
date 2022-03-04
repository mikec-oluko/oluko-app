import 'package:oluko_app/models/class.dart';

import '../models/submodels/video.dart';

enum IsolateStatusEnum {
  success,
  failure,
}

class OlukoIsolateMessage {
  IsolateStatusEnum status;
  Map<String, Object> video;
  OlukoIsolateMessage(this.status, {this.video});
}
