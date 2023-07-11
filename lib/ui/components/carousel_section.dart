import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CarouselSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Function() onOptionTap;
  final String optionLabel;
  final double height;
  final double width;

  CarouselSection({this.title, this.subtitle, this.children, this.onOptionTap, this.optionLabel, this.height, this.width});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CarouselSection> {
  @override
  Widget build(BuildContext context) {
    return widget.children.isNotEmpty
        ? Container(
            height: widget.height,
            child: _carouselContent(),
          )
        : const SizedBox.shrink();
  }

  Column _carouselContent() {
    return Column(children: [
      Flexible(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.title != null) TitleBody(widget.title) else const SizedBox.shrink(),
            if (widget.subtitle != null) TitleBody(widget.title) else const SizedBox.shrink(),
            GestureDetector(
              onTap: () => widget.onOptionTap(),
              child: widget.optionLabel != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Text(
                        widget.optionLabel ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary),
                      ),
                    )
                  : const SizedBox.shrink(),
            )
          ],
        ),
      ),
      Flexible(
        flex: 9,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Container(
              child: Align(
            alignment: Alignment.centerLeft,
            child: ListView(
              physics: OlukoNeumorphism.listViewPhysicsEffect,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: widget.children,
            ),
          )),
        ),
      )
    ]);
  }
}
