class GlobalService {
  static final GlobalService _instance = GlobalService._internal();

  factory GlobalService() => _instance;

  GlobalService._internal() {
    _videoProcessing = false;
  }

  bool _videoProcessing;

  bool get videoProcessing => _videoProcessing;

  set videoProcessing(bool value) => _videoProcessing = value;
}
