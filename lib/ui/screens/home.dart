import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/video_repository.dart';
import 'package:oluko_app/ui/screens/video_responses.dart';
import 'package:oluko_app/ui/screens/player_single.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:oluko_app/helpers/encoding_provider.dart';
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:path/path.dart' as p;
import 'package:oluko_app/models/video.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  String title = 'Videos App';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final thumbWidth = 100;
  final thumbHeight = 150;
  List<Video> _videos = <Video>[];
  bool _imagePickerActive = false;
  bool _processing = false;
  bool _canceled = false;
  double _progress = 0.0;
  int _videoDuration = 0;
  String _processPhase = '';
  final bool _debugMode = false;
  //SignUpResponse profile;
  FirebaseUser user;

  @override
  void initState() {
    FirebaseAuth.instance.onAuthStateChanged.listen((firebaseUser) async {
      if (firebaseUser != null) {
        this.user = firebaseUser;
      }
      List<Video> videosToShow = [];
      if (user == null) {
        List<Video> result = await VideoRepository.getVideos();
        videosToShow = result;
      } else {
        List<Video> result = await VideoRepository.getVideosByUser(user);
        videosToShow = result;
      }
      setState(() {
        _videos = videosToShow;
      });
    });

    if (!kIsWeb) {
      listenToEncodingProviderProgress();
    }
    super.initState();
  }

  void listenToEncodingProviderProgress() {
    EncodingProvider.enableStatisticsCallback((Statistics stats) {
      if (_canceled) return;
      setState(() {
        _progress = stats.time / _videoDuration;
      });
    });
  }

  void _onUploadProgress(event) {
    if (event.type == StorageTaskEventType.progress) {
      final double progress =
          event.snapshot.bytesTransferred / event.snapshot.totalByteCount;
      setState(() {
        _progress = progress;
      });
    }
  }

  Future<String> _uploadFile(filePath, folderName) async {
    return _uploadFileS3(filePath, folderName);
  }

  Future<String> _uploadFileFireStore(filePath, folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final StorageReference ref =
        FirebaseStorage.instance.ref().child(folderName).child(basename);
    StorageUploadTask uploadTask = ref.putFile(file);
    uploadTask.events.listen(_onUploadProgress);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String videoUrl = await taskSnapshot.ref.getDownloadURL();
    return videoUrl;
  }

  Future<String> _uploadFileS3(filePath, folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final S3Provider s3Provider = S3Provider();
    String downloadUrl =
        await s3Provider.putFile(file.readAsBytesSync(), folderName, basename);

    return downloadUrl;
  }

  String getFileExtension(String fileName) {
    final exploded = fileName.split('.');
    return exploded[exploded.length - 1];
  }

  void _updatePlaylistUrls(File file, String videoName, {bool s3Storage}) {
    final lines = file.readAsLinesSync();
    var updatedLines = List<String>();

    for (final String line in lines) {
      var updatedLine = line;
      if (line.contains('.ts') || line.contains('.m3u8')) {
        updatedLine = s3Storage == null
            ? '$videoName%2F$line?alt=media'
            : '$line?alt=media';
      }
      updatedLines.add(updatedLine);
    }
    final updatedContents =
        updatedLines.reduce((value, element) => value + '\n' + element);

    file.writeAsStringSync(updatedContents);
  }

  Future<String> _uploadHLSFiles(dirPath, videoName) async {
    final videosDir = Directory(dirPath);

    var playlistUrl = '';

    final files = videosDir.listSync();
    int i = 1;
    for (FileSystemEntity file in files) {
      final fileName = p.basename(file.path);
      final fileExtension = getFileExtension(fileName);
      if (fileExtension == 'm3u8')
        _updatePlaylistUrls(file, videoName, s3Storage: true);

      setState(() {
        _processPhase = 'Uploading video part file $i out of ${files.length}';
        _progress = 0.0;
      });

      final downloadUrl = await _uploadFile(file.path, videoName);

      if (fileName == 'master.m3u8') {
        playlistUrl = downloadUrl;
      }
      i++;
    }

    return playlistUrl;
  }

  Future<void> _processVideo(File rawVideoFile, {Video parentVideo}) async {
    final String rand = '${new Random().nextInt(10000)}';
    final videoName = 'video$rand';
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);

    final rawVideoPath = rawVideoFile.path;
    final info = await EncodingProvider.getMediaInformation(rawVideoPath);
    final aspectRatio =
        EncodingProvider.getAspectRatio(info.getAllProperties());

    setState(() {
      _processPhase = 'Generating thumbnail';
      _videoDuration = EncodingProvider.getDuration(info.getAllProperties());
      _progress = 0.0;
    });

    final thumbFilePath =
        await EncodingProvider.getThumb(rawVideoPath, thumbWidth, thumbHeight);

    setState(() {
      _processPhase = 'Encoding video';
      _progress = 0.0;
    });

    final encodedFilesDir =
        await EncodingProvider.encodeHLS(rawVideoPath, outDirPath);

    setState(() {
      _processPhase = 'Uploading thumbnail to cloud storage';
      _progress = 0.0;
    });
    final thumbUrl = await _uploadFile(thumbFilePath, 'thumbnail');
    final videoUrl = await _uploadHLSFiles(encodedFilesDir, videoName);

    final videoInfo = Video(
      videoUrl: videoUrl,
      thumbUrl: thumbUrl,
      coverUrl: thumbUrl,
      createdBy: user != null ? user.uid : null,
      aspectRatio: aspectRatio,
      uploadedAt: DateTime.now().millisecondsSinceEpoch,
      videoName: videoName,
    );

    setState(() {
      _processPhase = 'Saving video metadata to cloud storage';
      _progress = 0.0;
    });

    if (parentVideo == null) {
      await VideoRepository.saveVideo(videoInfo);
    } else {
      await VideoRepository.addVideoResponse(parentVideo.id, videoInfo);
    }
    setState(() {
      _processPhase = '';
      _progress = 0.0;
      _processing = false;
    });
  }

  void _takeVideo(ImageSource imageSource, {Video parentVideo}) async {
    var videoFile;
    if (_debugMode) {
      videoFile = File(
          '/storage/emulated/0/Android/data/com.app.oluko/files/Pictures/cef0e6eb-8371-4ea9-800b-98e9cc515ec72789476473552585505.mp4');
    } else {
      if (_imagePickerActive) return;

      _imagePickerActive = true;
      videoFile = await ImagePicker.pickVideo(source: imageSource);
      _imagePickerActive = false;

      if (videoFile == null) return;
    }
    setState(() {
      _processing = true;
    });

    try {
      await _processVideo(videoFile, parentVideo: parentVideo);
    } catch (e) {
      print('${e.toString()}');
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  _getListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _videos.length,
        itemBuilder: (BuildContext context, int index) {
          final video = _videos[index];
          return GestureDetector(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return PlayerSingle(
                        video: video,
                        onCamera: () => this._takeVideo(ImageSource.camera,
                            parentVideo: video));
                  },
                ),
              );
            },
            child: Card(
              child: new Container(
                  padding: new EdgeInsets.all(10.0),
                  child: Column(children: [
                    Stack(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Container(
                                  width: thumbWidth.toDouble(),
                                  height: thumbHeight.toDouble(),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                                ClipRRect(
                                  borderRadius: new BorderRadius.circular(8.0),
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: video.thumbUrl,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                margin: new EdgeInsets.only(left: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text("${video.videoName}"),
                                    Container(
                                      margin: new EdgeInsets.only(top: 12.0),
                                      child: Text(
                                          'Uploaded ${timeago.format(new DateTime.fromMillisecondsSinceEpoch(video.uploadedAt))}'),
                                    ),
                                    ElevatedButton(
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Scaffold(
                                                        body: ResponsesPage(
                                                      title: 'Responses',
                                                      videoParent: video,
                                                      videoParentPath: '/',
                                                    )))),
                                        child: Text("View Responses"))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ])),
            ),
          );
        });
  }

  _getProgressBar() {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            child: Text(_processPhase),
          ),
          LinearProgressIndicator(
            value: _progress,
          ),
        ],
      ),
    );
  }

  Future<Video> getVideoResponse(video) async {
    var response = await VideoRepository.getVideoResponses(video.id);
    if (response.length == 0) {
      return null;
    }
    var videoResponse = response[0];
    return videoResponse;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        //future: getProfile(),
        builder: (context, snapshot) {
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            //actions: menuOptions(),
          ),
          body: Center(child: _processing ? _getProgressBar() : _getListView()),
          floatingActionButton:
              Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            user != null
                ? FloatingActionButton(
                    child: _processing
                        ? CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Icon(Icons.camera),
                    onPressed: () => _takeVideo(ImageSource.camera))
                : SizedBox(),
            // Padding(
            //   padding: EdgeInsets.only(top: 10),
            // child: FloatingActionButton(
            //     child: _processing
            //         ? CircularProgressIndicator(
            //             valueColor:
            //                 new AlwaysStoppedAnimation<Color>(Colors.white),
            //           )
            //         : Icon(Icons.photo),
            //     onPressed: () => _takeVideo(ImageSource.gallery)),
            // )
          ]));
    });
  }

  /*Future<void> getProfile() async {
    final profileData = await LoginService.retrieveLoginData();
    profile = profileData != null
        ? SignUpResponse.fromJson(profileData.toJson())
        : null;
  }*/

  /*List<Widget> menuOptions() {
    List<Widget> options = [];

    if (profile == null) {
      options.add(ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/sign-up')
            .then((value) => onGoBack()),
        child: Text('SIGN UP'),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
      options.add(ElevatedButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/log-in').then((value) => onGoBack()),
        child: Text('LOG IN'),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
    } else {
      options.add(ElevatedButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          LoginService.removeLoginData();
          SnackbarService.showSnackbar(context, 'Logged out.');
          setState(() {});
        },
        child: Text('LOG OUT'),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
      options.add(ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/profile')
            .then((value) => onGoBack()),
        child: Text('PROFILE'),
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent, primary: Colors.transparent),
      ));
    }

    return options;
  }*/

  onGoBack() {
    setState(() {});
  }
}
