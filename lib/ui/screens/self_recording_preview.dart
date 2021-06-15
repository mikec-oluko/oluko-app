import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';

class SelfRecordingPreview extends StatefulWidget {
  SelfRecordingPreview({this.task, Key key}) : super(key: key);

  final Task task;

  @override
  _SelfRecordingPreviewState createState() => _SelfRecordingPreviewState();
}

class _SelfRecordingPreviewState extends State<SelfRecordingPreview> {
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
      height: MediaQuery.of(context).size.height / 4,
      child: BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
        return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              formFields(state),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  OlukoPrimaryButton(title: 'Start Recording'),
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
