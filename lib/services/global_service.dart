class GlobalService {
  static final GlobalService _instance = GlobalService._internal();

  // passes the instantiation to the _instance object
  factory GlobalService() => _instance;

  //initialize variables in here
  GlobalService._internal() {
    _videoProcessing = false;
  }

  bool _videoProcessing;

  //short getter for my variable
  bool get videoProcessing => _videoProcessing;

  //short setter for my variable
  set videoProcessing(bool value) => _videoProcessing = value;
}
