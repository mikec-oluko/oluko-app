import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';

class SubscriptionCard extends StatefulWidget {
  final Function(bool) onPressed;
  final String title;
  final List<String> subtitles;
  final String priceLabel;
  final String priceSubtitle;
  bool selected = false;

  SubscriptionCard(
      {this.title,
      this.subtitles,
      this.priceLabel,
      this.priceSubtitle,
      this.onPressed,
      this.selected});

  @override
  _State createState() => _State();
}

class _State extends State<SubscriptionCard> {
  @override
  Widget build(BuildContext context) {
    Color cardColor =
        widget.selected ? OlukoColors.secondary : OlukoColors.primary;
    return GestureDetector(
      onTap: () => this.setState(() {
        widget.selected = !widget.selected;
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: cardColor, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          stops: [0.1, 1],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            cardColor,
                            Colors.transparent,
                          ],
                        ),
                        color: cardColor,
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                      child: Column(children: [
                        Row(
                          children: [
                            Text(widget.title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: displayFeatures(widget.subtitles)),
                          ],
                        )
                      ]),
                    ),
                  ),
                  Container(
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        child: Column(children: [
                          Row(
                            children: [
                              Text(widget.priceLabel,
                                  style: TextStyle(
                                      color: cardColor,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: [
                              Text(widget.priceSubtitle,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300)),
                            ],
                          )
                        ])),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> displayFeatures(List<String> items) {
    return items
        .map((item) => Text(item,
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w300)))
        .toList();
  }
}
