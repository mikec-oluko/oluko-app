import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/task_details.dart';

class SelfRecordingPreview extends StatefulWidget {
  SelfRecordingPreview({this.task, Key key}) : super(key: key);

  final Task task;

  @override
  _SelfRecordingPreviewState createState() => _SelfRecordingPreviewState();
}

class _SelfRecordingPreviewState extends State<SelfRecordingPreview> {
  final _formKey = GlobalKey<FormState>();
  SignUpResponse profileInfo;
  ChewieController _controller;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc()..get(),
      child: form(),
    );
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: OlukoAppBar(title: widget.task.name),
            body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(children: [
                              OlukoPrimaryButton(
                                title: 'Done',
                                onPressed: () {
                                  _controller.pause();
                                  Navigator.popUntil(
                                      context, ModalRoute.withName('/'));
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TaskDetails(
                                              task: widget.task,
                                              showRecordedVideos: true)));
                                },
                              )
                            ]),
                          ),
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 1.5),
                              child: Stack(children: showVideoPlayer())),
                        ],
                      ),
                    )))));
  }

  List<Widget> showVideoPlayer() {
    List<Widget> widgets = [];
    widgets.add(OlukoVideoPlayer(
        videoUrl:
            'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/pexels-anthony-shkraba-production-8135646.mp4?alt=media&token=f3bd01db-8d38-492f-8cf9-386ba7a90d32',
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    return widgets;
  }
}
