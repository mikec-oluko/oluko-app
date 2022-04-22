class GlobalService {
  static final GlobalService _instance = GlobalService._internal();

  factory GlobalService() => _instance;

  bool _videoProcessing;
  bool _comesFromCoach;
  bool _hasInternetConnection;

  GlobalService._internal() {
    _videoProcessing = false;
    _comesFromCoach = false;
    _hasInternetConnection = false;
  }

  bool get videoProcessing => _videoProcessing;

  set videoProcessing(bool value) => _videoProcessing = value;

  bool get comesFromCoach => _comesFromCoach;

  set comesFromCoach(bool value) => _comesFromCoach = value;

  bool get hasInternetConnection => _hasInternetConnection;

  set hasInternetConnection(bool value) => _hasInternetConnection = value;
}
