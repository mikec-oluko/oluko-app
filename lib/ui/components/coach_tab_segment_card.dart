import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';

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
      height: 100,
      width: 150,
      color: OlukoColors.challengesGreyBackground,
      child: Wrap(
        children: [
          Row(
            children: [
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.segment.classImage),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          return Text('Your error widget...');
                        },
                      ),
                      color: OlukoColors.white,
                    ),
                    width: 60,
                    height: 90,
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
                              style: OlukoFonts.olukoSmallFont(
                                  customColor: OlukoColors.grayColor,
                                  custoFontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              widget.segment.segmentName,
                              overflow: TextOverflow.ellipsis,
                              style: OlukoFonts.olukoMediumFont(
                                  customColor: OlukoColors.white,
                                  custoFontWeight: FontWeight.w500),
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
