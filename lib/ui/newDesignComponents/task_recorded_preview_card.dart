import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';

class TaskRecordedPreviewCard extends StatefulWidget {
  final String thumbnail;
  final String timeLabel;
  final bool taskReady;
  const TaskRecordedPreviewCard({Key key, this.thumbnail, this.timeLabel, this.taskReady = false}) : super(key: key);

  @override
  State<TaskRecordedPreviewCard> createState() => _TaskRecordedPreviewCardState();
}

class _TaskRecordedPreviewCardState extends State<TaskRecordedPreviewCard> {
  @override
  Widget build(BuildContext context) {
    return !widget.taskReady ? getLoadingCard() : _previewCardReady();
  }

  Padding _previewCardReady() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Stack(alignment: AlignmentDirectional.center, children: [
          if (widget.thumbnail == null)
            const Image(image: AssetImage('assets/assessment/thumbnail.jpg'))
          else
            Image(image: CachedNetworkImageProvider(widget.thumbnail)),
          Align(
              child: OlukoNeumorphism.isNeumorphismDesign
                  ? const SizedBox(
                      width: 50,
                      height: 50,
                      child: OlukoBlurredButton(
                        childContent: Icon(
                          Icons.play_arrow,
                          color: OlukoColors.white,
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/assessment/play.png',
                      scale: 5,
                      height: 40,
                      width: 60,
                    )),
          Positioned(
              top: OlukoNeumorphism.isNeumorphismDesign ? 10 : null,
              bottom: !OlukoNeumorphism.isNeumorphismDesign ? 10 : null,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: OlukoColors.black.withAlpha(150),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.timeLabel,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )),
        ]),
      ),
    );
  }

  Widget getLoadingCard() {
    return Container(
      width: 100,
      height: 150,
      child: Neumorphic(
        style: OlukoNeumorphism.getNeumorphicStyleForCircleElementNegativeDepth()
            .copyWith(boxShape: NeumorphicBoxShape.roundRect(const BorderRadius.all(Radius.circular(15)))),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
