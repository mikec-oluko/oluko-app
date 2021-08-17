import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
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
    return modalOptionsViewWithProviders(context);
  }

  Container returnList(BuildContext context) {
    return Container(
      color: OlukoColors.black,
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            onTap: () {
              uploadContentFromCamera(context);
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
              uploadContentFromGallery(context);
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

  void uploadContentFromCamera(BuildContext context) {
    if (widget.contentFrom == UploadFrom.profileImage ||
        widget.contentFrom == UploadFrom.profileCoverImage) {
      BlocProvider.of<ProfileBloc>(context)
        ..uploadImageForProfile(
            uploadedFrom: DeviceContentFrom.camera,
            contentFor: widget.contentFrom);
    }
    if (widget.contentFrom == UploadFrom.transformationJourney) {
      BlocProvider.of<TransformationJourneyBloc>(context)
        ..uploadTransformationJourneyContent(
            uploadedFrom: DeviceContentFrom.camera);
    }
  }

  void uploadContentFromGallery(BuildContext context) {
    if (widget.contentFrom == UploadFrom.profileImage ||
        widget.contentFrom == UploadFrom.profileCoverImage) {
      BlocProvider.of<ProfileBloc>(context)
        ..uploadImageForProfile(
            uploadedFrom: DeviceContentFrom.gallery,
            contentFor: widget.contentFrom);
    }
    if (widget.contentFrom == UploadFrom.transformationJourney) {
      BlocProvider.of<TransformationJourneyBloc>(context)
        ..uploadTransformationJourneyContent(
            uploadedFrom: DeviceContentFrom.gallery);
    }
  }

  modalOptionsViewWithProviders(BuildContext context) {
    return returnList(context);
  }
}
