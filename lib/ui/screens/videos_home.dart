import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/ui/screens/player_response.dart';
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title, this.videoParent, this.videoParentPath})
      : super(key: key);

  String title;
  Video videoParent;
  String videoParentPath;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final thumbWidth = 100;
  final thumbHeight = 150;
  bool _imagePickerActive = false;
  bool _processing = false;
  bool _canceled = false;
  double _progress = 0.0;
  int _videoDuration = 0;
  String _processPhase = '';
  final bool _debugMode = false;

  List<Video> _videos = <Video>[];
  FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    _setUpParameters();
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state is AuthSuccess) {
        this.user = state.firebaseUser;
      }
    }, builder: (context, state) {
      if (state is AuthSuccess) {
        this.user = state.firebaseUser;
        return BlocProvider(
            create: (context) => VideoBloc()
              ..getVideos(this.user, widget.videoParent,
                  widget.videoParentPath), //VER ACA QUE LLEGA CON NULO
            child: Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                ),
                body: Center(
                    child: _processing
                        ? _getProgressBar()
                        : BlocConsumer<VideoBloc, VideoState>(
                            listener: (context, state) {
                            if (state is VideoSuccess) {
                              print("CAMBIO");
                              _videos.add(state.video);
                            }
                          }, builder: (context, state) {
                            if (state is VideosSuccess) {
                              return _getListView(state.videos);
                            } else {
                              return Text(
                                'LOADING...',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              );
                            }
                          })),
                floatingActionButton:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  user != null
                      ? FloatingActionButton(
                          child: _processing
                              ? CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Icon(Icons.camera),
                          onPressed: () => _takeVideo(ImageSource.camera,
                              parentVideo: widget.videoParent))
                      : SizedBox(),
                ])));
      } else {
        return Text('User must be logged in');
      }
    });
  }

  @override
  void initState() {
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

    final video = Video(
      url: videoUrl,
      thumbUrl: thumbUrl,
      coverUrl: thumbUrl,
      createdBy: user != null ? user.uid : null,
      aspectRatio: aspectRatio,
      uploadedAt: DateTime.now().millisecondsSinceEpoch,
      name: videoName,
    );

    setState(() {
      _processPhase = 'Saving video metadata to cloud storage';
      _progress = 0.0;
    });

    if (parentVideo == null) {
      VideoBloc()..createVideo(video);
    } else if (widget.videoParent == null) {
      VideoBloc()..createVideoResponse(parentVideo.id, video, "/");
    } else if (parentVideo.id == widget.videoParent.id) {
      VideoBloc()
        ..createVideoResponse(parentVideo.id, video, widget.videoParentPath);
    } else {
      VideoBloc()
        ..createVideoResponse(
            parentVideo.id,
            video,
            widget.videoParentPath == '/'
                ? widget.videoParent.id
                : '${widget.videoParentPath}/${widget.videoParent.id}');
    }

    /*BlocListener<VideoBloc, VideoState>(
      listener: (context, state) {
        if (state is VideoSuccess) {
          _videos.add(state.video);
        }
      },
    );*/

    setState(() {
      _processPhase = '';
      _progress = 0.0;
      _processing = false;
    });
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

  String getFileExtension(String fileName) {
    final exploded = fileName.split('.');
    return exploded[exploded.length - 1];
  }

  Future<String> _uploadFile(filePath, folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final S3Provider s3Provider = S3Provider();
    String downloadUrl =
        await s3Provider.putFile(file.readAsBytesSync(), folderName, basename);

    return downloadUrl;
  }

  void _updatePlaylistUrls(File file, String videoName, {bool s3Storage}) {
    final lines = file.readAsLinesSync();
    var updatedLines = [];

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

  _getListView(List<Video> videos) {
    _videos = videos;
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
                    return _player(video);
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
                                    Text("${video.name}"),
                                    Container(
                                      margin: new EdgeInsets.only(top: 12.0),
                                      child: Text(
                                          'Uploaded ${timeago.format(new DateTime.fromMillisecondsSinceEpoch(video.uploadedAt))}'),
                                    ),
                                    ElevatedButton(
                                        onPressed: () => Navigator.pushNamed(
                                                context, '/videos', arguments: {
                                              'title': 'Responses',
                                              'videoParent': video,
                                              'videoParentPath': _getVideoPath()
                                            }),
                                        child: Text("View responses"))
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

  _player(Video video) {
    if (widget.videoParentPath == "") {
      return PlayerSingle(
          video: video,
          onCamera: () =>
              this._takeVideo(ImageSource.camera, parentVideo: video));
    } else {
      return PlayerResponse(
        videoParentPath: _getVideoPath(),
        videoParent: widget.videoParent,
        video: video,
        onCamera: () => this._takeVideo(ImageSource.camera, parentVideo: video),
      );
    }
  }

  _getVideoPath() {
    if (widget.videoParentPath == "") {
      return "/";
    } else if (widget.videoParentPath == "/") {
      return widget.videoParent.id;
    } else {
      return '${widget.videoParentPath}/${widget.videoParent.id}';
    }
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

  _setUpParameters() {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    if (args == null) {
      return;
    }
    if (args['title'] != null) {
      widget.title = args['title'];
    }
    if (args['videoParent'] != null) {
      widget.videoParent = args['videoParent'];
    }
    if (args['videoParentPath'] != null) {
      widget.videoParentPath = args['videoParentPath'];
    }
  }
}
