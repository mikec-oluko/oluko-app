import 'package:flutter/material.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/ui/components/uploading_modal_success.dart';
import 'package:mvt_fitness/utils/app_modal.dart';
import 'package:mvt_fitness/utils/oluko_localizations.dart';

class UploadingModalLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                  valueColor:
                      AlwaysStoppedAnimation<Color>(OlukoColors.primary)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0).copyWith(top: 50),
            child: GestureDetector(
              onDoubleTap: () {
                Navigator.pop(context);
                AppModal.dialogContent(
                    context: context, content: [UploadingModalSuccess()]);
              },
              child: Text(
                OlukoLocalizations.of(context).find('uploadingWithDots'),
                style:
                    OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.w400),
              ),
            ),
          )
        ],
      ),
    );
  }
}
