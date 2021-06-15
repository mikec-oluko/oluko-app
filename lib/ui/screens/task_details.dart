import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/self_recording_preview.dart';

class TaskDetails extends StatefulWidget {
  TaskDetails({this.task, Key key}) : super(key: key);

  final Task task;

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final _formKey = GlobalKey<FormState>();
  SignUpResponse profileInfo;

  bool _makePublic = false;

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
                color: Colors.black,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Container(child: OlukoVideoPlayer()),
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
      height: MediaQuery.of(context).size.height / 1.75,
      child: BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
        return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              formFields(state),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  OlukoPrimaryButton(
                    title: 'Start Recording',
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SelfRecordingPreview(task: widget.task))),
                  ),
                ],
              ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleBody(
                  'Make this public',
                  bold: true,
                ),
                Switch(
                  value: _makePublic,
                  onChanged: (bool value) => this.setState(() {
                    _makePublic = value;
                  }),
                  trackColor: MaterialStateProperty.all(Colors.grey),
                  activeColor: OlukoColors.primary,
                )
              ],
            ),
          ),
          Text(
            widget.task.description,
            style: TextStyle(fontSize: 17, color: Colors.white60),
          )
        ],
      );
    } else {
      return SizedBox();
    }
  }
}
