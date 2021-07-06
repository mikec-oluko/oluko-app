import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class TransformationJourneyOptions extends StatelessWidget {
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
              Navigator.pop(context);
              ProfileViewConstants.dialogContent(
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
              Navigator.pop(context);
              ProfileViewConstants.dialogContent(
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
