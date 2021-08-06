import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class TransformationJourneyContentDetail extends StatefulWidget {
  final TransformationJourneyUpload contentToShow;
  TransformationJourneyContentDetail({this.contentToShow});

  @override
  _TransformationJourneyContentDetailState createState() =>
      _TransformationJourneyContentDetailState();
}

class _TransformationJourneyContentDetailState
    extends State<TransformationJourneyContentDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: OlukoColors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: OlukoColors.black,
        child: Stack(
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                      TimeConverter.returnDateAndTimeOnStringFormat(
                          dateToFormat: widget.contentToShow.createdAt),
                      style: OlukoFonts.olukoBigFont(
                          customColor: OlukoColors.white)),
                )),
            Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: OlukoColors.black,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          image: Image.network(
                            widget.contentToShow.file,
                            frameBuilder: (BuildContext context, Widget child,
                                    int frame, bool wasSynchronouslyLoaded) =>
                                ImageUtils.frameBuilder(context, child, frame,
                                    wasSynchronouslyLoaded,
                                    height: 120),
                          ).image)),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                )),
          ],
        ),
      ),
    );
  }
}
