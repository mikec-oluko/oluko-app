import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class SubscriptionCard extends StatefulWidget {
  Function(bool) onPressed;
  Function() onHintPressed;
  String title;
  String priceLabel;
  String priceSubtitle;
  bool selected;
  bool showHint;
  String backgroundImage;

  SubscriptionCard(
      {this.title,
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
    final Color cardColor = widget.selected ? OlukoColors.secondary : OlukoColors.primary;
    if (widget.title == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: cardColor, width: 2), borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Column(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Opacity(
                        opacity: 0.3,
                        child: Container(
                          decoration: const BoxDecoration(color: OlukoColors.black, borderRadius: BorderRadius.all(Radius.circular(9))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                            child: Container(
                              height: 30.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  OlukoLocalizations.get(context, 'errorGettingCurrentPlan'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => setState(() {
          widget.selected = !widget.selected;
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: cardColor, width: 2), borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Column(
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        Opacity(
                          opacity: 0.3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: OlukoColors.black,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                alignment: Alignment.centerRight,
                                image: CachedNetworkImageProvider(widget.backgroundImage),
                              ),
                              borderRadius: const BorderRadius.all(Radius.circular(9)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                              child: Container(
                                height: 30.0,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              stops: [0.15, 1],
                              colors: [
                                cardColor,
                                Colors.transparent,
                              ],
                            ),
                            color: cardColor,
                            borderRadius: const BorderRadius.all(Radius.circular(3)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                            child: SizedBox(
                              height: 41.0,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(widget.title,
                                          style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                                      if (widget.showHint) getWaitList() else const SizedBox()
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(widget.priceLabel, style: TextStyle(color: cardColor, fontSize: 30, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                widget.priceSubtitle,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  List<Widget> displayFeatures(List<String> items) {
    return items
        .map(
          (item) => Text(
            featureLabel[EnumHelper.enumFromString<PlanFeature>(PlanFeature.values, item)],
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
          ),
        )
        .toList();
  }

  Widget getWaitList() {
    return Expanded(
      child: InkWell(
        onTap: () => widget.onHintPressed(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text(
              'Waitlist',
              style: TextStyle(color: OlukoColors.secondary),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                Icons.help,
                color: OlukoColors.secondary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
