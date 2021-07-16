import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/models/enums/file_type_enum.dart';
import 'package:mvt_fitness/models/transformation_journey_uploads.dart';
import 'package:mvt_fitness/models/user_response.dart';
import 'package:mvt_fitness/repositories/auth_repository.dart';
import 'package:mvt_fitness/repositories/transformation_journey_repository.dart';
import 'package:mvt_fitness/ui/components/uploading_modal_loader.dart';
import 'package:mvt_fitness/ui/components/uploading_modal_success.dart';
import 'package:mvt_fitness/ui/screens/profile/profile_routes.dart';
import 'package:mvt_fitness/utils/app_modal.dart';
import 'package:mvt_fitness/utils/oluko_localizations.dart';

class TransformationJourneyOptions extends StatefulWidget {
  @override
  _TransformationJourneyOptionsState createState() =>
      _TransformationJourneyOptionsState();
}

class _TransformationJourneyOptionsState
    extends State<TransformationJourneyOptions> {
  File _image;
  File _imageFromGallery;
  final imagePicker = ImagePicker();

  Future getImage() async {
    final image = await imagePicker.getImage(source: ImageSource.camera);
    if (image == null) return;
    UserResponse user = await AuthRepository().retrieveLoginData();
    TransformationJourneyUpload upload =
        await TransformationJourneyRepository.createTransformationJourneyUpload(
            FileTypeEnum.image, image, user.username);
    print(upload);
  }

  Future getImageFromGallery() async {
    final image = await imagePicker.getImage(source: ImageSource.gallery);
    // setState(() {
    //   _imageFromGallery = File(image.path);
    // });
    if (image == null) return;
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
                  context: context, content: [UploadingModalSuccess()]);
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
                  context: context, content: [UploadingModalSuccess()]);
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
