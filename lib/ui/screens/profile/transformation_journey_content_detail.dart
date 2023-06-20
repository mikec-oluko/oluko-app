import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class TransformationJourneyContentDetail extends StatefulWidget {
  final TransformationJourneyUpload contentToShow;
  final CoachMedia coachMedia;
  TransformationJourneyContentDetail({this.contentToShow, this.coachMedia});

  @override
  _TransformationJourneyContentDetailState createState() => _TransformationJourneyContentDetailState();
}

class _TransformationJourneyContentDetailState extends State<TransformationJourneyContentDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      appBar: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight * 1.5), child: getAppBar()),
      body: widget.contentToShow != null
          ? showImageDetailsView(context: context, imageUrl: widget.contentToShow.file, contentCreatedAt: widget.contentToShow.createdAt)
          : showImageDetailsView(context: context, imageUrl: widget.coachMedia.imageUrl, contentCreatedAt: widget.coachMedia.createdAt),
    );
  }

  Container showImageDetailsView({BuildContext context, String imageUrl, Timestamp contentCreatedAt}) {
    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: OlukoNeumorphismColors.appBackgroundColor,
      child: Stack(
        children: [
          Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: OlukoColors.black,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        image: Image(
                          image: CachedNetworkImageProvider(imageUrl),
                          frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
                              ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 120),
                        ).image)),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              )),
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(TimeConverter.returnDateAndTimeOnStringFormat(dateToFormat: contentCreatedAt, context: context),
                    style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white)),
              )),
        ],
      ),
    );
  }

  Widget getAppBar() {
    return !OlukoNeumorphism.isNeumorphismDesign
        ? AppBar(
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
          )
        : OlukoAppBar(
            showTitle: true,
            showBackButton: true,
            title: '',
          );
  }
}
