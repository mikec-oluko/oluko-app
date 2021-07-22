import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/transformation_journey_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/components/uploading_modal_success.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

import 'modal_manager.dart';

class ModalUploadOptions extends StatefulWidget {
  final UploadFrom toUpload;
  ModalUploadOptions(this.toUpload);
  @override
  _ModalUploadOptionsState createState() => _ModalUploadOptionsState();
}

class _ModalUploadOptionsState extends State<ModalUploadOptions> {
  final imagePicker = ImagePicker();

  Future getImage(BuildContext context) async {
    final image = await imagePicker.getImage(source: ImageSource.camera);
    if (image == null) return;

    if (widget.toUpload == UploadFrom.transformationJourney) {
      await updateTransformationJourneyGallery(image);
    }
    if (widget.toUpload == UploadFrom.profileImage) {
      await updateUserProfileAvatar(image, context);
    }
  }

  Future getImageFromGallery(BuildContext context) async {
    final image = await imagePicker.getImage(source: ImageSource.gallery);
    if (image == null) return;

    if (widget.toUpload == UploadFrom.transformationJourney) {
      await updateTransformationJourneyGallery(image);
    }
    if (widget.toUpload == UploadFrom.profileImage) {
      await updateUserProfileAvatar(image, context);
    }
  }

  Future updateUserProfileAvatar(PickedFile image, BuildContext context) async {
    BlocProvider.of<ProfileBloc>(context)..updateUserProfileAvatar();
  }

  Future updateTransformationJourneyGallery(PickedFile image) async {
    UserResponse user = await AuthRepository().retrieveLoginData();
    TransformationJourneyUpload upload =
        await TransformationJourneyRepository.createTransformationJourneyUpload(
            FileTypeEnum.image, image, user.username);
    print(upload);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: returnList(context),
    );
  }

  Container returnList(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            onTap: () {
              getImage(context);
              Navigator.pop(context);
              AppModal.dialogContent(context: context, content: [
                BlocProvider(
                  create: (context) => ProfileBloc(),
                  child: ModalMananger(widget.toUpload),
                )
              ]);
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
              BlocProvider.of<ProfileBloc>(context)..updateUserProfileAvatar();
              AppModal.dialogContent(context: context, content: [
                BlocProvider(
                  create: (context) => ProfileBloc(),
                  child: ModalMananger(widget.toUpload),
                )
              ]);
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
