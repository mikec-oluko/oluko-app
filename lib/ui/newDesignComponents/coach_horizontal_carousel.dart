import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachTabHorizontalCarousel extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Function() onOptionTap;
  final String optionLabel;
  final double height;
  final double width;

  const CoachTabHorizontalCarousel({this.title, this.subtitle, this.children, this.onOptionTap, this.optionLabel, this.height, this.width});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CoachTabHorizontalCarousel> {
  @override
  Widget build(BuildContext context) {
    return widget.children.isNotEmpty ? _carouselContent() : const SizedBox.shrink();
  }

  Widget _carouselContent() {
    return SizedBox(
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_headerContent(), horizontalScrollComponent()],
      ),
    );
  }

  Flexible horizontalScrollComponent() {
    return Flexible(
        child: ListView.builder(
      padding: EdgeInsets.zero,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      shrinkWrap: true,
      itemCount: 1,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        return Row(
          children: widget.children,
        );
      },
    ));
  }

  Row _headerContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.title != null) TitleBody(widget.title) else const SizedBox.shrink(),
        GestureDetector(
          onTap: () => widget.onOptionTap(),
          child: widget.optionLabel != null
              ? Text(
                  widget.optionLabel ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary),
                )
              : const SizedBox.shrink(),
        )
      ],
    );
  }
}
