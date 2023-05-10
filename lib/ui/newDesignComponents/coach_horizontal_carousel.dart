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
        mainAxisSize: MainAxisSize.max,
        children: [
          _headerContent(),
          // SingleChildScrollView(
          //   padding: EdgeInsets.zero,
          //   scrollDirection: Axis.horizontal,
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: widget.children,
          //   ),
          // )
          Flexible(
              child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: 1,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: widget.children,
              );
            },
          ))
        ],
      ),
    );
  }

  Row _headerContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
  // Column _carouselContent() {
  //   return Column(children: [
  //     Flexible(
  //       flex: 1,
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           if (widget.title != null)
  //             // Expanded(
  //             //   child: Row(
  //             //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             //     children: [
  //             TitleBody(widget.title)
  //           //     ],
  //           //   ),
  //           // )
  //           else
  //             SizedBox(),
  //           if (widget.subtitle != null) TitleBody(widget.title) else SizedBox(),
  //           GestureDetector(
  //             onTap: () => widget.onOptionTap(),
  //             child: widget.optionLabel != null
  //                 ? Padding(
  //                     padding: const EdgeInsets.only(top: 3.0),
  //                     child: Text(
  //                       widget.optionLabel ?? '',
  //                       overflow: TextOverflow.ellipsis,
  //                       style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary),
  //                     ),
  //                   )
  //                 : SizedBox(),
  //           )
  //         ],
  //       ),
  //     ),
  //     Flexible(
  //       flex: 9,
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(vertical: OlukoNeumorphism.isNeumorphismDesign ? 5 : 10),
  //         child: Container(
  //             child: Align(
  //           alignment: Alignment.centerLeft,
  //           child: ListView(
  //             addAutomaticKeepAlives: false,
  //             addRepaintBoundaries: false,
  //             shrinkWrap: true,
  //             scrollDirection: Axis.horizontal,
  //             children: widget.children,
  //           ),
  //         )),
  //       ),
  //     )
  //   ]);
  // }
}
