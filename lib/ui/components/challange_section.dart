import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';

class ChallangeSection extends StatefulWidget {
  final List<SegmentSubmodel> challanges;

  ChallangeSection({this.challanges});

  @override
  _State createState() => _State();
}

class _State extends State<ChallangeSection> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            Divider(
              color: OlukoColors.grayColor,
              height: 50,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: getChallangesCards()),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> getChallangesCards() {
    List<Widget> challangeCards = [];
    widget.challanges.forEach((challange) {
      challangeCards.add(
        ClipRRect(
          child: Image.network(
            challange.challangeImage,
            height: 115,
            width: 80,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        ),
      );
      challangeCards.add(SizedBox(width: 15));
    });
    return challangeCards;
  }
}
