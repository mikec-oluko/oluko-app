import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/repositories/video_repository.dart';
import 'package:oluko_app/ui/screens/videos/player_response.dart';
import 'package:oluko_app/ui/screens/videos/player_single.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/ui/screens/videos/recording_response.dart';
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
  Home({Key key, this.title, this.videoParent, this.parentVideoReference})
      : super(key: key);

  String title;
  Video videoParent;
  CollectionReference parentVideoReference;

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
  double _unitOfProgress = 0.13;
  //int _videoDuration = 0;
  String _processPhase = '';

  List<Video> _videos = <Video>[];
  User user;

  @override
  Widget build(BuildContext context) {
    _setUpParameters();
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        this.user = state.firebaseUser;
        return BlocProvider(
            create: (context) =>
                VideoBloc()..getVideos(this.user, widget.parentVideoReference),
            child: Builder(builder: (BuildContext context) {
              return Scaffold(
                  appBar: AppBar(
                    title: Text(widget.title),
                  ),
                  body: Center(
                      child: _processing
                          ? _getProgressBar()
                          : BlocBuilder<VideoBloc, VideoState>(
                              builder: (context, state) {
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
                  floatingActionButton: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          child: _processing
                              ? CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Icon(Icons.camera),
                          onPressed: () async {
                            if (widget.videoParent == null) {
                              _takeVideo(context, ImageSource.camera,
                                  widget.parentVideoReference);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return RecordingResponse(
                                      parentVideoReference: widget.parentVideoReference,
                                      videoParent: widget.videoParent,
                                      onCamera: () => this._takeVideo(
                                          context,
                                          ImageSource.camera,
                                          widget.parentVideoReference
                                              .doc(widget.videoParent.id)
                                              .collection('videoResponses')),
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ]));
            }));
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
      /*setState(() {
        _progress = stats.time / _videoDuration;
      });*/
    });
  }

  void _takeVideo(BuildContext context, ImageSource imageSource,
      CollectionReference reference) async {
    if (_imagePickerActive) return;
    _imagePickerActive = true;
    ImagePicker _imagePicker = new ImagePicker();
    PickedFile videoFile = await _imagePicker.getVideo(source: imageSource);
    _imagePickerActive = false;
    if (videoFile == null) return;

    setState(() {
      _processing = true;
    });

    try {
      File file = File(videoFile.path);
      await _processVideo(context, file, reference);
    } catch (e) {
      print('${e.toString()}');
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  Future<void> _processVideo(BuildContext context, File rawVideoFile,
      CollectionReference reference) async {
    setState(() {
      _progress = 0.0;
    });
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
      //_videoDuration = EncodingProvider.getDuration(info.getAllProperties());
      _progress += _unitOfProgress;
    });

    final thumbFilePath =
        await EncodingProvider.getThumb(rawVideoPath, thumbWidth, thumbHeight);

    setState(() {
      _processPhase = 'Encoding video';
      _progress += _unitOfProgress;
    });

    final encodedFilesDir =
        await EncodingProvider.encodeHLS(rawVideoPath, outDirPath);

    setState(() {
      _processPhase = 'Uploading thumbnail to cloud storage';
      _progress += _unitOfProgress;
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
      _progress += _unitOfProgress;
    });

    //BlocProvider.of<VideoBloc>(context)..createVideoWithPath(video, reference);

    VideoRepository.createVideo(video, reference);

    setState(() {
      _processPhase = '';
      _progress += _unitOfProgress;
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

      double fileProgress = 0.3 / files.length.toDouble();

      setState(() {
        _processPhase = 'Uploading video part file $i out of ${files.length}';
        _progress += fileProgress;
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
                    return _player(context, video);
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
                                                context, '/videos',
                                                arguments: {
                                                  'title': 'Responses',
                                                  'videoParent': video,
                                                  'parentVideoReference': widget
                                                      .parentVideoReference
                                                      .doc(video.id)
                                                      .collection(
                                                          'videoResponses'),
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

  _player(BuildContext context, Video video) {
    if (widget.videoParent == null) {
      return PlayerSingle(
          video: video,
          onCamera: () => this._takeVideo(
              context,
              ImageSource.camera,
              widget.parentVideoReference
                  .doc(video.id)
                  .collection('videoResponses')));
    } else {
      return PlayerResponse(
        videoReference: widget.parentVideoReference.doc(video.id),
        videoParent: widget.videoParent,
        video: video,
        onCamera: () => this._takeVideo(
            context,
            ImageSource.camera,
            widget.parentVideoReference
                .doc(widget.videoParent.id)
                .collection('videoResponses')),
      );
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
    //NO SE PARA QUE SIRVE ESTO
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
    if (args['parentVideoReference'] != null) {
      widget.parentVideoReference = args['parentVideoReference'];
    }
  }
}
