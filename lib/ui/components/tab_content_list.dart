import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/timeline_list_content.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TabContentList extends StatefulWidget {
  const TabContentList({this.contentToDisplay});
  final List<Widget> contentToDisplay;

  @override
  _TabContentListState createState() => _TabContentListState();
}

class _TabContentListState extends State<TabContentList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(children: testFunction()),
    );
  }

  List<Widget> testFunction() {
    List<Widget> contentToShow = [];
    contentToShow.add(TimelineListContent(content: widget.contentToDisplay.take(3).toList()));
    contentToShow.add(TimelineListContent(
      content: widget.contentToDisplay.take(2).toList(),
      newDate: '22/9/21',
    ));
    contentToShow.add(TimelineListContent(content: widget.contentToDisplay.take(1).toList(), newDate: '20/9/21'));
    return contentToShow;
  }
}
// widget.contentToDisplay.map((element) {
//           if (widget.contentToDisplay.indexOf(element) == 0) {
//             return Container(
//               color: OlukoColors.black,
//               child: TimelineTile(
//                   indicatorStyle: IndicatorStyle(width: 15, height: 15),
//                   beforeLineStyle: LineStyle(thickness: 2),
//                   afterLineStyle: LineStyle(thickness: 2),
//                   isFirst: true,
//                   alignment: TimelineAlign.start,
//                   // startChild: Text('date',
//                   //     style:
//                   //         OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
//                   endChild: element),
//             );
//           } else if (widget.contentToDisplay.indexOf(element) == widget.contentToDisplay.length - 1) {
//             return Container(
//               color: OlukoColors.black,
//               child: TimelineTile(
//                   indicatorStyle: IndicatorStyle(width: 15, height: 15, indicatorXY: 0.0),
//                   beforeLineStyle: LineStyle(thickness: 2),
//                   afterLineStyle: LineStyle(thickness: 2),
//                   isLast: true,
//                   alignment: TimelineAlign.start,
//                   // startChild: Text('date',
//                   //     style:
//                   //         OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
//                   endChild: Column(
//                     children: [
//                       Text('Today',
//                           style: OlukoFonts.olukoMediumFont(
//                               customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
//                       element,
//                     ],
//                   )),
//             );
//           } else {
//             return Container(
//               color: OlukoColors.black,
//               child: TimelineTile(
//                   indicatorStyle: IndicatorStyle(width: 15, height: 15),
//                   beforeLineStyle: LineStyle(thickness: 2),
//                   afterLineStyle: LineStyle(thickness: 2),
//                   alignment: TimelineAlign.start,
//                   // startChild: Text('date',
//                   //     style:
//                   //         OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
//                   endChild: element),
//             );
//           }
//         }).toList(),