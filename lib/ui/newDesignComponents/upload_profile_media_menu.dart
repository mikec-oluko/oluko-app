import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_avatar_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_cover_image_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class UploadProfileMediaMenu extends StatefulWidget {
  final bool deleteContent;
  final Success galleryState;
  final UploadFrom contentFrom;

  const UploadProfileMediaMenu({this.galleryState, this.contentFrom, this.deleteContent = false}) : super();

  @override
  _UploadProfileMediaMenuState createState() => _UploadProfileMediaMenuState();
}

enum Actions { uploadFromCamera, uploadFromGallery, deleteImage }

class _UploadProfileMediaMenuState extends State<UploadProfileMediaMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Actions>(
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<Actions>>[
          PopupMenuItem(
            onTap: () {
              uploadContentFromCamera(context);
            },
            // value: Actions.unenroll,
            padding: EdgeInsets.zero,
            child: Container(
                color: OlukoNeumorphismColors.appBackgroundColor,
                child: ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.white,
                  ),
                  title: Text(OlukoLocalizations.get(context, 'camera'), style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
                )),
          ),
          PopupMenuItem(
            onTap: () {
              uploadContentFromGallery(context);
            },
            // value: Actions.unenroll,
            padding: EdgeInsets.zero,
            child: Container(
                color: OlukoNeumorphismColors.appBackgroundColor,
                child: ListTile(
                  leading: imageWrapper(),
                  title: Text(OlukoLocalizations.get(context, 'fromGallery'), style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
                )),
          ),
          if (widget.deleteContent)
            PopupMenuItem(
              onTap: () {
                deleteContentAction(context);
              },
              padding: EdgeInsets.zero,
              child: Container(
                  color: OlukoNeumorphismColors.appBackgroundColor,
                  child: ListTile(
                    leading: Image.asset(
                      'assets/neumorphic/bin.png',
                      color: Colors.red,
                      scale: 4.5,
                    ),
                    title: Text(OlukoLocalizations.get(context, 'deleteImage'), style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white)),
                  )),
            ),
        ];
      },
      color: OlukoNeumorphismColors.appBackgroundColor,
      icon: Image.asset(
        'assets/profile/uploadImage.png',
        scale: 4,
      ),
      iconSize: 24,
      padding: EdgeInsets.zero,
    );
  }

  Widget imageWrapper() {
    if (widget.galleryState is Success) {
      return Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          image: DecorationImage(fit: BoxFit.cover, image: MemoryImage(widget.galleryState.firstImage)),
        ),
      );
    } else {
      return Container(
        width: 25,
        height: 25,
        child: const Icon(
          Icons.image,
          size: 20,
          color: OlukoColors.grayColor,
        ),
      );
    }
  }

  void uploadContentFromCamera(BuildContext context) {
    switch (widget.contentFrom) {
      case UploadFrom.profileImage:
        BlocProvider.of<ProfileAvatarBloc>(context).uploadProfileAvatarImage(uploadedFrom: DeviceContentFrom.camera, contentFor: UploadFrom.profileImage);
        break;
      case UploadFrom.profileCoverImage:
        BlocProvider.of<ProfileCoverImageBloc>(context).uploadProfileCoverImage(
          uploadedFrom: DeviceContentFrom.camera,
        );
        break;
      default:
    }
  }

  void uploadContentFromGallery(BuildContext context) {
    switch (widget.contentFrom) {
      case UploadFrom.profileImage:
        BlocProvider.of<ProfileAvatarBloc>(context).uploadProfileAvatarImage(uploadedFrom: DeviceContentFrom.gallery, contentFor: UploadFrom.profileImage);
        break;
      case UploadFrom.profileCoverImage:
        BlocProvider.of<ProfileCoverImageBloc>(context).uploadProfileCoverImage(
          uploadedFrom: DeviceContentFrom.gallery,
        );
        break;
      default:
        return;
    }
  }

  void deleteContentAction(BuildContext context) {
    switch (widget.contentFrom) {
      case UploadFrom.profileImage:
        BlocProvider.of<ProfileAvatarBloc>(context).removeProfilePicture();
        break;
      case UploadFrom.profileCoverImage:
        BlocProvider.of<ProfileCoverImageBloc>(context).removeProfileCoverImage();
        break;
      default:
        return;
    }
  }
}
