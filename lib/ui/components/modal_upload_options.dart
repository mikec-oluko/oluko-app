import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ModalUploadOptions extends StatefulWidget {
  final UploadFrom contentFrom;
  ModalUploadOptions(this.contentFrom);
  @override
  _ModalUploadOptionsState createState() => _ModalUploadOptionsState();
}

class _ModalUploadOptionsState extends State<ModalUploadOptions> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider.value(value: BlocProvider.of<ProfileBloc>(context)),
      BlocProvider.value(value: BlocProvider.of<AuthBloc>(context)),
      BlocProvider.value(
          value: BlocProvider.of<TransformationJourneyBloc>(context)),
    ], child: returnList(context));
  }

  Container returnList(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            onTap: () {
              if (widget.contentFrom == UploadFrom.profileImage) {
                BlocProvider.of<ProfileBloc>(context)
                  ..updateUserProfileAvatar(
                      uploadedFrom: DeviceContentFrom.camera);
                AppModal.dialogContent(
                    context: context,
                    content: [UploadingModalLoader(widget.contentFrom)]);
              }
              if (widget.contentFrom == UploadFrom.transformationJourney) {
                BlocProvider.of<TransformationJourneyBloc>(context)
                  ..uploadTransformationJourneyContent(
                      uploadedFrom: DeviceContentFrom.camera);
                AppModal.dialogContent(
                    context: context,
                    content: [UploadingModalLoader(widget.contentFrom)]);
              }
            },
            leading: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
            ),
            title: Text(OlukoLocalizations.of(context).find('camera'),
                style:
                    OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
          ),
          ListTile(
            onTap: () {
              if (widget.contentFrom == UploadFrom.profileImage) {
                BlocProvider.of<ProfileBloc>(context)
                  ..updateUserProfileAvatar(
                      uploadedFrom: DeviceContentFrom.gallery);
                //TODO: Check Navigator.pop();
                AppModal.dialogContent(
                    context: context,
                    content: [UploadingModalLoader(widget.contentFrom)]);
              }
              if (widget.contentFrom == UploadFrom.transformationJourney) {
                BlocProvider.of<TransformationJourneyBloc>(context)
                  ..uploadTransformationJourneyContent(
                      uploadedFrom: DeviceContentFrom.gallery);
                AppModal.dialogContent(
                    context: context,
                    content: [UploadingModalLoader(widget.contentFrom)]);
              }
            },
            leading: Icon(
              Icons.image,
              color: Colors.white,
            ),
            title: Text(OlukoLocalizations.of(context).find('fromGallery'),
                style:
                    OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
          ),
        ],
      ),
    );
  }
}
