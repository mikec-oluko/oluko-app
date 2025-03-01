import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_get_header_for_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachTimelineVideoContent extends StatefulWidget {
  const CoachTimelineVideoContent({this.videoTitle, this.videoThumbnail, this.date, this.fileType});
  final String videoTitle, videoThumbnail;
  final DateTime date;
  final CoachFileTypeEnum fileType;

  @override
  _CoachTimelineVideoContentState createState() => _CoachTimelineVideoContentState();
}

class _CoachTimelineVideoContentState extends State<CoachTimelineVideoContent> {
  final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
  @override
  Widget build(BuildContext context) {
    final double _height = 70;
    final double _width = 140;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                width: _width,
                height: _height,
                child: Stack(
                  children: [
                    Align(
                        child: Neumorphic(
                      style: OlukoNeumorphism.getNeumorphicStyleForCardElement(),
                      child: CachedNetworkImage(
                        imageUrl: widget.videoThumbnail,
                        width: _width,
                        height: _height,
                        maxWidthDiskCache: _width.toInt(),
                        maxHeightDiskCache: _height.toInt(),
                        memCacheWidth: _width.toInt(),
                        memCacheHeight: _height.toInt(),
                        fit: BoxFit.cover,
                        imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) => Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                              color: OlukoColors.warning,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
                          width: 60,
                          height: 90,
                        ),
                      ),
                    )),
                    Align(
                      child: SizedBox(
                        child: OlukoNeumorphism.isNeumorphismDesign
                            ? Container(
                                width: 40,
                                height: 40,
                                child: OlukoBlurredButton(
                                    childContent: Image.asset('assets/courses/play_arrow.png', height: 5, width: 5, scale: 4, color: OlukoColors.white)),
                              )
                            : Image.asset(
                                'assets/self_recording/play_button.png',
                                color: Colors.white,
                                height: 40,
                                width: 40,
                              ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ScreenUtils.modifiedFont(context)
                      ? SizedBox(
                          width: ScreenUtils.width(context) * 0.33,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(CoachHeders.getContentHeader(context: context, fileType: widget.fileType),
                                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500)),
                              Text(widget.videoTitle, style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(CoachHeders.getContentHeader(context: context, fileType: widget.fileType),
                                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500)),
                            Text(widget.videoTitle,
                                overflow: TextOverflow.ellipsis,
                                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500)),
                          ],
                        ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(DateFormat.jm().format(widget.date).toString(), style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor)),
          ),
        ],
      ),
    );
  }
}
