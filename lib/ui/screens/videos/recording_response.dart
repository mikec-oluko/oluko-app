import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/encoding_provider.dart';
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/ui/screens/videos/player_life_cycle.dart';
import 'package:oluko_app/ui/screens/videos/aspect_ratio.dart';
import 'package:oluko_app/ui/screens/videos/loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

typedef OnCameraCallBack = void Function();

class RecordingResponse extends StatefulWidget {
  final Video videoParent;
  final OnCameraCallBack onCamera;

  const RecordingResponse({Key key, @required this.videoParent, this.onCamera})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecordingResponseState();
}

class _RecordingResponseState extends State<RecordingResponse> {
  String _error;
  VideoPlayerController controller;
  List<dynamic> contents;
  bool contentInitialized = false;
  bool _autoPlay = true;
  bool playing = false;
  bool ended = false;
  Timer playbackTimer;

  //video processing and recording
  final thumbWidth = 100;
  final thumbHeight = 150;
  bool _imagePickerActive = false;
  bool _processing = false;
  bool _canceled = false;
  double _progress = 0.0;
  int _videoDuration = 0;
  String _processPhase = '';
  final bool _debugMode = false;

  //camera
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }

  Future<void> _setupCameras() async {
    try {
      // initialize cameras.
      cameras = await availableCameras();
      // initialize camera controllers.
      cameraController =
          new CameraController(cameras[0], ResolutionPreset.medium);
      await cameraController.initialize();
    } on CameraException catch (_) {
      // do something on error.
    }
    if (!mounted) return;
    setState(() {
      _isReady = true;
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          !contentInitialized ? LoadingScreen() : Container(),
          _error == null
              ? Opacity(
                  opacity: contentInitialized ? 1 : 0,
                  child: Stack(children: [
                    Positioned(
                        top: 0,
                        right: 0,
                        left: 0,
                        bottom: 30,
                        child: Container(
                            height: MediaQuery.of(context).size.height,
                            child: NetworkPlayerLifeCycle(
                              widget.videoParent.url,
                              (BuildContext context,
                                  VideoPlayerController controller) {
                                this.controller = controller;
                                addVideoControllerListener(controller);
                                return AspectRatioVideo(controller);
                              },
                            ))),
                    Positioned(
                        bottom: 118,
                        right: 8,
                        child: Container(
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width / 2,
                          child: (!_isReady)
                              ? Container()
                              : AspectRatio(
                                  aspectRatio:
                                      cameraController.value.aspectRatio,
                                  child: CameraPreview(cameraController)),
                        )),
                    Positioned(
                      bottom: 200,
                      right: 70,
                      child: Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () async {
                            //await cameraController.startVideoRecording();
                            /*_takeVideo(context, ImageSource.camera,
                                parentVideo: widget.videoParent);*/
                            /*setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });*/
                          },
                          onLongPress: () async {
                            /*XFile videopath =
                                await cameraController.stopVideoRecording();
                            print(videopath.toString());*/
                          },
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: Colors.black38,
                            child: Icon(
                              Icons.play_arrow,
                              /*_controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,*/
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    )
                  ]))
              : Center(
                  child: Text(_error),
                ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Visibility(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.green),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Visibility(
                            visible: true,
                            child: Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              children: <Widget>[
                                Container(
                                    height: 25,
                                    child: Slider.adaptive(
                                      activeColor: Colors.lightGreen.shade300,
                                      inactiveColor: Colors.teal.shade700,
                                      value: getCurrentVideoPosition(),
                                      max: getSliderMac().toDouble(),
                                      min: 0,
                                      onChanged: (val) async {
                                        await Future.wait([
                                          controller.seekTo(Duration(
                                              milliseconds: val.toInt())),
                                        ]);
                                        setState(() {});
                                      },
                                      onChangeEnd: (val) async {
                                        this.ended = contentsEnded();

                                        this._autoPlay = true;

                                        setState(() {});
                                      },
                                    )),
                                Container(
                                  height: 55,
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                IconButton(
                                    color: Colors.white,
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      setState(() => Navigator.pop(context));
                                    }),
                                IconButton(
                                    color: Colors.white,
                                    icon: Icon(this.playing
                                        ? Icons.stop
                                        : contentsEnded()
                                            ? Icons.replay
                                            : Icons.play_arrow),
                                    onPressed: () {
                                      setState(() {
                                        playing
                                            ? pauseContents()
                                            : playContents();
                                      });
                                    }),
                                IconButton(
                                    color: Colors.white,
                                    icon: Icon(Icons.camera),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      widget.onCamera();
                                    }),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
              )))
        ],
      ),
    );
  }

  double getCurrentVideoPosition() {
    double position = 0;
    if (controller != null && controller.value.position != null) {
      if (controller.value.duration != null &&
          controller.value.duration < controller.value.position) {
        position = controller.value.duration.inMilliseconds.toDouble();
      } else {
        position = controller.value.position.inMilliseconds.toDouble();
      }
    }
    return position;
  }

  playContents() async {
    var position = this.controller.value.position;
    var duration = this.controller.value.duration;

    if (position.inSeconds == duration.inSeconds) {
      resetContents();
    } else if (position.inSeconds < duration.inSeconds) {
      await Future.wait([this.controller.play()]);
    }
  }

  resetContents() async {
    this.ended = false;
    this.contentInitialized = false;
    this._autoPlay = true;
    await Future.wait([
      this.controller.seekTo(Duration(milliseconds: 0)),
    ]);
  }

  pauseContents() async {
    await this.controller.pause();

    if (this.playbackTimer != null) {
      this.playbackTimer.cancel();
      this.playbackTimer = null;
    }
    setState(() {
      this.playing = false;
    });
  }

  bool contentsEnded() {
    return videoControllerEnded(this.controller);
  }

  videoControllerEnded(videoController) {
    if (videoController == null ||
        videoController.value.position == null ||
        videoController.value.duration == null) {
      return false;
    }
    int controllerPosition =
        roundedTimestamp(videoController.value.position.inMilliseconds);
    int controllerDuration =
        roundedTimestamp(videoController.value.duration.inMilliseconds);

    bool ended = controllerPosition == controllerDuration;
    return ended;
  }

  num roundedTimestamp(num timeStamp) {
    const num division = 20;
    return (timeStamp / division).ceil();
  }

  addVideoControllerListener(VideoPlayerController controller) {
    controller.addListener(() {
      if (contentsEnded() && allContentIsPlaying()) {
        pauseContents();
        this.ended = true;
      } else if (contentsEnded() && this.ended == false) {
        this.ended = true;
        this.playing = false;
      }
      if (allContentIsPlaying()) {
        this.playing = true;
      } else {
        this.playing = false;
      }
      if (allContentsReady() && this._autoPlay == true) {
        this.playContents();
        this._autoPlay = false;
        this.contentInitialized = true;
      }
      setState(() {});
    });
  }

  allContentsReady() {
    bool created = allContentsCreated();
    bool initialized = allVideosInitialized();
    bool buffered = allVideosBuffered();
    bool stopped = !controller.value.isPlaying;

    return created && initialized && buffered && stopped && !contentInitialized;
  }

  allContentIsPlaying() {
    return this.controller.value.isPlaying;
  }

  allContentsCreated() {
    return controller != null;
  }

  allVideosInitialized() {
    return controller.value.initialized;
  }

  allVideosBuffered() {
    return !controller.value.isBuffering;
  }

  num getSliderMac() {
    return controller != null && controller.value.duration != null
        ? controller.value.duration.inMilliseconds.toDouble()
        : 100;
  }

  void _takeVideo(BuildContext context, ImageSource imageSource,
      {Video parentVideo}) async {
    var videoFile;
    if (_debugMode) {
      videoFile = File(
          '/storage/emulated/0/Android/data/com.app.oluko/files/Pictures/cef0e6eb-8371-4ea9-800b-98e9cc515ec72789476473552585505.mp4');
    } else {
      if (_imagePickerActive) return;

      _imagePickerActive = true;
      ImagePicker _imagePicker = new ImagePicker();
      videoFile = await _imagePicker.getImage(source: imageSource);
      _imagePickerActive = false;

      if (videoFile == null) return;
    }
    setState(() {
      _processing = true;
    });

    try {
      await _processVideo(context, videoFile, parentVideo: parentVideo);
    } catch (e) {
      print('${e.toString()}');
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  Future<void> _processVideo(BuildContext context, File rawVideoFile,
      {Video parentVideo}) async {
    print("EL PATH ES: " + rawVideoFile.toString());
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
      //createdBy: user != null ? user.uid : null,
      aspectRatio: aspectRatio,
      uploadedAt: DateTime.now().millisecondsSinceEpoch,
      name: videoName,
    );

    setState(() {
      _processPhase = 'Saving video metadata to cloud storage';
      _progress = 0.0;
    });

    /*if (parentVideo == null) {
      BlocProvider.of<VideoBloc>(context)..createVideo(video);
    } else if (widget.videoParent == null) {
      BlocProvider.of<VideoBloc>(context)
        ..createVideoResponse(parentVideo.id, video, "/");
    } else if (parentVideo.id == widget.videoParent.id) {
      BlocProvider.of<VideoBloc>(context)
        ..createVideoResponse(parentVideo.id, video, widget.videoParentPath);
    } else {
      BlocProvider.of<VideoBloc>(context)
        ..createVideoResponse(
            parentVideo.id,
            video,
            widget.videoParentPath == '/'
                ? widget.videoParent.id
                : '${widget.videoParentPath}/${widget.videoParent.id}');
    }*/

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
}
