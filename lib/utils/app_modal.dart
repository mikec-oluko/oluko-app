import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/ui/components/dialog.dart';

class AppModal {
  //Function handler Dialog/Modal
  static dialogContent(
      {BuildContext context,
      List<Widget> content,
      dynamic valueToReturn,
      bool closeButton = false}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext _) {
          if (closeButton == true) {
            content.insert(
                0,
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: 20,
                    child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                  ),
                ));
          }

          return MultiBlocProvider(providers: [
            BlocProvider.value(value: BlocProvider.of<ProfileBloc>(context)),
            BlocProvider.value(value: BlocProvider.of<AuthBloc>(context)),
            BlocProvider.value(
                value: BlocProvider.of<TransformationJourneyBloc>(context))
          ], child: DialogWidget(content: content));
        });
  }
}
