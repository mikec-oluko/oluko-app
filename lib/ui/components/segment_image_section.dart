import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/ui/components/audio_section.dart';
import 'package:oluko_app/ui/components/people_section.dart';
import 'package:oluko_app/ui/components/segment_step_section.dart';
import 'package:oluko_app/ui/components/vertical_divider.dart' as verticalDivider;
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class SegmentImageSection extends StatefulWidget {
  final Segment segment;
  final bool showBackButton;
  final int currentSegmentStep;
  final int totalSegmentStep;
  final Function() audioAction;
  final Function() peopleAction;
  final Function() clockAction;

  SegmentImageSection({this.segment, this.showBackButton = true, this.currentSegmentStep, this.totalSegmentStep, Key key, this.audioAction, this.clockAction, this.peopleAction}) : super(key: key);

  @override
  _SegmentImageSectionState createState() => _SegmentImageSectionState();
}

class _SegmentImageSectionState extends State<SegmentImageSection> {
  ChewieController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return imageWithButtons();
  }

  Widget imageWithButtons() {
    return Stack(children: [
      imageSection(),
      topButtons(),
      if (widget.segment.isChallenge) challengeButtons(),
      Padding(
          padding: EdgeInsets.only(top: 270, right: 15, left: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.segment.isChallenge ? (OlukoLocalizations.get(context, 'challengeTitle') + widget.segment.name) : widget.segment.name,
                style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.segment.description,
                style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400),
              ),
              SegmentStepSection(currentSegmentStep: widget.currentSegmentStep, totalSegmentStep: widget.totalSegmentStep),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: SegmentUtils.getSegmentSummary(widget.segment, context, OlukoColors.white))),
            ],
          ))
    ]);
  }

  Widget topButtons() {
    return Padding(
        padding: EdgeInsets.only(top: 15),
        child: Row(
          children: [
            widget.showBackButton ? IconButton(icon: Icon(Icons.chevron_left, size: 35, color: Colors.white), onPressed: () => Navigator.pop(context)) : SizedBox(),
            Expanded(child: SizedBox()),
            Padding(
                padding: EdgeInsets.only(right: 15),
                child: Stack(alignment: Alignment.center, children: [
                  Image.asset(
                    'assets/courses/outlined_camera.png',
                    scale: 3,
                  ),
                  Padding(padding: EdgeInsets.only(top: 1), child: Icon(Icons.circle_outlined, size: 16, color: OlukoColors.primary))
                ]))
          ],
        ));
  }

  Widget imageSection() {
    return Stack(alignment: Alignment.center, children: [
      AspectRatio(
          aspectRatio: 3 / 4,
          child: Image.network(
            widget.segment.image,
            fit: BoxFit.cover,
          )),
      Image.asset(
        'assets/courses/degraded.png',
        scale: 4,
      ),
    ]);
  }

  Widget challengeButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 190),
      child: Column(children: [
        Row(children: [
          GestureDetector(child: AudioSection(audioMessageQty: 10), onTap: widget.audioAction),
          verticalDivider.VerticalDivider(
            width: 30,
            height: 60,
          ),
          GestureDetector(child: PeopleSection(peopleQty: 30), onTap: widget.peopleAction),
          verticalDivider.VerticalDivider(
            width: 30,
            height: 60,
          ),
          GestureDetector(child: clockSection(), onTap: widget.clockAction),
        ])
      ]),
    );
  }

  Widget clockSection() {
    return Container(
      width: 60,
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Image.asset(
              'assets/courses/clock.png',
              height: 24,
              width: 27,
            )),
        const SizedBox(height: 5),
        Text(
          OlukoLocalizations.get(context, 'personalRecord'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
        )
      ]),
    );
  }
}
