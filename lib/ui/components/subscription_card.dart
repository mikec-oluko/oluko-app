import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:html/parser.dart';

class SubscriptionCard extends StatefulWidget {
  Function(bool) onPressed;
  Plan plan;
  String priceLabel;
  String priceSubtitle;
  bool selected;
  String backgroundImage;
  String userId;
  Function() loadingAction;
  Function() subscribeAction;

  SubscriptionCard({this.plan, this.priceLabel, this.priceSubtitle, this.onPressed, this.selected, this.backgroundImage, this.userId, this.loadingAction});

  @override
  _State createState() => _State();
}

class _State extends State<SubscriptionCard> {
  @override
  Widget build(BuildContext context) {
    return _subscriptionCardForPlan();
  }

  Container _subscriptionCardForPlan() {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: OlukoColors.primary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: OlukoColors.primary),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: OlukoColors.subscriptionTabsColor,
              ),
              child: ListView(
                  children: _parseHtmlString(widget.plan.description)
                      .map((element) => Padding(
                            padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                            child: Row(
                              children: [
                                Text('- ', style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.black)),
                                Text(element, style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.black)),
                              ],
                            ),
                          ))
                      .toList())),
        ));
  }

  Padding oldSubscriptionCard(BuildContext context, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: SizedBox(
        width: ScreenUtils.width(context) - 50,
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: cardColor, width: 2), borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: widget.plan.name == null
              ? Text(
                  OlukoLocalizations.get(context, 'errorGettingCurrentPlan'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                )
              : GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(color: OlukoColors.black, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: Text(widget.plan.name, style: TextStyle(color: cardColor, fontSize: 20, fontWeight: FontWeight.normal)),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      widget.loadingAction();
                                      widget.subscribeAction();
                                    },
                                    child: Text(
                                      OlukoLocalizations.get(context, 'purchase'),
                                      style: const TextStyle(color: OlukoColors.primary, fontSize: 15, fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              // SizedBox(
                              //   child: Text(
                              //     _parseHtmlString(widget.plan.description),
                              //     style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w300),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('\$${widget.plan.applePrice} ',
                                    style: const TextStyle(color: OlukoColors.coral, fontSize: 30, fontWeight: FontWeight.bold)),
                                Text(widget.priceLabel, style: const TextStyle(color: OlukoColors.coral, fontSize: 30, fontWeight: FontWeight.normal)),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  widget.priceSubtitle,
                                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w300),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  List<String> _parseHtmlString(String htmlString) {
    var rows = parse(htmlString).getElementsByTagName('ul')[0].getElementsByTagName('li');
    return rows.map((element) => element.text).toList();
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
        onTap: () {} /*widget.onHintPressed()*/,
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
