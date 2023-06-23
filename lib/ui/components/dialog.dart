import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
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

Widget _dialogContent(BuildContext context, List<Widget> content) {
  return Container(
      color: OlukoColors.black,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: BlocProvider.of<ProfileBloc>(context)),
          BlocProvider.value(value: BlocProvider.of<AuthBloc>(context)),
          BlocProvider.value(value: BlocProvider.of<TransformationJourneyBloc>(context))
        ],
        child: ListView(
          physics: OlukoNeumorphism.listViewPhysicsEffect,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          shrinkWrap: true,
          children: content,
        ),
      ));
}
