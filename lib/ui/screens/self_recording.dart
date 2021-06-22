import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/self_recording_preview.dart';

class SelfRecording extends StatefulWidget {
  SelfRecording({this.task, Key key}) : super(key: key);

  final Task task;
  bool _recording = false;

  @override
  _State createState() => _State();
}

class _State extends State<SelfRecording> {
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
            bottomNavigationBar: bottomNavigationBar(),
            body: Container(
                color: Colors.black,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width,
                                      maxHeight:
                                          MediaQuery.of(context).size.height /
                                              1.8),
                                  child: Stack(
                                    children: showVideoPlayer(),
                                  )),
                              BlocBuilder<TaskBloc, TaskState>(
                                  builder: (context, state) {
                                return formSection();
                              }),
                            ],
                          )
                        ],
                      ),
                    )))));
  }

  Widget formSection() {
    return Container(
      child: BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
        return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              formFields(state),
            ]);
      }),
    );
  }

  Widget formFields(TaskState state) {
    if (state is TaskSuccess) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                widget.task.stepsTitle != null
                    ? TitleBody(widget.task.stepsTitle)
                    : SizedBox()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.task.stepsDescription != null
                        ? Text(
                            '${widget.task.stepsDescription.replaceAll('\\n', '\n')} ',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white60),
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          )
        ],
      );
    } else {
      return SizedBox();
    }
  }

  List<Widget> showVideoPlayer() {
    List<Widget> widgets = [];
    widgets.add(OlukoVideoPlayer(
        autoPlay: false,
        showControls: false,
        //TODO: Hardcoded
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

  Widget bottomNavigationBar() {
    return BottomAppBar(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              Icons.photo_camera,
              size: 45,
              color: Colors.white,
            ),
            GestureDetector(
              onTap: () => this.setState(() {
                //TODO Remove this when implementing video recording
                if (widget._recording == true) {
                  _controller.seekTo(Duration(milliseconds: 0));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SelfRecordingPreview(task: widget.task)));
                } else {
                  _controller.play();
                }
                widget._recording = !widget._recording;
              }),
              child: widget._recording
                  ? Image.asset('assets/self_recording/recording.png')
                  : Image.asset('assets/self_recording/record.png'),
            ),
            Image.asset('assets/self_recording/gallery.png'),
          ],
        ),
      ),
    );
  }
}
