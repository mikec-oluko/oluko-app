import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_avatar_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_cover_image_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_transformation_journey_content_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ModalUploadOptions extends StatefulWidget {
  final UploadFrom contentFrom;
  final int indexValue;
  ModalUploadOptions({this.contentFrom, this.indexValue});
  @override
  _ModalUploadOptionsState createState() => _ModalUploadOptionsState();
}

class _ModalUploadOptionsState extends State<ModalUploadOptions> {
  @override
  Widget build(BuildContext context) {
    return modalOptionsViewWithProviders(context);
  }

  Widget returnList(BuildContext context) {
    return Container(
      color: OlukoColors.black,
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView(
        padding: EdgeInsets.zero,
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
    if (widget.contentFrom == UploadFrom.profileImage) {
      BlocProvider.of<ProfileAvatarBloc>(context)
        ..uploadProfileAvatarImage(
          uploadedFrom: DeviceContentFrom.camera,
        );
    }
    if (widget.contentFrom == UploadFrom.profileCoverImage) {
      BlocProvider.of<ProfileCoverImageBloc>(context)
        ..uploadProfileCoverImage(
          uploadedFrom: DeviceContentFrom.camera,
        );
    }
    if (widget.contentFrom == UploadFrom.transformationJourney) {
      BlocProvider.of<TransformationJourneyContentBloc>(context)
        ..uploadTransformationJourneyContent(
            uploadedFrom: DeviceContentFrom.camera,
            indexForContent: widget.indexValue);
    }
  }

  void uploadContentFromGallery(BuildContext context) {
    if (widget.contentFrom == UploadFrom.profileImage) {
      BlocProvider.of<ProfileAvatarBloc>(context)
        ..uploadProfileAvatarImage(uploadedFrom: DeviceContentFrom.gallery);
    }
    if (widget.contentFrom == UploadFrom.profileCoverImage) {
      BlocProvider.of<ProfileCoverImageBloc>(context)
        ..uploadProfileCoverImage(
          uploadedFrom: DeviceContentFrom.gallery,
        );
    }
    if (widget.contentFrom == UploadFrom.transformationJourney) {
      BlocProvider.of<TransformationJourneyContentBloc>(context)
        ..uploadTransformationJourneyContent(
            uploadedFrom: DeviceContentFrom.gallery,
            indexForContent: widget.indexValue);
    }
  }

  modalOptionsViewWithProviders(BuildContext context) {
    return returnList(context);
  }
}
