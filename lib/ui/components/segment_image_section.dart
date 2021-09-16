import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/ui/components/segment_step_section.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class SegmentImageSection extends StatefulWidget {
  final Segment segment;
  final bool showBackButton;
  final int currentSegmentStep;
  final int totalSegmentStep;

  SegmentImageSection(
      {this.segment,
      this.showBackButton = true,
      this.currentSegmentStep,
      this.totalSegmentStep,
      Key key})
      : super(key: key);

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
      Padding(
          padding: EdgeInsets.only(top: 270, right: 15, left: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.segment.name,
                style:
                    OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.segment.description,
                style:
                    OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400),
              ),
              SegmentStepSection(
                  currentSegmentStep: widget.currentSegmentStep,
                  totalSegmentStep: widget.totalSegmentStep),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: SegmentUtils.getSegmentSummary(
                          widget.segment, context, OlukoColors.white))),
            ],
          ))
    ]);
  }

  Widget topButtons() {
    return Padding(
        padding: EdgeInsets.only(top: 15),
        child: Row(
          children: [
            widget.showBackButton
                ? IconButton(
                    icon:
                        Icon(Icons.chevron_left, size: 35, color: Colors.white),
                    onPressed: () => Navigator.pop(context))
                : SizedBox(),
            Expanded(child: SizedBox()),
            Padding(
                padding: EdgeInsets.only(right: 15),
                child: Stack(alignment: Alignment.center, children: [
                  Image.asset(
                    'assets/courses/outlined_camera.png',
                    scale: 3,
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(Icons.circle_outlined,
                          size: 16, color: OlukoColors.primary))
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
}
