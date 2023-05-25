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
  List<Widget> _growingWidgetList = [];
  final _listController = ScrollController();
  final int _batchMaxRange = 10;

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _growingWidgetList =
        widget.children.isNotEmpty ? [...widget.children.getRange(0, widget.children.length > _batchMaxRange ? _batchMaxRange : widget.children.length)] : [];
    _listController.addListener(() {
      if (_listController.position.atEdge) {
        if (_listController.position.pixels > 0) {
          if (_growingWidgetList.length != widget.children.length) {
            _getMoreElements();
            setState(() {});
          }
        }
      }
    });
    super.initState();
  }

  void _getMoreElements() => _growingWidgetList = widget.children.isNotEmpty
      ? [
          ...widget.children.getRange(
              0, widget.children.length > _growingWidgetList.length + _batchMaxRange ? _growingWidgetList.length + _batchMaxRange : widget.children.length)
        ]
      : [];

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
      controller: _listController,
      padding: EdgeInsets.zero,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      shrinkWrap: true,
      itemCount: 1,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        return Row(
          children: _growingWidgetList,
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
