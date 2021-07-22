import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/components/uploading_modal_success.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ModalMananger extends StatefulWidget {
  final UploadFrom cameFrom;
  ModalMananger(this.cameFrom);
  @override
  _ModalManangerState createState() => _ModalManangerState();
}

class _ModalManangerState extends State<ModalMananger> {
  Widget viewToDisplay;

  @override
  Widget build(BuildContext context) {
    if (widget.cameFrom == UploadFrom.transformationJourney) {
      viewToDisplay =
          BlocBuilder<TransformationJourneyBloc, TransformationJourneyState>(
        builder: (context, state) {
          if (state is TransformationJourneyLoading) {
            return UploadingModalLoader();
          }
          if (state is TransformationJourneyLoading) {
            return UploadingModalSuccess(widget.cameFrom);
          }
          return Container();
        },
      );
    }

    if (widget.cameFrom == UploadFrom.profileImage) {
      viewToDisplay = BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (ProfileState previous, ProfileState current) =>
            current is UploadingModalSuccess || current is Loading,
        builder: (context, state) {
          Widget finalWidget = UploadingModalSuccess(widget.cameFrom);
          if (state is Loading) {
            finalWidget = UploadingModalLoader();
          }
          if (state is ProfileUploadSuccess) {
            finalWidget = UploadingModalSuccess(widget.cameFrom);
          }
          return finalWidget;
        },
      );
    }

    return viewToDisplay;
  }
}
