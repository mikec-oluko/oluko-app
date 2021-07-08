import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/helpers/enum_helper.dart';
import 'package:mvt_fitness/models/plan.dart';

class SubscriptionCard extends StatefulWidget {
  Function(bool) onPressed;
  Function() onHintPressed;
  String title;
  List<String> subtitles;
  String priceLabel;
  String priceSubtitle;
  bool selected;
  bool showHint;
  String backgroundImage;

  SubscriptionCard(
      {this.title,
      this.subtitles,
      this.priceLabel,
      this.priceSubtitle,
      this.onPressed,
      this.showHint,
      this.onHintPressed,
      this.selected,
      this.backgroundImage});

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
                  Stack(children: [
                    Opacity(
                      opacity: 0.3,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                alignment: Alignment.centerRight,
                                image: NetworkImage(widget.backgroundImage)),
                            borderRadius: BorderRadius.all(Radius.circular(9))),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 30, horizontal: 10),
                          child: Container(
                            height: 30.0 +
                                (widget.subtitles.length * 15).toDouble(),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            stops: [0.15, 1],
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
                        child: Container(
                          height:
                              41.0 + (widget.subtitles.length * 15).toDouble(),
                          child: Column(children: [
                            Row(
                              children: [
                                Text(widget.title,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold)),
                                widget.showHint ? getWaitList() : SizedBox()
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        displayFeatures(widget.subtitles)),
                              ],
                            )
                          ]),
                        ),
                      ),
                    ),
                  ]),
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
        .map((item) => Text(
            featureLabel[EnumHelper.enumFromString<PlanFeature>(
                PlanFeature.values, item)],
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w300)))
        .toList();
  }

  Widget getWaitList() {
    return Expanded(
        child: InkWell(
      onTap: () => widget.onHintPressed(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Waitlist',
            style: TextStyle(color: OlukoColors.secondary),
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                Icons.help,
                color: OlukoColors.secondary,
              ))
        ],
      ),
    ));
  }
}
