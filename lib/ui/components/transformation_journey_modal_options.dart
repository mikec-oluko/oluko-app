import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

class TransformationJourneyOptions extends StatefulWidget {
  final UploadFrom toUpload;
  TransformationJourneyOptions(this.toUpload);
  @override
  _TransformationJourneyOptionsState createState() =>
      _TransformationJourneyOptionsState();
}

class _TransformationJourneyOptionsState
    extends State<TransformationJourneyOptions> {
  final imagePicker = ImagePicker();

  Future getImage() async {
    final image = await imagePicker.getImage(source: ImageSource.camera);
    if (image == null) return;

    if (widget.toUpload == UploadFrom.transformationJourney) {
      await updateTransformationJourneyGallery(image);
    }
    if (widget.toUpload == UploadFrom.profileImage) {
      await updateUserProfileAvatar(image);
    }
  }

  Future getImageFromGallery() async {
    final image = await imagePicker.getImage(source: ImageSource.gallery);
    if (image == null) return;

    if (widget.toUpload == UploadFrom.transformationJourney) {
      await updateTransformationJourneyGallery(image);
    }
    if (widget.toUpload == UploadFrom.profileImage) {
      await updateUserProfileAvatar(image);
    }
  }

  Future updateUserProfileAvatar(PickedFile image) async {
    UserResponse user = await AuthRepository().retrieveLoginData();
    UserRepository().updateUserAvatar(user, image);
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
    return returnList(context);
  }

  Container returnList(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            onTap: () {
              getImage();
              Navigator.pop(context);
              AppModal.dialogContent(
                  context: context,
                  content: [UploadingModalSuccess(widget.toUpload)]);
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
              getImageFromGallery();
              Navigator.pop(context);
              AppModal.dialogContent(
                  context: context,
                  content: [UploadingModalSuccess(widget.toUpload)]);
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
