import 'package:flutter/material.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/ui/components/oluko_outlined_button.dart';
import 'package:mvt_fitness/ui/components/oluko_primary_button.dart';

class UploadingModalSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: CircleAvatar(
              backgroundColor: OlukoColors.primary,
              radius: 40.0,
              child: IconButton(
                  icon: Icon(Icons.check, color: OlukoColors.black),
                  onPressed: () {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Uploaded Successfully",
              style:
                  OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.w400),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: OlukoOutlinedButton(
                  title: "Done",
                  onPressed: () => Navigator.pop(context),
                )),
          )
        ],
      ),
    );
  }
}
