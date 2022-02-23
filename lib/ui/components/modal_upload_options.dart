import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
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
  bool isOptionSelected = false;
  @override
  void initState() {
    setState(() {
      isOptionSelected = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return returnList(context);
  }

  Widget returnList(BuildContext context) {
    return Container(
      color: OlukoNeumorphismColors.appBackgroundColor,
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          ListTile(
            onTap: () {
              if (isOptionSelected == false) {
                setState(() {
                  isOptionSelected = true;
                });
                uploadContentFromCamera(context);
              }
            },
            leading: const Icon(
              Icons.camera_alt_outlined,
              color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.white,
            ),
            title: Text(OlukoLocalizations.get(context, 'camera'), style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
          ),
          ListTile(
            onTap: () {
              if (isOptionSelected == false) {
                setState(() {
                  isOptionSelected = true;
                });
                uploadContentFromGallery(context);
              }
            },
            leading: OlukoNeumorphism.isNeumorphismDesign
                ? imageWrapper()
                : const Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
            title: Text(OlukoLocalizations.get(context, 'fromGallery'), style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
          ),
        ],
      ),
    );
  }

  Widget imageWrapper() {
    return BlocBuilder<GalleryVideoBloc, GalleryVideoState>(
      builder: (context, state) {
        if (state is Success) {
          return Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              image: DecorationImage(fit: BoxFit.cover, image: MemoryImage(state.firstMediaItem)),
            ),
          );
        } else {
          return const Icon(
            Icons.file_upload,
            size: 20,
            color: OlukoColors.grayColor,
          );
        }
      },
    );
  }

  void uploadContentFromCamera(BuildContext context) {
    switch (widget.contentFrom) {
      case UploadFrom.profileImage:
        BlocProvider.of<ProfileAvatarBloc>(context).uploadProfileAvatarImage(uploadedFrom: DeviceContentFrom.camera);
        break;
      case UploadFrom.profileCoverImage:
        BlocProvider.of<ProfileCoverImageBloc>(context).uploadProfileCoverImage(
          uploadedFrom: DeviceContentFrom.camera,
        );
        break;
      case UploadFrom.transformationJourney:
        BlocProvider.of<TransformationJourneyContentBloc>(context)
            .uploadTransformationJourneyContent(uploadedFrom: DeviceContentFrom.camera, indexForContent: widget.indexValue);
        break;
      default:
    }
  }

  void uploadContentFromGallery(BuildContext context) {
    switch (widget.contentFrom) {
      case UploadFrom.profileImage:
        BlocProvider.of<ProfileAvatarBloc>(context).uploadProfileAvatarImage(uploadedFrom: DeviceContentFrom.gallery);
        break;
      case UploadFrom.profileCoverImage:
        BlocProvider.of<ProfileCoverImageBloc>(context).uploadProfileCoverImage(
          uploadedFrom: DeviceContentFrom.gallery,
        );
        break;
      case UploadFrom.transformationJourney:
        BlocProvider.of<TransformationJourneyContentBloc>(context)
            .uploadTransformationJourneyContent(uploadedFrom: DeviceContentFrom.gallery, indexForContent: widget.indexValue);
        break;
      default:
        return;
    }
  }
}
