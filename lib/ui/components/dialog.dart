import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/constants/theme.dart';

class DialogWidget extends StatefulWidget {
  final List<Widget> content;
  DialogWidget({this.content});
  @override
  _DialogWidgetState createState() => _DialogWidgetState();
}

class _DialogWidgetState extends State<DialogWidget> {
  @override
  Widget build(BuildContext context) {
    return _dialogContent(context, widget.content);
  }
}

_dialogContent(BuildContext context, List<Widget> content) {
  return Container(
      color: OlukoColors.black,
      child: BlocProvider.value(
        value: BlocProvider.of<ProfileBloc>(context),
        child: ListView(
          shrinkWrap: true,
          children: content,
        ),
      ));
}
