import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

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
    setState(() {
      _image = File(image.path);
    });
  }

  Future getImageFromGallery() async {
    final image = await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      _imageFromGallery = File(image.path);
    });
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
                  context: context, content: [UploadingModalLoader()]);
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
                  context: context, content: [UploadingModalLoader()]);
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
