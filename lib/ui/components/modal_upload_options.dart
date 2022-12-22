import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_avatar_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_cover_image_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_transformation_journey_content_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ModalUploadOptions extends StatefulWidget {
  final UploadFrom contentFrom;
  final int indexValue;
  final bool showDeleteOnList;
  final bool isDeleteRequested;
  final Function() deleteAction;
  final Function() deleteCancelAction;
  ModalUploadOptions(
      {this.contentFrom, this.indexValue, this.isDeleteRequested = false, this.deleteAction, this.deleteCancelAction, this.showDeleteOnList = false});
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
    return _panelContent(context);
  }

  Widget _panelContent(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: OlukoNeumorphism.isNeumorphismDesign ? BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)) : BorderRadius.zero,
        color: OlukoNeumorphismColors.appBackgroundColor,
      ),
      width: MediaQuery.of(context).size.width,
      height: widget.isDeleteRequested ? 120 : 100,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: widget.isDeleteRequested ? [getDeleteMethod(context)] : getUploadMethods(context),
      ),
    );
  }

  Widget getDeleteMethod(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [Text(OlukoLocalizations.get(context, 'deleteContentAlert'), style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.bold))],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              OlukoNeumorphicPrimaryButton(
                  title: OlukoLocalizations.get(context, 'ok'),
                  onPressed: () {
                    if (widget.deleteAction != null) {
                      widget.deleteAction();
                    }
                  }),
              SizedBox(
                width: 20,
              ),
              OlukoNeumorphicSecondaryButton(
                  title: OlukoLocalizations.get(context, 'cancel'),
                  onPressed: () {
                    if (widget.deleteCancelAction != null) {
                      widget.deleteCancelAction();
                    }
                  })
            ],
          )
        ],
      ),
    );
  }

  List<Widget> getUploadMethods(BuildContext context) {
    return [
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
      ListTile(
        onTap: () {
          if (isOptionSelected == false) {
            setState(() {
              isOptionSelected = true;
            });
            // TODO: Add delete function by uploadFrom content (only profile/cover pictures)
          }
        },
        leading: Image.asset(
          'assets/neumorphic/bin.png',
          color: Colors.red,
          scale: 4.5,
        ),
        title: Text("Delete image", style: OlukoFonts.olukoSmallFont(customColor: Colors.red)),
        // OlukoLocalizations.get(context, 'fromGallery')
      ),
    ];
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
              image: DecorationImage(fit: BoxFit.cover, image: MemoryImage(state.firstImage)),
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
        BlocProvider.of<ProfileAvatarBloc>(context).uploadProfileAvatarImage(uploadedFrom: DeviceContentFrom.camera, contentFor: UploadFrom.profileImage);
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
        BlocProvider.of<ProfileAvatarBloc>(context).uploadProfileAvatarImage(uploadedFrom: DeviceContentFrom.gallery, contentFor: UploadFrom.profileImage);
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
