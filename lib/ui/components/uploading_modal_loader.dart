import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class UploadingModalLoader extends StatefulWidget {
  final UploadFrom toUpload;
  UploadingModalLoader(this.toUpload);
  @override
  _UploadingModalLoaderState createState() => _UploadingModalLoaderState();
}

class _UploadingModalLoaderState extends State<UploadingModalLoader> {
  @override
  Widget build(BuildContext context) {
    if (widget.toUpload == UploadFrom.transformationJourney) {
      return LoaderAndUploadingText();
    } else if (widget.toUpload == UploadFrom.profileImage || widget.toUpload == UploadFrom.profileCoverImage) {
      return LoaderAndUploadingText();
    } else if (widget.toUpload == UploadFrom.profileImage) {
      return LoaderAndUploadingText();
    }
    return Container();
  }
}

class LoaderAndUploadingText extends StatelessWidget {
  const LoaderAndUploadingText();
  @override
  Widget build(BuildContext context) {
    return Container(
        color: OlukoColors.black,
        width: MediaQuery.of(context).size.width,
        height: 300,
        child: Row(children: [
          Expanded(
            child: Container(
              color: OlukoColors.black,
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Transform.scale(
                      scale: 2,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: OlukoColors.grayColor,
                          valueColor: AlwaysStoppedAnimation<Color>(OlukoColors.primary)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0).copyWith(top: 50),
                    child: Text(
                      OlukoLocalizations.get(context, 'uploadingWithDots'),
                      style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
            ),
          )
        ]));
  }
}
