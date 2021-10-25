import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class ChallengeDetailSection extends StatefulWidget {
  final Segment segment;

  ChallengeDetailSection({
    this.segment,
  });

  @override
  _State createState() => _State();
}

class _State extends State<ChallengeDetailSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 40, right: 15, left: 15, bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.segment.isChallenge
                  ? (OlukoLocalizations.get(context, 'challengeTitle') +
                      widget.segment.name)
                  : widget.segment.name,
              style:
                  OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.segment.description,
              style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: SegmentUtils.getSegmentSummary(
                        widget.segment, context, OlukoColors.white))),
          ],
        ));
  }
}
