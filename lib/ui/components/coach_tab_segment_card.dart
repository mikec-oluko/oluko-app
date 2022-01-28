import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachTabSegmentCard extends StatefulWidget {
  final CoachSegmentContent segment;
  const CoachTabSegmentCard({this.segment});

  @override
  _CoachTabSegmentCardState createState() => _CoachTabSegmentCardState();
}

class _CoachTabSegmentCardState extends State<CoachTabSegmentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: OlukoColors.challengesGreyBackground, borderRadius: BorderRadius.all(Radius.circular(5))),
      height: 100,
      width: 150,
      child: Wrap(
        children: [
          Row(
            children: [
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: widget.segment.classImage != null
                      ? Container(
                          decoration: BoxDecoration(
                            color: OlukoColors.challengesGreyBackground,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(widget.segment.classImage),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                return Text('Your error widget...');
                              },
                            ),
                          ),
                          width: 60,
                          height: 90,
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            color: OlukoColors.grayColor,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          width: 60,
                          height: 90,
                          child: Center(
                              child: Text(
                            OlukoLocalizations.get(context, 'segment'),
                            style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                          )),
                        )),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              widget.segment.className,
                              style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              widget.segment.segmentName,
                              overflow: TextOverflow.ellipsis,
                              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
