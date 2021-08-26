import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/video_info_bloc.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/submodels/video_info.dart';
import 'package:oluko_app/ui/components/progress_bar.dart';
import 'package:oluko_app/ui/screens/videos/player_double.dart';
import 'package:oluko_app/ui/screens/videos/player_single.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/ui/screens/videos/recording_response.dart';
import 'package:oluko_app/utils/field_formatting.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:oluko_app/helpers/encoding_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideosHome extends StatefulWidget {
  VideosHome({Key key, this.title, this.parentVideoInfo, this.parentVideoReference})
      : super(key: key);

  String title;
  VideoInfo parentVideoInfo;
  CollectionReference parentVideoReference;

  @override
  _VideosHomeState createState() => _VideosHomeState();
}

class _VideosHomeState extends State<VideosHome> {
  VideoInfoBloc _videoInfoBloc;

  List<VideoInfo> _videosInfo = <VideoInfo>[];
  User user;

  @override
  Widget build(BuildContext context) {
    _setUpParameters();
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        this.user = state.firebaseUser;
        return BlocProvider(
            create: (context) => _videoInfoBloc
              ..getVideosInfo(this.user, widget.parentVideoReference),
            child: Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                ),
                body: Center(child: BlocBuilder<VideoInfoBloc, VideoInfoState>(
                    builder: (context, state) {
                  if (state is TakeVideoSuccess) {
                    return ProgressBar(
                                  processPhase: state.processPhase,
                                  progress: state.progress);
                  } else if (state is VideoInfoSuccess) {
                    return _getListView(state.videosInfo);
                  } else {
                    return Text(
                      'LOADING...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  }
                })),
                floatingActionButton:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  FloatingActionButton(
                    child:
                        /*_processing
                              ? CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              :*/
                        Icon(Icons.camera),
                    onPressed: () async {
                      if (widget.parentVideoInfo == null) {
                        _videoInfoBloc
                          ..takeVideo(user, ImageSource.camera,
                              widget.parentVideoReference, true);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                                value: _videoInfoBloc,
                                child: RecordingResponse(
                                  user: user,
                                  parentVideoReference:
                                      widget.parentVideoReference,
                                  parentVideoInfo: widget.parentVideoInfo,
                                  onCamera: () => _videoInfoBloc
                                    ..takeVideo(
                                        user,
                                        ImageSource.camera,
                                        widget.parentVideoReference
                                            .doc(widget.parentVideoInfo.id)
                                            .collection('videosInfo'),
                                        true),
                                )),
                          ),
                        );
                      }
                    },
                  ),
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
    _videoInfoBloc = VideoInfoBloc();
  }

  void listenToEncodingProviderProgress() {
    EncodingProvider.enableStatisticsCallback((Statistics stats) {});
  }

  _getListView(List<VideoInfo> videosInfo) {
    _videosInfo = videosInfo;
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _videosInfo.length,
        itemBuilder: (BuildContext context, int index) {
          VideoInfo videoInfo = _videosInfo[index];
          Video video = videoInfo.video;
          return GestureDetector(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return _player(context, videoInfo);
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
                                  width: 100.0,
                                  height: 150.0,
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
                                          'Uploaded ${videoInfo.createdAt == null ? timeago.format(DateTime.now()) : timeago.format(fromTimestampToDate(videoInfo.createdAt))}'),
                                    ),
                                    ElevatedButton(
                                        onPressed: () => Navigator.pushNamed(
                                                context, '/videos',
                                                arguments: {
                                                  'title': 'Responses',
                                                  'parentVideoInfo': videoInfo,
                                                  'parentVideoReference': widget
                                                      .parentVideoReference
                                                      .doc(videoInfo.id)
                                                      .collection('videosInfo'),
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

  _player(BuildContext context, VideoInfo videoInfo) {
    if (widget.parentVideoInfo == null) {
      return PlayerSingle(
          videoInfo: videoInfo,
          onCamera: () => _videoInfoBloc
            ..takeVideo(
                user,
                ImageSource.camera,
                widget.parentVideoReference
                    .doc(videoInfo.id)
                    .collection('videosInfo'),
                false));
    } else {
      return BlocProvider.value(
          value: _videoInfoBloc,
          child: PlayerDouble(
            videoReference: widget.parentVideoReference.doc(videoInfo.id),
            parentVideoInfo: widget.parentVideoInfo,
            videoInfo: videoInfo,
            onCamera: () => _videoInfoBloc
              ..takeVideo(
                  user,
                  ImageSource.camera,
                  widget.parentVideoReference
                      .doc(videoInfo.id)
                      .collection('videosInfo'),
                  false),
          ));
    }
  }

  _setUpParameters() {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    if (args == null) {
      return;
    }
    if (args['title'] != null) {
      widget.title = args['title'];
    }
    if (args['parentVideoInfo'] != null) {
      widget.parentVideoInfo = args['parentVideoInfo'];
    }
    if (args['parentVideoReference'] != null) {
      widget.parentVideoReference = args['parentVideoReference'];
    }
  }
}
