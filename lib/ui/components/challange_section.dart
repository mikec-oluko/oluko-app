import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'movement_item_bubbles.dart';

class ChallangeSection extends StatefulWidget {
  final List<SegmentSubmodel> challanges;

  ChallangeSection({this.challanges});

  @override
  _State createState() => _State();
}

class _State extends State<ChallangeSection> {
  //TODO: Make dynimic
  String challangeImage =
      "https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/course_sample_images%2Fchallange.jpeg?alt=media&token=f8dca8e7-0941-4a88-a207-02d6ac28ef56";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              Divider(
                color: OlukoColors.grayColor,
                height: 50,
              ),
              /*Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  widget.segmentName,
                  style: OlukoFonts.olukoSuperBigFont(
                      custoFontWeight: FontWeight.bold),
                ),
              ),*/
              Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: getChallangesCards()
                          //Prevent the last item to be overlayed by the carousel gradient
                          ..add(SizedBox(
                            width: 180,
                          ))),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getChallangesCards() {
    List<Widget> challangeCards = [];
    widget.challanges.forEach((challange) {
      challangeCards
          .add(Expanded(flex: 9, child: Image.network(challangeImage)));
    });
  }
}
