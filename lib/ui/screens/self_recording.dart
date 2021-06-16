import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/title_body.dart';
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
            bottomNavigationBar: BottomAppBar(
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
                        widget._recording = !widget._recording;
                        //TODO Remove this when implementing video recording
                        if (widget._recording == false) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SelfRecordingPreview(task: widget.task)));
                        }
                      }),
                      child: widget._recording
                          ? Image.asset('assets/self_recording/recording.png')
                          : Image.asset('assets/self_recording/record.png'),
                    ),
                    Image.asset('assets/self_recording/gallery.png'),
                  ],
                ),
              ),
            ),
            body: Container(
                color: Colors.black,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Image.asset(
                              'assets/self_recording/self_recording_placeholder.png'),
                          BlocBuilder<TaskBloc, TaskState>(
                              builder: (context, state) {
                            return formSection();
                          }),
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
    if (state is Success) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [TitleBody('Tell us the following things about you')],
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
                    Text(
                      '1. Your Name?',
                      style: TextStyle(fontSize: 20, color: Colors.white60),
                    ),
                    Text(
                      '2. Your Age?',
                      style: TextStyle(fontSize: 20, color: Colors.white60),
                    ),
                    Text(
                      '3. Your Fitness Goal?',
                      style: TextStyle(fontSize: 20, color: Colors.white60),
                    )
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
}
