import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';

class CardInfo extends StatelessWidget {
  CardInfo(
      {this.title = "Placeholder Title",
      this.mainText = 'Main Text',
      this.subtitle = 'Subtitle',
      this.img = "https://via.placeholder.com/250",
      this.tap = defaultFunc});

  final String img;
  final Function tap;
  final String title;
  final String mainText;
  final String subtitle;

  static void defaultFunc() {
    print("the function works!");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Container(
            height: 230,
            width: null,
            child: GestureDetector(
              onTap: tap,
              child: Card(
                  elevation: 0.4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6.0))),
                  child: Stack(children: [
                    Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)),
                            image: DecorationImage(
                              image: NetworkImage(img),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                return Text('Your error widget...');
                              },
                            ))),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)))),
                    Positioned(
                        child: Padding(
                            padding:
                                EdgeInsets.only(top: 40, left: 20, right: 150),
                            child: Column(children: [
                              Text(title,
                                  style: TextStyle(
                                      color: OlukoColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25.0)),
                              Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Row(children: [
                                    Text(mainText,
                                        style: TextStyle(
                                            color: OlukoColors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25.0)),
                                  ])),
                              Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Row(children: [
                                    Text(subtitle,
                                        style: TextStyle(
                                            color: OlukoColors.white,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 22.0)),
                                  ]))
                            ])))
                  ])),
            )));
  }
}
