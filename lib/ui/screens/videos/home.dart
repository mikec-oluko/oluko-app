import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/ui/screens/videos/player_response.dart';
import 'package:oluko_app/ui/screens/videos/player_single.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/ui/screens/videos/recording_response.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:oluko_app/helpers/encoding_provider.dart';
import 'package:oluko_app/models/video.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/foundation.dart' show kIsWeb;
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
  VideoBloc _videoBloc;

  //int _videoDuration = 0;

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
                _videoBloc..getVideos(this.user, widget.parentVideoReference),
            child: Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                ),
                body: Center(child: BlocBuilder<VideoBloc, VideoState>(
                    builder: (context, state) {
                  if (state is TakeVideoSuccess) {
                    return _getProgressBar(state.processPhase, state.progress);
                  } else if (state is VideosSuccess) {
                    return _getListView(state.videos);
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
                      if (widget.videoParent == null) {
                        _videoBloc
                          ..takeVideo(user, ImageSource.camera,
                              widget.parentVideoReference, true);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return RecordingResponse(
                                parentVideoReference:
                                    widget.parentVideoReference,
                                videoParent: widget.videoParent,
                                onCamera: () => _videoBloc
                                  ..takeVideo(
                                      user,
                                      ImageSource.camera,
                                      widget.parentVideoReference
                                          .doc(widget.videoParent.id)
                                          .collection('videoResponses'),
                                      true),
                              );
                            },
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
    _videoBloc = VideoBloc();
  }

  void listenToEncodingProviderProgress() {
    EncodingProvider.enableStatisticsCallback((Statistics stats) {
      /*setState(() {
        _progress = stats.time / _videoDuration;
      });*/
    });
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
          onCamera: () => _videoBloc
            ..takeVideo(
                user,
                ImageSource.camera,
                widget.parentVideoReference
                    .doc(video.id)
                    .collection('videoResponses'),
                false));
    } else {
      return PlayerResponse(
        videoReference: widget.parentVideoReference.doc(video.id),
        videoParent: widget.videoParent,
        video: video,
        onCamera: () => _videoBloc
          ..takeVideo(
              user,
              ImageSource.camera,
              widget.parentVideoReference
                  .doc(video.id)
                  .collection('videoResponses'),
              false),
      );
    }
  }

  _getProgressBar(String processPhase, double progress) {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            child: Text(processPhase),
          ),
          LinearProgressIndicator(
            value: progress,
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
